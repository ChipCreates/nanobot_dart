import 'package:nanobot_dart/nanobot_dart.dart';

/// A mock provider that returns pre-determined responses for testing.
class MockIntegrationProvider implements LlmProvider {
  MockIntegrationProvider({
    this.responses = const [],
    this.onChat,
  });

  final List<LlmResponse> responses;
  final Future<LlmResponse> Function(
    List<Message> messages,
    List<ToolDefinition> tools,
  )? onChat;

  int _callCount = 0;

  String get id => 'mock-integration';

  @override
  String get name => 'Mock Integration';

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<LlmResponse> chat({
    required List<dynamic> messages,
    List<dynamic>? tools,
    String? model,
  }) async {
    if (onChat != null) {
      // Cast to expected types for helper
      return onChat!(
        messages.cast<Message>(),
        tools?.cast<ToolDefinition>() ?? [],
      );
    }

    if (_callCount < responses.length) {
      return responses[_callCount++];
    }

    return const LlmResponse(content: 'Mock response (out of scripts)');
  }
}
