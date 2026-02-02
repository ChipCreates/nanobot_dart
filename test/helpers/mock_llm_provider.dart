import 'package:nanobot_dart/src/providers/llm_provider.dart';

/// Mock LLM provider for testing.
///
/// Returns pre-configured responses in sequence.
class MockLlmProvider implements LlmProvider {
  MockLlmProvider(this.responses);

  /// Pre-configured responses to return.
  final List<LlmResponse> responses;

  int _callCount = 0;

  /// Get the number of times chat() was called.
  int get callCount => _callCount;

  /// Last messages passed to chat().
  List<dynamic>? lastMessages;

  /// Last tools passed to chat().
  List<dynamic>? lastTools;

  @override
  Future<LlmResponse> chat({
    required List<dynamic> messages,
    List<dynamic>? tools,
    String? model,
  }) async {
    lastMessages = messages;
    lastTools = tools;

    if (_callCount >= responses.length) {
      throw StateError(
        'No more mock responses available (called $_callCount times, '
        'only ${responses.length} responses configured)',
      );
    }

    return responses[_callCount++];
  }

  @override
  String get name => 'mock';

  @override
  Future<bool> isAvailable() async => true;

  /// Reset the call count and history.
  void reset() {
    _callCount = 0;
    lastMessages = null;
    lastTools = null;
  }
}
