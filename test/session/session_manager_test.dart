import 'dart:io';

import 'package:nanobot_dart/src/session/session.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('SessionManager', () {
    late Directory tempDir;
    late SessionManager manager;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('session_test_');
      manager = SessionManager(workspacePath: tempDir.path);
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('creates new session when not exists', () async {
      final session = await manager.getOrCreate('test:123');

      expect(session.key, 'test:123');
      expect(session.messages, isEmpty);
    });

    test('retrieves existing session from cache', () async {
      final session1 = await manager.getOrCreate('test:123');
      session1.addMessage(
        SessionMessage(
          role: 'user',
          content: 'Hello',
          timestamp: DateTime.now(),
        ),
      );

      final session2 = await manager.getOrCreate('test:123');

      expect(session2.messages.length, 1);
      expect(session2.messages[0].content, 'Hello');
    });

    test('persists session to JSONL file', () async {
      final session = await manager.getOrCreate('test:123');
      session.addMessage(
        SessionMessage(
          role: 'user',
          content: 'Test message',
          timestamp: DateTime.now(),
        ),
      );

      await manager.save(session);

      final sessionFile = File(
        path.join(
          tempDir.path,
          '.nanobot',
          'sessions',
          'test_123.jsonl',
        ),
      );

      expect(sessionFile.existsSync(), true);
      final content = await sessionFile.readAsString();
      expect(content, contains('Test message'));
    });

    test('loads session from disk', () async {
      final session = await manager.getOrCreate('test:123');
      session.addMessage(
        SessionMessage(
          role: 'user',
          content: 'Persisted message',
          timestamp: DateTime.now(),
        ),
      );
      await manager.save(session);

      // Create new manager to force disk load
      final newManager = SessionManager(workspacePath: tempDir.path);
      final loaded = await newManager.getOrCreate('test:123');

      expect(loaded.messages.length, 1);
      expect(loaded.messages[0].content, 'Persisted message');
    });

    test('enforces max history limit', () async {
      final session = await manager.getOrCreate('test:123');

      // Add 60 messages (max is 50)
      for (var i = 0; i < 60; i++) {
        session.addMessage(
          SessionMessage(
            role: 'user',
            content: 'Message $i',
            timestamp: DateTime.now(),
          ),
        );
      }

      await manager.save(session);

      expect(session.messages.length, 50);
      expect(session.messages[0].content, 'Message 10'); // First 10 trimmed
      expect(session.messages.last.content, 'Message 59');
    });

    test('deletes session', () async {
      final session = await manager.getOrCreate('test:123');
      session.addMessage(
        SessionMessage(
          role: 'user',
          content: 'To be deleted',
          timestamp: DateTime.now(),
        ),
      );
      await manager.save(session);

      await manager.delete('test:123');

      final sessionFile = File(
        path.join(
          tempDir.path,
          '.nanobot',
          'sessions',
          'test_123.jsonl',
        ),
      );

      expect(sessionFile.existsSync(), false);
    });

    test('lists all sessions', () async {
      await manager.getOrCreate('test:123');
      await manager.getOrCreate('test:456');
      await manager.save(await manager.getOrCreate('test:123'));
      await manager.save(await manager.getOrCreate('test:456'));

      final sessions = await manager.listSessions();

      expect(sessions.length, 2);
      expect(sessions, contains('test_123'));
      expect(sessions, contains('test_456'));
    });

    test('sanitizes session keys for filesystem', () async {
      final session = await manager.getOrCreate('channel:chat/id');
      await manager.save(session);

      final sessionFile = File(
        path.join(
          tempDir.path,
          '.nanobot',
          'sessions',
          'channel_chat_id.jsonl',
        ),
      );

      expect(sessionFile.existsSync(), true);
    });

    test('handles empty session list', () async {
      final sessions = await manager.listSessions();
      expect(sessions, isEmpty);
    });

    test('preserves message timestamps', () async {
      final timestamp = DateTime(2024, 1, 15, 10, 30);
      final session = await manager.getOrCreate('test:123');
      session.addMessage(
        SessionMessage(
          role: 'user',
          content: 'Test',
          timestamp: timestamp,
        ),
      );

      await manager.save(session);

      final newManager = SessionManager(workspacePath: tempDir.path);
      final loaded = await newManager.getOrCreate('test:123');

      expect(loaded.messages[0].timestamp, timestamp);
    });

    test('preserves session metadata', () async {
      final session = await manager.getOrCreate('test:123');
      session
        ..metadata['user_id'] = 'user123'
        ..metadata['channel'] = 'discord';

      await manager.save(session);

      final newManager = SessionManager(workspacePath: tempDir.path);
      final loaded = await newManager.getOrCreate('test:123');

      expect(loaded.metadata['user_id'], 'user123');
      expect(loaded.metadata['channel'], 'discord');
    });
  });

  group('Session', () {
    test('adds messages', () {
      final session = Session(key: 'test:123');
      final message = SessionMessage(
        role: 'user',
        content: 'Hello',
        timestamp: DateTime.now(),
      );

      session.addMessage(message);

      expect(session.messages.length, 1);
      expect(session.messages[0].content, 'Hello');
    });

    test('converts to and from JSON', () {
      final session = Session(key: 'test:123')
        ..addMessage(
          SessionMessage(
            role: 'user',
            content: 'Test',
            timestamp: DateTime.now(),
          ),
        );

      final json = session.toJson();
      final restored = Session.fromJson(json);

      expect(restored.key, session.key);
      expect(restored.messages.length, 1);
      expect(restored.messages[0].content, 'Test');
    });
  });

  group('SessionMessage', () {
    test('converts to and from JSON', () {
      final message = SessionMessage(
        role: 'user',
        content: 'Test message',
        timestamp: DateTime(2024, 1, 15, 10, 30),
      );

      final json = message.toJson();
      final restored = SessionMessage.fromJson(json);

      expect(restored.role, 'user');
      expect(restored.content, 'Test message');
      expect(restored.timestamp, DateTime(2024, 1, 15, 10, 30));
    });
  });
}
