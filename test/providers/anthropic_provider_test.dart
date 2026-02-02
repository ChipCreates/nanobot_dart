import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nanobot_dart/src/providers/anthropic_provider.dart';
import 'package:test/test.dart';

void main() {
  group('AnthropicProvider', () {
    test('name returns anthropic', () {
      final provider = AnthropicProvider(apiKey: 'test-key');
      expect(provider.name, 'anthropic');
    });

    test('isAvailable returns true with non-empty key', () async {
      final provider = AnthropicProvider(apiKey: 'test-key');
      expect(await provider.isAvailable(), isTrue);
    });

    test('isAvailable returns false with empty key', () async {
      final provider = AnthropicProvider(apiKey: '');
      expect(await provider.isAvailable(), isFalse);
    });

    test('chat returns text response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/messages'));
        expect(request.headers['x-api-key'], 'test-key');
        expect(request.headers['anthropic-version'], '2023-06-01');

        return http.Response(
          jsonEncode(<String, dynamic>{
            'content': [
              {'type': 'text', 'text': 'Hello from Claude!'},
            ],
          }),
          200,
        );
      });

      final provider = AnthropicProvider(
        apiKey: 'test-key',
        httpClient: mockClient,
      );

      final response = await provider.chat(
        messages: [
          {'role': 'user', 'content': 'Hi'},
        ],
      );

      expect(response.content, 'Hello from Claude!');
      expect(response.toolCalls, isNull);
    });

    test('chat handles tool use response', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, dynamic>{
            'content': [
              {'type': 'text', 'text': 'Using a tool'},
              {
                'type': 'tool_use',
                'id': 'tool-1',
                'name': 'read_file',
                'input': {'path': 'test.txt'},
              },
            ],
          }),
          200,
        );
      });

      final provider = AnthropicProvider(
        apiKey: 'test-key',
        httpClient: mockClient,
      );

      final response = await provider.chat(
        messages: [
          {'role': 'user', 'content': 'Read test.txt'},
        ],
      );

      expect(response.content, 'Using a tool');
      expect(response.toolCalls, isNotNull);
      expect(response.toolCalls!.length, 1);
      expect(response.toolCalls![0].name, 'read_file');
      expect(response.toolCalls![0].id, 'tool-1');
      expect(
        (response.toolCalls![0].arguments as Map<String, dynamic>)['path'],
        'test.txt',
      );
    });

    test('chat includes tools in request', () async {
      var requestChecked = false;

      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['tools'], isNotNull);
        requestChecked = true;

        return http.Response(
          jsonEncode(<String, dynamic>{
            'content': [
              {'type': 'text', 'text': 'OK'},
            ],
          }),
          200,
        );
      });

      final provider = AnthropicProvider(
        apiKey: 'test-key',
        httpClient: mockClient,
      );

      await provider.chat(
        messages: <Map<String, dynamic>>[
          <String, dynamic>{'role': 'user', 'content': 'test'},
        ],
        tools: <Map<String, dynamic>>[
          <String, dynamic>{
            'name': 'test_tool',
            'description': 'A test tool',
            'input_schema': <String, dynamic>{
              'type': 'object',
              'properties': <String, dynamic>{},
            },
          },
        ],
      );

      expect(requestChecked, isTrue);
    });

    test('chat handles HTTP error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final provider = AnthropicProvider(
        apiKey: 'bad-key',
        httpClient: mockClient,
      );

      final response = await provider.chat(
        messages: [
          {'role': 'user', 'content': 'Hi'},
        ],
      );

      expect(response.content, contains('Error: 401'));
    });

    test('chat handles network exception', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Network error');
      });

      final provider = AnthropicProvider(
        apiKey: 'test-key',
        httpClient: mockClient,
      );

      final response = await provider.chat(
        messages: [
          {'role': 'user', 'content': 'Hi'},
        ],
      );

      expect(response.content, contains('Error calling Anthropic'));
    });

    test('uses custom model', () async {
      String? requestedModel;

      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        requestedModel = body['model'] as String;

        return http.Response(
          jsonEncode(<String, dynamic>{
            'content': [
              {'type': 'text', 'text': 'OK'},
            ],
          }),
          200,
        );
      });

      final provider = AnthropicProvider(
        apiKey: 'test-key',
        httpClient: mockClient,
      );

      await provider.chat(
        messages: [
          {'role': 'user', 'content': 'Hi'},
        ],
        model: 'claude-3-opus-20240229',
      );

      expect(requestedModel, 'claude-3-opus-20240229');
    });
  });
}
