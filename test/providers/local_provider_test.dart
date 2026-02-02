import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nanobot_dart/src/providers/local_provider.dart';
import 'package:test/test.dart';

void main() {
  group('LocalLlmProvider', () {
    test('sends chat completion request with correct format', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), contains('/api/chat'));
        expect(request.headers['Content-Type'], 'application/json');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['model'], 'llama3.1');
        expect(body['messages'], isA<List<dynamic>>());
        expect(body['stream'], false);

        return http.Response(
          jsonEncode(<String, dynamic>{
            'message': <String, dynamic>{
              'role': 'assistant',
              'content': 'Hello! How can I help you?',
            },
          }),
          200,
        );
      });

      final provider = LocalLlmProvider(
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
            'message': <String, dynamic>{
              'role': 'assistant',
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
          }),
          200,
        );
      });

      final provider = LocalLlmProvider(
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

        return http.Response(
          jsonEncode(<String, dynamic>{
            'message': <String, dynamic>{
              'role': 'assistant',
              'content': 'Response',
            },
          }),
          200,
        );
      });

      final provider = LocalLlmProvider(
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
        expect(body['model'], 'mistral');

        return http.Response(
          jsonEncode(<String, dynamic>{
            'message': <String, dynamic>{
              'role': 'assistant',
              'content': 'Response',
            },
          }),
          200,
        );
      });

      final provider = LocalLlmProvider(
        httpClient: mockClient,
      );

      await provider.chat(
        messages: <Map<String, dynamic>>[
          <String, dynamic>{'role': 'user', 'content': 'Test'},
        ],
        model: 'mistral',
      );
    });

    test('handles HTTP errors gracefully', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final provider = LocalLlmProvider(
        httpClient: mockClient,
      );

      final response = await provider.chat(
        messages: <Map<String, dynamic>>[
          <String, dynamic>{'role': 'user', 'content': 'Test'},
        ],
      );

      expect(response.content, contains('Error: 500'));
    });

    test('handles network exceptions', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Network error');
      });

      final provider = LocalLlmProvider(
        httpClient: mockClient,
      );

      final response = await provider.chat(
        messages: <Map<String, dynamic>>[
          <String, dynamic>{'role': 'user', 'content': 'Test'},
        ],
      );

      expect(response.content, contains('Error calling Ollama'));
    });

    test('handles empty response', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, dynamic>{}),
          200,
        );
      });

      final provider = LocalLlmProvider(
        httpClient: mockClient,
      );

      final response = await provider.chat(
        messages: <Map<String, dynamic>>[
          <String, dynamic>{'role': 'user', 'content': 'Test'},
        ],
      );

      expect(response.content, 'No response from model');
    });

    test('isAvailable checks Ollama connectivity', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), contains('/api/tags'));
        return http.Response('{"models": []}', 200);
      });

      final provider = LocalLlmProvider(
        httpClient: mockClient,
      );

      final available = await provider.isAvailable();
      expect(available, true);
    });

    test('isAvailable returns false when Ollama is not running', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Connection refused');
      });

      final provider = LocalLlmProvider(
        httpClient: mockClient,
      );

      final available = await provider.isAvailable();
      expect(available, false);
    });

    test('uses custom baseUrl', () async {
      final mockClient = MockClient((request) async {
        expect(
          request.url.toString(),
          startsWith('http://192.168.1.100:11434'),
        );

        return http.Response(
          jsonEncode(<String, dynamic>{
            'message': <String, dynamic>{
              'role': 'assistant',
              'content': 'Response',
            },
          }),
          200,
        );
      });

      final provider = LocalLlmProvider(
        baseUrl: 'http://192.168.1.100:11434',
        httpClient: mockClient,
      );

      await provider.chat(
        messages: <Map<String, dynamic>>[
          <String, dynamic>{'role': 'user', 'content': 'Test'},
        ],
      );
    });

    test('name returns local', () {
      final provider = LocalLlmProvider();
      expect(provider.name, 'local');
    });
  });
}
