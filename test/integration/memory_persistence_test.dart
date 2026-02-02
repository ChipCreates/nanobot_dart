import 'dart:io';

import 'package:nanobot_dart/nanobot_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Memory Persistence', () {
    late Directory tempDir;
    late MemoryStore memory;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('nanobot_memory_');
      memory = MemoryStore(workspacePath: tempDir.path);
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('Writes and reads daily memory', () async {
      await memory.appendToday('Worked on integration tests.');

      // Verify file created
      final file = File(memory.todayPath);
      expect(file.existsSync(), isTrue);

      final content = await memory.readToday();
      expect(content, contains('Worked on integration tests.'));
    });

    test('Persists long-term memory', () async {
      const coreInfo = 'My name is NanoBot.';
      await memory.writeLongTerm(coreInfo);

      final readBack = await memory.readLongTerm();
      expect(readBack, coreInfo);

      // Verify context builder includes it
      final context = await memory.buildContext();
      expect(context, contains(coreInfo));
      expect(context, contains('## Long-term Memory'));
    });
  });
}
