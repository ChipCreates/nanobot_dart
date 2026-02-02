import 'dart:async';
import 'dart:convert';

import 'package:nanobot_dart/src/providers/llm_provider.dart';

/// Registry for tools that can be called by the LLM.
class ToolRegistry {
  final Map<String, Tool> _tools = {};

  /// Register a tool with the registry.
  void register(Tool tool) {
    _tools[tool.name] = tool;
  }

  /// Unregister a tool by name.
  void unregister(String name) {
    _tools.remove(name);
  }

  /// Get all registered tool names.
  List<String> get names => _tools.keys.toList();

  /// Get tool definitions for LLM function calling.
  List<ToolDefinition> get definitions =>
      _tools.values.map((t) => t.definition).toList();

  /// Execute a tool call and return the result.
  Future<ToolResult> execute(ToolCall call) async {
    final tool = _tools[call.name];
    if (tool == null) {
      return ToolResult.error('Unknown tool: ${call.name}');
    }

    try {
      final params = call.arguments is String
          ? jsonDecode(call.arguments as String) as Map<String, dynamic>
          : call.arguments as Map<String, dynamic>;

      final output = await tool.execute(params);
      return ToolResult.success(output);
    } catch (e) {
      return ToolResult.error('Tool execution failed: $e');
    }
  }
}

/// A tool that can be called by the LLM.
abstract class Tool {
  /// Unique name for this tool.
  String get name;

  /// Human-readable description.
  String get description;

  /// JSON Schema for the tool's parameters.
  Map<String, dynamic> get parametersSchema;

  /// Execute the tool with the given parameters.
  Future<String> execute(Map<String, dynamic> params);

  /// Get the tool definition for LLM function calling.
  ToolDefinition get definition => ToolDefinition(
        name: name,
        description: description,
        parameters: parametersSchema,
      );
}

/// Definition of a tool for LLM function calling.
class ToolDefinition {
  const ToolDefinition({
    required this.name,
    required this.description,
    required this.parameters,
  });

  final String name;
  final String description;
  final Map<String, dynamic> parameters;

  Map<String, dynamic> toJson() => {
        'type': 'function',
        'function': {
          'name': name,
          'description': description,
          'parameters': parameters,
        },
      };
}

/// Result of a tool execution.
class ToolResult {
  const ToolResult._({required this.output, required this.isError});

  factory ToolResult.success(String output) =>
      ToolResult._(output: output, isError: false);

  factory ToolResult.error(String message) =>
      ToolResult._(output: message, isError: true);

  final String output;
  final bool isError;
}
