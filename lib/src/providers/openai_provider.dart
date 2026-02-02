import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nanobot_dart/src/providers/llm_provider.dart';

/// OpenAI LLM provider.
class OpenAIProvider implements LlmProvider {
  OpenAIProvider({
    required this.apiKey,
    this.defaultModel = 'gpt-4o',
    this.baseUrl = 'https://api.openai.com/v1',
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String apiKey;
  final String defaultModel;
  final String baseUrl;
  final http.Client _httpClient;

  @override
  String get name => 'openai';

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
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        return LlmResponse(
          content: 'Error: ${response.statusCode} - ${response.body}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
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
    } catch (e) {
      return LlmResponse(content: 'Error calling OpenAI: $e');
    }
  }
}
