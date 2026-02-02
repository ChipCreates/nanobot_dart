import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nanobot_dart/src/providers/openrouter_provider.dart';
import 'package:test/test.dart';

void main() {
  group('OpenRouterProvider', () {
    test('sends chat completion request with correct format', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), contains('/chat/completions'));
        expect(request.headers['Authorization'], 'Bearer test-key');
        expect(request.headers['Content-Type'], 'application/json');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['model'], 'anthropic/claude-3.5-sonnet');
        expect(body['messages'], isA<List<dynamic>>());

        return http.Response(
          jsonEncode(<String, dynamic>{
            'choices': [
              <String, dynamic>{
                'message': <String, dynamic>{
                  'content': 'Hello! How can I help you?',
                },
              },
            ],
          }),
          200,
        );
      });

      final provider = OpenRouterProvider(
        apiKey: 'test-key',
        httpClient: mockClient,
      );

      final response = await provider.chat(
        messages: <Map<String, dynamic>>[
          <String, dynamic>{'role': 'user', 'content': 'Hi'},
        ],
      );

      expect(response.content, 'Hello! How can I help you?');
      expect(response.hasToolCalls, false);
    });

    test('handles tool calls in response', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, dynamic>{
            'choices': [
              <String, dynamic>{
                'message': <String, dynamic>{
                  'content': 'Let me search for that',
                  'tool_calls': [
                    <String, dynamic>{
                      'id': 'call_123',
                      'type': 'function',
                      'function': <String, dynamic>{
                        'name': 'search',
                        'arguments': '{"query": "test"}',
                      },
                    },
                  ],
                },
              },
            ],
          }),
          200,
        );
      });

      final provider = OpenRouterProvider(
        apiKey: 'test-key',
        httpClient: mockClient,
      );

      final response = await provider.chat(
        messages: <Map<String, dynamic>>[
          <String, dynamic>{'role': 'user', 'content': 'Search for test'},
        ],
      );

      expect(response.content, 'Let me search for that');
      expect(response.hasToolCalls, true);
      expect(response.toolCalls?.length, 1);
      expect(response.toolCalls![0].name, 'search');
      expect(response.toolCalls![0].id, 'call_123');
    });

    test('includes tools in request when provided', () async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['tools'], isA<List<dynamic>>());
        expect(body['tool_choice'], 'auto');

        return http.Response(
          jsonEncode(<String, dynamic>{
            'choices': [
              <String, dynamic>{
                'message': <String, dynamic>{'content': 'Response'},
              },
            ],
          }),
          200,
        );
      });

      final provider = OpenRouterProvider(
        apiKey: 'test-key',
        httpClient: mockClient,
      );

      await provider.chat(
        messages: <Map<String, dynamic>>[
          <String, dynamic>{'role': 'user', 'content': 'Test'},
        ],
        tools: <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'function',
            'function': <String, dynamic>{
              'name': 'test_tool',
              'description': 'A test tool',
            },
          },
        ],
      );
    });

    test('uses custom model when specified', () async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['model'], 'openai/gpt-4');

        return http.Response(
          jsonEncode(<String, dynamic>{
            'choices': [
              <String, dynamic>{
                'message': <String, dynamic>{'content': 'Response'},
              },
            ],
          }),
          200,
        );
      });

      final provider = OpenRouterProvider(
        apiKey: 'test-key',
        httpClient: mockClient,
      );

      await provider.chat(
        messages: <Map<String, dynamic>>[
          <String, dynamic>{'role': 'user', 'content': 'Test'},
        ],
        model: 'openai/gpt-4',
      );
    });

    test('handles HTTP errors gracefully', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final provider = OpenRouterProvider(
        apiKey: 'invalid-key',
        httpClient: mockClient,
      );

      final response = await provider.chat(
        messages: <Map<String, dynamic>>[
          <String, dynamic>{'role': 'user', 'content': 'Test'},
        ],
      );

      expect(response.content, contains('Error: 401'));
    });

    test('handles network exceptions', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Network error');
      });

      final provider = OpenRouterProvider(
        apiKey: 'test-key',
        httpClient: mockClient,
      );

      final response = await provider.chat(
        messages: <Map<String, dynamic>>[
          <String, dynamic>{'role': 'user', 'content': 'Test'},
        ],
      );

      expect(response.content, contains('Error calling OpenRouter'));
    });

    test('handles empty choices array', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, dynamic>{'choices': <Map<String, dynamic>>[]}),
          200,
        );
      });

      final provider = OpenRouterProvider(
        apiKey: 'test-key',
        httpClient: mockClient,
      );

      final response = await provider.chat(
        messages: <Map<String, dynamic>>[
          <String, dynamic>{'role': 'user', 'content': 'Test'},
        ],
      );

      expect(response.content, 'No response from model');
    });

    test('isAvailable checks API connectivity', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), contains('/models'));
        expect(request.headers['Authorization'], 'Bearer test-key');
        return http.Response('{"data": []}', 200);
      });

      final provider = OpenRouterProvider(
        apiKey: 'test-key',
        httpClient: mockClient,
      );

      final available = await provider.isAvailable();
      expect(available, true);
    });

    test('isAvailable returns false on error', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Network error');
      });

      final provider = OpenRouterProvider(
        apiKey: 'test-key',
        httpClient: mockClient,
      );

      final available = await provider.isAvailable();
      expect(available, false);
    });
  });
}
