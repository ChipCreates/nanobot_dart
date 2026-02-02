import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nanobot_dart/src/agent/tools/web.dart';
import 'package:test/test.dart';

void main() {
  group('WebTools', () {
    test('WebSearchTool returns stub result', () async {
      final tool = WebSearchTool(apiKey: 'dummy');
      final result = await tool.execute({'query': 'test query'});
      expect(result, contains('Search results for "test query"'));
      expect(result, contains('[Stub]'));
    });

    test('WebFetchTool returns content on success', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Hello World', 200);
      });

      final tool = WebFetchTool(client: mockClient);
      final result = await tool.execute({'url': 'https://example.com'});
      expect(result, 'Hello World');
    });

    test('WebFetchTool throws exception on failure', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final tool = WebFetchTool(client: mockClient);
      expect(
        () => tool.execute({'url': 'https://example.com'}),
        throwsA(isA<Exception>()),
      );
    });
  });
}
