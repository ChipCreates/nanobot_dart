import 'package:nanobot_dart/src/agent/tool_registry.dart';

/// Mock tool for testing.
class MockTool extends Tool {
  MockTool({
    required this.toolName,
    this.output = 'Mock tool executed',
  });

  final String toolName;
  final String output;

  int callCount = 0;
  Map<String, dynamic>? lastParams;

  @override
  String get name => toolName;

  @override
  String get description => 'Mock tool for testing';

  @override
  Map<String, dynamic> get parametersSchema => {
        'type': 'object',
        'properties': {
          'input': {
            'type': 'string',
            'description': 'Test input',
          },
        },
      };

  @override
  Future<String> execute(Map<String, dynamic> params) async {
    callCount++;
    lastParams = params;
    return output;
  }
}
