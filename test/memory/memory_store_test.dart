import 'dart:io';

import 'package:nanobot_dart/src/agent/memory/memory_store.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('MemoryStore', () {
    late Directory tempDir;
    late MemoryStore store;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('memory_test_');
      store = MemoryStore(workspacePath: tempDir.path);
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('appends to today"s memory file', () async {
      await store.appendToday('First memory');
      await store.appendToday('Second memory');

      final content = await store.readToday();

      expect(content, isNotNull);
      expect(content, contains('First memory'));
      expect(content, contains('Second memory'));
    });

    test('creates memory directory if it doesn"t exist', () async {
      final memoryDir =
          Directory(path.join(tempDir.path, '.nanobot', 'memory'));
      expect(memoryDir.existsSync(), false);

      await store.appendToday('Test memory');

      expect(memoryDir.existsSync(), true);
    });

    test('returns null when reading non-existent today file', () async {
      final content = await store.readToday();
      expect(content, isNull);
    });

    test('writes and reads long-term memory', () async {
      const longTermContent = '''
# Important Facts

- User prefers concise answers
- Working on Dart project
''';

      await store.writeLongTerm(longTermContent);
      final content = await store.readLongTerm();

      expect(content, longTermContent);
    });

    test('returns null when reading non-existent long-term memory', () async {
      final content = await store.readLongTerm();
      expect(content, isNull);
    });

    test('overwrites long-term memory on write', () async {
      await store.writeLongTerm('First version');
      await store.writeLongTerm('Second version');

      final content = await store.readLongTerm();
      expect(content, 'Second version');
      expect(content, isNot(contains('First version')));
    });

    test('gets recent memories from last N days', () async {
      // Create memory files for the last 3 days
      final memoryDir =
          Directory(path.join(tempDir.path, '.nanobot', 'memory'));
      await memoryDir.create(recursive: true);

      final now = DateTime.now();
      for (var i = 0; i < 3; i++) {
        final date = now.subtract(Duration(days: i));
        final dateStr =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final file = File(path.join(memoryDir.path, '$dateStr.md'));
        await file.writeAsString('Memory from day $i');
      }

      final memories = await store.getRecentMemories(days: 3);

      expect(memories.length, 3);
      expect(memories[0], contains('Memory from day 0'));
      expect(memories[1], contains('Memory from day 1'));
      expect(memories[2], contains('Memory from day 2'));
    });

    test('returns empty list when no recent memories exist', () async {
      final memories = await store.getRecentMemories();
      expect(memories, isEmpty);
    });

    test('builds context from long-term and recent memories', () async {
      await store.writeLongTerm('Important long-term fact');
      await store.appendToday("Today's note");

      final context = await store.buildContext(recentDays: 1);

      expect(context, contains('Long-term Memory'));
      expect(context, contains('Important long-term fact'));
      expect(context, contains('Recent Notes'));
      expect(context, contains("Today's note"));
    });

    test('builds context with only long-term memory', () async {
      await store.writeLongTerm('Only long-term');

      final context = await store.buildContext(recentDays: 1);

      expect(context, contains('Long-term Memory'));
      expect(context, contains('Only long-term'));
      expect(context, isNot(contains('Recent Notes')));
    });

    test('builds empty context when no memories exist', () async {
      final context = await store.buildContext();
      expect(context, isEmpty);
    });

    test('today path uses correct date format', () {
      final todayPath = store.todayPath;
      final now = DateTime.now();
      final expectedDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      expect(todayPath, contains(expectedDate));
      expect(todayPath, endsWith('.md'));
    });

    test('appends with timestamp headers', () async {
      await store.appendToday('Test memory');

      final content = await store.readToday();

      expect(content, contains('##'));
      expect(content, contains('T')); // ISO8601 timestamp contains 'T'
    });

    test('handles multiple recent days correctly', () async {
      final memoryDir =
          Directory(path.join(tempDir.path, '.nanobot', 'memory'));
      await memoryDir.create(recursive: true);

      // Create 10 days of memories
      final now = DateTime.now();
      for (var i = 0; i < 10; i++) {
        final date = now.subtract(Duration(days: i));
        final dateStr =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final file = File(path.join(memoryDir.path, '$dateStr.md'));
        await file.writeAsString('Day $i');
      }

      final memories = await store.getRecentMemories(days: 5);

      expect(memories.length, 5);
      expect(memories[0], contains('Day 0'));
      expect(memories[4], contains('Day 4'));
    });
  });
}
