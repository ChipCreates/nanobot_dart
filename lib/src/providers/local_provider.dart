import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nanobot_dart/src/providers/llm_provider.dart';

/// Local LLM provider using Ollama API.
///
/// Connects to a locally running Ollama instance for inference.
/// Default endpoint is http://localhost:11434.
///
/// Example:
/// ```dart
/// final provider = LocalLlmProvider(
///   model: 'llama3.1',
///   baseUrl: 'http://localhost:11434',
/// );
/// ```
class LocalLlmProvider implements LlmProvider {
  LocalLlmProvider({
    this.model = 'llama3.1',
    this.baseUrl = 'http://localhost:11434',
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Default model to use (e.g., 'llama3.1', 'mistral', 'codellama').
  final String model;

  /// Base URL for Ollama API.
  final String baseUrl;

  /// HTTP client for making requests.
  final http.Client _httpClient;

  @override
  String get name => 'local';

  @override
  Future<bool> isAvailable() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/api/tags'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<LlmResponse> chat({
    required List<dynamic> messages,
    List<dynamic>? tools,
    String? model,
  }) async {
    final requestBody = <String, dynamic>{
      'model': model ?? this.model,
      'messages': messages,
      'stream': false,
    };

    // Ollama 0.4+ supports tools in OpenAI format
    if (tools != null && tools.isNotEmpty) {
      requestBody['tools'] = tools;
    }

    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        return LlmResponse(
          content: 'Error: ${response.statusCode} - ${response.body}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseResponse(data);
    } catch (e) {
      return LlmResponse(content: 'Error calling Ollama: $e');
    }
  }

  LlmResponse _parseResponse(Map<String, dynamic> data) {
    // Ollama chat response format:
    // { "message": { "role": "assistant", "content": "..." } }
    final message = data['message'] as Map<String, dynamic>?;
    if (message == null) {
      return const LlmResponse(content: 'No response from model');
    }

    final content = message['content'] as String?;
    final toolCallsJson = message['tool_calls'] as List<dynamic>?;

    List<ToolCall>? toolCalls;
    if (toolCallsJson != null && toolCallsJson.isNotEmpty) {
      toolCalls = toolCallsJson
          .map((tc) => ToolCall.fromJson(tc as Map<String, dynamic>))
          .toList();
    }

    return LlmResponse(content: content, toolCalls: toolCalls);
  }

  /// Close the HTTP client.
  void dispose() {
    _httpClient.close();
  }
}
