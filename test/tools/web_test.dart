import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nanobot_dart/src/agent/tools/web.dart';
import 'package:test/test.dart';

void main() {
  group('WebSearchTool', () {
    test('name returns web_search', () {
      final tool = WebSearchTool(apiKey: 'dummy');
      expect(tool.name, 'web_search');
    });

    test('description is not empty', () {
      final tool = WebSearchTool(apiKey: 'dummy');
      expect(tool.description, isNotEmpty);
    });

    test('parametersSchema has required structure', () {
      final tool = WebSearchTool(apiKey: 'dummy');
      final schema = tool.parametersSchema;
      expect(schema['type'], 'object');
      expect(
        (schema['properties'] as Map<String, dynamic>)['query'],
        isNotNull,
      );
      expect(schema['required'], contains('query'));
    });

    test('execute returns stub result with query', () async {
      final tool = WebSearchTool(apiKey: 'dummy');
      final result = await tool.execute({'query': 'test query'});
      expect(result, contains('Search results for "test query"'));
      expect(result, contains('[Stub]'));
    });

    test('definition returns valid OpenAI function schema', () {
      final tool = WebSearchTool(apiKey: 'test-api-key');
      final schema = tool.definition.toJson();
      expect(schema['type'], 'function');
      expect(
        (schema['function'] as Map<String, dynamic>)['name'],
        'web_search',
      );
    });
  });

  group('WebFetchTool', () {
    test('name returns web_fetch', () {
      final tool = WebFetchTool();
      expect(tool.name, 'web_fetch');
    });

    test('description is not empty', () {
      final tool = WebFetchTool();
      expect(tool.description, isNotEmpty);
    });

    test('parametersSchema has required structure', () {
      final tool = WebFetchTool();
      final schema = tool.parametersSchema;
      expect(schema['type'], 'object');
      expect(
        (schema['properties'] as Map<String, dynamic>)['url'],
        isNotNull,
      );
      expect(schema['required'], contains('url'));
    });

    test('execute returns content on success', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Hello World', 200);
      });

      final tool = WebFetchTool(client: mockClient);
      final result = await tool.execute({'url': 'https://example.com'});
      expect(result, 'Hello World');
    });

    test('execute truncates very long content', () async {
      final longContent = 'A' * 15000;
      final mockClient = MockClient((request) async {
        return http.Response(longContent, 200);
      });

      final tool = WebFetchTool(client: mockClient);
      final result = await tool.execute({'url': 'https://example.com'});
      expect(result.length, lessThan(15000));
      expect(result, contains('...[truncated]'));
    });

    test('execute throws exception on 404', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final tool = WebFetchTool(client: mockClient);
      expect(
        () => tool.execute({'url': 'https://example.com'}),
        throwsA(isA<Exception>()),
      );
    });

    test('execute throws exception on 500', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final tool = WebFetchTool(client: mockClient);
      expect(
        () => tool.execute({'url': 'https://example.com'}),
        throwsA(isA<Exception>()),
      );
    });

    test('execute works with provided client', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), 'https://test.com/page');
        return http.Response('<html>Test</html>', 200);
      });

      final tool = WebFetchTool(client: mockClient);
      final result = await tool.execute({'url': 'https://test.com/page'});
      expect(result, '<html>Test</html>');
    });

    test('definition returns valid OpenAI function schema', () {
      final tool = WebFetchTool();
      final schema = tool.definition.toJson();
      expect(schema['type'], 'function');
      expect((schema['function'] as Map<String, dynamic>)['name'], 'web_fetch');
    });

    test('execute handles HTML response', () async {
      const html = '''
<!DOCTYPE html>
<html>
<head><title>Test</title></head>
<body><h1>Hello</h1></body>
</html>''';

      final mockClient = MockClient((request) async {
        return http.Response(html, 200);
      });

      final tool = WebFetchTool(client: mockClient);
      final result = await tool.execute({'url': 'https://example.com'});
      expect(result, contains('<h1>Hello</h1>'));
    });
  });
}
