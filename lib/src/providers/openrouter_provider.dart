import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nanobot_dart/src/providers/llm_provider.dart';

/// OpenRouter LLM provider for cloud-based inference.
///
/// Supports multiple models through OpenRouter's unified API.
/// Requires an API key from https://openrouter.ai/
class OpenRouterProvider implements LlmProvider {
  OpenRouterProvider({
    required this.apiKey,
    this.defaultModel = 'anthropic/claude-3.5-sonnet',
    this.baseUrl = 'https://openrouter.ai/api/v1',
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// OpenRouter API key.
  final String apiKey;

  /// Default model to use if not specified.
  final String defaultModel;

  /// Base URL for OpenRouter API.
  final String baseUrl;

  /// HTTP client for making requests.
  final http.Client _httpClient;

  @override
  String get name => 'openrouter';

  @override
  Future<bool> isAvailable() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/models'),
        headers: {'Authorization': 'Bearer $apiKey'},
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
      'model': model ?? defaultModel,
      'messages': messages,
    };

    if (tools != null && tools.isNotEmpty) {
      requestBody['tools'] = tools;
      requestBody['tool_choice'] = 'auto';
    }

    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://github.com/nanobot',
          'X-Title': 'NanoBot Dart',
        },
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
      return LlmResponse(content: 'Error calling OpenRouter: $e');
    }
  }

  LlmResponse _parseResponse(Map<String, dynamic> data) {
    final choices = data['choices'] as List<dynamic>;
    if (choices.isEmpty) {
      return const LlmResponse(content: 'No response from model');
    }

    final choice = choices[0] as Map<String, dynamic>;
    final message = choice['message'] as Map<String, dynamic>;

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
