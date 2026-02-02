import 'package:nanobot_dart/src/providers/llm_provider.dart';

/// Local LLM provider using llama.cpp.
class LocalLlmProvider implements LlmProvider {
  LocalLlmProvider({required this.modelPath});

  final String modelPath;

  @override
  String get name => 'local';

  @override
  Future<bool> isAvailable() async {
    return false;
  }

  @override
  Future<LlmResponse> chat({
    required List<dynamic> messages,
    List<dynamic>? tools,
    String? model,
  }) async {
    throw UnimplementedError('LocalLlmProvider.chat not yet implemented');
  }
}
