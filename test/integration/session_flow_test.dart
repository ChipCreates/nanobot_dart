import 'dart:io';

import 'package:nanobot_dart/nanobot_dart.dart';
import 'package:nanobot_dart/src/session/session.dart';
import 'package:test/test.dart';

void main() {
  group('Session Flow', () {
    late Directory tempDir;
    late SessionManager sessions;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('nanobot_session_');
      sessions = SessionManager(workspacePath: tempDir.path);
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('Creates and persists session', () async {
      final session = await sessions.getOrCreate('channel:chat-1');
      session.addMessage(
        SessionMessage(
          role: 'user',
          content: 'Hello',
          timestamp: DateTime.now(),
        ),
      );
      await sessions.save(session);

      // Verify persistence
      final loaded = await sessions.getOrCreate('channel:chat-1');
      expect(loaded.messages, hasLength(1));
      expect(
        loaded.messages.first.content,
        'Hello',
      );
    });

    test('Deletes session', () async {
      final session = await sessions.getOrCreate('channel:chat-2');
      session.addMessage(
        SessionMessage(
          role: 'user',
          content: 'Hi',
          timestamp: DateTime.now(),
        ),
      );
      await sessions.save(
        session,
      );

      await sessions.delete(
        'channel:chat-2',
      );

      // Should be empty (new session)
      final reloaded = await sessions.getOrCreate('channel:chat-2');
      expect(reloaded.messages, isEmpty);
    });

    test('Lists sessions', () async {
      await sessions.save(await sessions.getOrCreate('s1'));
      await sessions.save(await sessions.getOrCreate('s2'));

      final list = await sessions.listSessions();
      expect(list, containsAll(['s1', 's2']));
    });
  });
}
