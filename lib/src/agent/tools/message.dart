import 'package:nanobot_dart/src/agent/tool_registry.dart';

/// Tool for sending a message (final answer or communication).
class MessageTool extends Tool {
  @override
  String get name => 'message';

  @override
  String get description => 'Send a message to the user or system.';

  @override
  Map<String, dynamic> get parametersSchema => {
        'type': 'object',
        'properties': {
          'content': {
            'type': 'string',
            'description': 'The content of the message.',
          },
        },
        'required': ['content'],
      };

  @override
  Future<String> execute(Map<String, dynamic> params) async {
    final content = params['content'] as String;
    // In a real agent loop, this might trigger an event on the message bus.
    // For the tool execution itself, it just returns confirmation.
    // The AgentLoop will observe the tool call and handle the message event.
    return 'Message sent: $content';
  }
}
