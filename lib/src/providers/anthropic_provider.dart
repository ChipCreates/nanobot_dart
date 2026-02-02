import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nanobot_dart/src/providers/llm_provider.dart';

/// Anthropic LLM provider.
class AnthropicProvider implements LlmProvider {
  AnthropicProvider({
    required this.apiKey,
    this.defaultModel = 'claude-3-5-sonnet-20240620',
    this.baseUrl = 'https://api.anthropic.com/v1',
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String apiKey;
  final String defaultModel;
  final String baseUrl;
  final http.Client _httpClient;

  @override
  String get name => 'anthropic';

  @override
  Future<bool> isAvailable() async {
    // Anthropic doesn't have a simple auth check endpoint, assuming true if key exists
    return apiKey.isNotEmpty;
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
      'max_tokens': 4096, // Required for Anthropic
    };

    if (tools != null && tools.isNotEmpty) {
      requestBody['tools'] = tools;
    }

    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/messages'),
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        return LlmResponse(
          content: 'Error: ${response.statusCode} - ${response.body}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final contentAcc = StringBuffer();

      final contentList = data['content'] as List<dynamic>;
      List<ToolCall>? toolCalls;

      for (final item in contentList) {
        final map = item as Map<String, dynamic>;
        if (map['type'] == 'text') {
          contentAcc.write(map['text']);
        } else if (map['type'] == 'tool_use') {
          toolCalls ??= [];
          toolCalls.add(
            ToolCall(
              id: map['id'] as String,
              name: map['name'] as String,
              arguments: map['input'] as Map<String, dynamic>,
            ),
          );
        }
      }

      return LlmResponse(
        content: contentAcc.toString(),
        toolCalls: toolCalls,
      );
    } catch (e) {
      return LlmResponse(content: 'Error calling Anthropic: $e');
    }
  }
}
