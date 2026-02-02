import 'package:nanobot_dart/src/agent/tools/message.dart';
import 'package:test/test.dart';

void main() {
  test('MessageTool returns confirmation', () async {
    final tool = MessageTool();
    final result = await tool.execute({'content': 'Hello user'});
    expect(result, 'Message sent: Hello user');
  });
}
