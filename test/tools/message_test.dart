import 'package:nanobot_dart/src/agent/tools/message.dart';
import 'package:test/test.dart';

void main() {
  group('MessageTool', () {
    late MessageTool tool;

    setUp(() {
      tool = MessageTool();
    });

    test('name returns message', () {
      expect(tool.name, 'message');
    });

    test('description is not empty', () {
      expect(tool.description, isNotEmpty);
    });

    test('parametersSchema has required structure', () {
      final schema = tool.parametersSchema;
      expect(schema['type'], 'object');
      expect(schema['properties'], isNotNull);
      expect(
        (schema['properties'] as Map<String, dynamic>)['content'],
        isNotNull,
      );
      expect(schema['required'], contains('content'));
    });

    test('execute returns confirmation with content', () async {
      final result = await tool.execute({'content': 'Hello user'});
      expect(result, 'Message sent: Hello user');
    });

    test('execute handles long content', () async {
      final longContent = 'A' * 1000;
      final result = await tool.execute({'content': longContent});
      expect(result, contains('Message sent:'));
      expect(result, contains(longContent));
    });

    test('execute handles empty content', () async {
      final result = await tool.execute({'content': ''});
      expect(result, 'Message sent: ');
    });

    test('execute handles special characters', () async {
      final result = await tool.execute({
        'content': 'Hello! <script>alert("xss")</script>',
      });
      expect(result, contains('Hello!'));
    });

    test('definition returns valid OpenAI function schema', () {
      final schema = tool.definition.toJson();
      expect(schema['type'], 'function');
      final fn = schema['function'] as Map<String, dynamic>;
      expect(fn['name'], 'message');
      expect(fn['description'], isNotEmpty);
      expect(fn['parameters'], isNotNull);
    });
  });
}
