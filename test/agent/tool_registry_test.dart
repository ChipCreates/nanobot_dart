import 'package:nanobot_dart/src/agent/tool_registry.dart';
import 'package:nanobot_dart/src/providers/llm_provider.dart';
import 'package:test/test.dart';

import '../helpers/mock_tool.dart';

void main() {
  group('ToolRegistry', () {
    late ToolRegistry registry;

    setUp(() {
      registry = ToolRegistry();
    });

    test('registers and retrieves tools by name', () {
      final tool = MockTool(toolName: 'test_tool');
      registry.register(tool);

      expect(registry.names, contains('test_tool'));
    });

    test('unregisters tools', () {
      final tool = MockTool(toolName: 'test_tool');
      registry.register(tool);
      expect(registry.names, contains('test_tool'));

      registry.unregister('test_tool');
      expect(registry.names, isNot(contains('test_tool')));
    });

    test('returns tool definitions for LLM function calling', () {
      final tool1 = MockTool(toolName: 'tool1');
      final tool2 = MockTool(toolName: 'tool2');
      registry
        ..register(tool1)
        ..register(tool2);

      final definitions = registry.definitions;

      expect(definitions.length, 2);
      expect(definitions[0].name, 'tool1');
      expect(definitions[1].name, 'tool2');
    });

    test('executes tool with valid parameters', () async {
      final tool = MockTool(
        toolName: 'test_tool',
        output: 'Success!',
      );
      registry.register(tool);

      const call = ToolCall(
        id: 'call_1',
        name: 'test_tool',
        arguments: <String, dynamic>{'input': 'test'},
      );

      final result = await registry.execute(call);

      expect(result.isError, false);
      expect(result.output, 'Success!');
      expect(tool.callCount, 1);
      expect(tool.lastParams, {'input': 'test'});
    });

    test('handles unknown tool gracefully', () async {
      const call = ToolCall(
        id: 'call_1',
        name: 'unknown_tool',
        arguments: <String, dynamic>{},
      );

      final result = await registry.execute(call);

      expect(result.isError, true);
      expect(result.output, contains('Unknown tool'));
    });

    test('handles tool execution errors', () async {
      final tool = _ErrorTool();
      registry.register(tool);

      const call = ToolCall(
        id: 'call_1',
        name: 'error_tool',
        arguments: <String, dynamic>{},
      );

      final result = await registry.execute(call);

      expect(result.isError, true);
      expect(result.output, contains('Tool execution failed'));
    });

    test('handles JSON string arguments', () async {
      final tool = MockTool(toolName: 'test_tool');
      registry.register(tool);

      const call = ToolCall(
        id: 'call_1',
        name: 'test_tool',
        arguments: '{"input": "json_string"}',
      );

      final result = await registry.execute(call);

      expect(result.isError, false);
      expect(tool.lastParams, {'input': 'json_string'});
    });

    test('replaces tool when registering with same name', () {
      final tool1 = MockTool(toolName: 'test_tool', output: 'First');
      final tool2 = MockTool(toolName: 'test_tool', output: 'Second');

      registry
        ..register(tool1)
        ..register(tool2);

      expect(registry.names.length, 1);
      expect(registry.names, contains('test_tool'));
    });
  });

  group('ToolDefinition', () {
    test('converts to JSON for LLM function calling', () {
      const definition = ToolDefinition(
        name: 'test_tool',
        description: 'A test tool',
        parameters: <String, dynamic>{
          'type': 'object',
          'properties': <String, dynamic>{
            'input': <String, dynamic>{
              'type': 'string',
              'description': 'Test input',
            },
          },
        },
      );

      final json = definition.toJson();
      final function = json['function'] as Map<String, dynamic>;
      final parameters = function['parameters'] as Map<String, dynamic>;

      expect(json['type'], 'function');
      expect(function['name'], 'test_tool');
      expect(function['description'], 'A test tool');
      expect(parameters['type'], 'object');
    });
  });

  group('ToolResult', () {
    test('creates success result', () {
      final result = ToolResult.success('Success message');

      expect(result.isError, false);
      expect(result.output, 'Success message');
    });

    test('creates error result', () {
      final result = ToolResult.error('Error message');

      expect(result.isError, true);
      expect(result.output, 'Error message');
    });
  });
}

/// Tool that always throws an error for testing error handling.
class _ErrorTool extends Tool {
  @override
  String get name => 'error_tool';

  @override
  String get description => 'Tool that throws errors';

  @override
  Map<String, dynamic> get parametersSchema => <String, dynamic>{
        'type': 'object',
        'properties': <String, dynamic>{},
      };

  @override
  Future<String> execute(Map<String, dynamic> params) async {
    throw Exception('Intentional error for testing');
  }
}
