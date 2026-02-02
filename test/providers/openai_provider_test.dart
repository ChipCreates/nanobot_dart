import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nanobot_dart/src/providers/openai_provider.dart';
import 'package:test/test.dart';

void main() {
  group('OpenAIProvider', () {
    test('name returns openai', () {
      final provider = OpenAIProvider(apiKey: 'test-key');
      expect(provider.name, 'openai');
    });

    test('isAvailable returns true on 200 response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/models'));
        return http.Response('{"data": []}', 200);
      });

      final provider = OpenAIProvider(
        apiKey: 'test-key',
        httpClient: mockClient,
      );

      expect(await provider.isAvailable(), isTrue);
    });

    test('isAvailable returns false on error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final provider = OpenAIProvider(
        apiKey: 'bad-key',
        httpClient: mockClient,
      );

      expect(await provider.isAvailable(), isFalse);
    });

    test('isAvailable returns false on exception', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Network error');
      });

      final provider = OpenAIProvider(
        apiKey: 'test-key',
        httpClient: mockClient,
      );

      expect(await provider.isAvailable(), isFalse);
    });

    test('chat returns text response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/chat/completions'));
        expect(request.headers['Authorization'], 'Bearer test-key');

        return http.Response(
          jsonEncode(<String, dynamic>{
            'choices': [
              {
                'message': {
                  'content': 'Hello from GPT!',
                },
              },
            ],
          }),
          200,
        );
      });

      final provider = OpenAIProvider(
        apiKey: 'test-key',
        httpClient: mockClient,
      );

      final response = await provider.chat(
        messages: [
          {'role': 'user', 'content': 'Hi'},
        ],
      );

      expect(response.content, 'Hello from GPT!');
      expect(response.toolCalls, isNull);
    });

    test('chat handles tool call response', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, dynamic>{
            'choices': [
              {
                'message': {
                  'content': null,
                  'tool_calls': [
                    {
                      'id': 'call-1',
                      'type': 'function',
                      'function': {
                        'name': 'read_file',
                        'arguments': '{"path": "test.txt"}',
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

      final provider = OpenAIProvider(
        apiKey: 'test-key',
        httpClient: mockClient,
      );

      final response = await provider.chat(
        messages: [
          {'role': 'user', 'content': 'Read test.txt'},
        ],
      );

      expect(response.toolCalls, isNotNull);
      expect(response.toolCalls!.length, 1);
      expect(response.toolCalls![0].name, 'read_file');
      expect(response.toolCalls![0].id, 'call-1');
    });

    test('chat includes tools and tool_choice in request', () async {
      var requestChecked = false;

      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['tools'], isNotNull);
        expect(body['tool_choice'], 'auto');
        requestChecked = true;

        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {'content': 'OK'},
              },
            ],
          }),
          200,
        );
      });

      final provider = OpenAIProvider(
        apiKey: 'test-key',
        httpClient: mockClient,
      );

      await provider.chat(
        messages: <Map<String, dynamic>>[
          <String, dynamic>{'role': 'user', 'content': 'test'},
        ],
        tools: <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'function',
            'function': {
              'name': 'test_tool',
              'description': 'A test tool',
              'parameters': <String, dynamic>{
                'type': 'object',
                'properties': <String, dynamic>{},
              },
            },
          },
        ],
      );

      expect(requestChecked, isTrue);
    });

    test('chat handles HTTP error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Rate limited', 429);
      });

      final provider = OpenAIProvider(
        apiKey: 'test-key',
        httpClient: mockClient,
      );

      final response = await provider.chat(
        messages: [
          {'role': 'user', 'content': 'Hi'},
        ],
      );

      expect(response.content, contains('Error: 429'));
    });

    test('chat handles empty choices', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, dynamic>{'choices': <dynamic>[]}),
          200,
        );
      });

      final provider = OpenAIProvider(
        apiKey: 'test-key',
        httpClient: mockClient,
      );

      final response = await provider.chat(
        messages: [
          {'role': 'user', 'content': 'Hi'},
        ],
      );

      expect(response.content, 'No response from model');
    });

    test('chat handles network exception', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Network error');
      });

      final provider = OpenAIProvider(
        apiKey: 'test-key',
        httpClient: mockClient,
      );

      final response = await provider.chat(
        messages: [
          {'role': 'user', 'content': 'Hi'},
        ],
      );

      expect(response.content, contains('Error calling OpenAI'));
    });

    test('uses custom model', () async {
      String? requestedModel;

      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        requestedModel = body['model'] as String;

        return http.Response(
          jsonEncode(<String, dynamic>{
            'choices': [
              {
                'message': {'content': 'OK'},
              },
            ],
          }),
          200,
        );
      });

      final provider = OpenAIProvider(
        apiKey: 'test-key',
        httpClient: mockClient,
      );

      await provider.chat(
        messages: [
          {'role': 'user', 'content': 'Hi'},
        ],
        model: 'gpt-4-turbo',
      );

      expect(requestedModel, 'gpt-4-turbo');
    });

    test('uses default model when not specified', () async {
      String? requestedModel;

      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        requestedModel = body['model'] as String;

        return http.Response(
          jsonEncode(<String, dynamic>{
            'choices': [
              {
                'message': {'content': 'OK'},
              },
            ],
          }),
          200,
        );
      });

      final provider = OpenAIProvider(
        apiKey: 'test-key',
        httpClient: mockClient,
      );

      await provider.chat(
        messages: [
          {'role': 'user', 'content': 'Hi'},
        ],
      );

      expect(requestedModel, 'gpt-4o');
    });
  });
}
