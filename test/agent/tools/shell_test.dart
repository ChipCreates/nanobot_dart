import 'package:nanobot_dart/src/agent/tools/shell.dart';
import 'package:test/test.dart';

void main() {
  group('ExecTool', () {
    late ExecTool tool;

    setUp(() {
      tool = ExecTool();
    });

    test('executes a simple command', () async {
      final result = await tool.execute({'command': 'echo "hello"'});
      expect(result.trim(), equals('hello'));
    });

    test('handles stderr', () async {
      final result = await tool.execute({'command': 'echo "error" >&2'});
      expect(result, contains('STDERR:'));
      expect(result, contains('error'));
    });

    test('handles exit codes', () async {
      final result = await tool.execute({'command': 'exit 1'});
      expect(result, contains('Exit code: 1'));
    });

    test('handles timeouts', () async {
      final slowTool = ExecTool(timeout: const Duration(milliseconds: 100));
      final result = await slowTool.execute({'command': 'sleep 1'});
      expect(result, contains('Error: Command timed out'));
    });

    test('truncates long output', () async {
      final result = await tool
          .execute({'command': r'head -c 11000 /dev/zero | tr "\0" "a"'});
      expect(result.length, greaterThan(10000));
      expect(result, contains('truncated'));
    });
  });
}
