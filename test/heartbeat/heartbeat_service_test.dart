import 'dart:io';

import 'package:nanobot_dart/src/heartbeat/service.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('heartbeat_test_');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  group('HeartbeatService', () {
    test('does not start when disabled', () {
      HeartbeatService(
        workspacePath: tempDir.path,
        enabled: false,
      )
        ..start()
        ..stop();
    });

    test('starts and stops correctly', () {
      HeartbeatService(
        workspacePath: tempDir.path,
        interval: const Duration(hours: 1),
      )
        ..start()
        ..stop();
      expect(true, isTrue);
    });

    test('heartbeatFile returns correct path', () {
      final service = HeartbeatService(
        workspacePath: tempDir.path,
      );

      expect(service.heartbeatFile.path, endsWith('HEARTBEAT.md'));
    });

    test('triggerNow returns null when no callback', () async {
      final service = HeartbeatService(
        workspacePath: tempDir.path,
      );

      final result = await service.triggerNow();
      expect(result, isNull);
    });

    test('triggerNow calls callback', () async {
      String? receivedPrompt;

      final service = HeartbeatService(
        workspacePath: tempDir.path,
        onHeartbeat: (prompt) async {
          receivedPrompt = prompt;
          return 'HEARTBEAT_OK';
        },
      );

      final result = await service.triggerNow();
      expect(result, 'HEARTBEAT_OK');
      expect(receivedPrompt, contains('HEARTBEAT.md'));
    });

    test('detects empty heartbeat file', () async {
      // Create empty HEARTBEAT.md
      final heartbeatFile = File('${tempDir.path}/HEARTBEAT.md');
      await heartbeatFile.writeAsString('');

      var callbackCalled = false;

      final service = HeartbeatService(
        workspacePath: tempDir.path,
        interval: const Duration(milliseconds: 50),
        onHeartbeat: (prompt) async {
          callbackCalled = true;
          return 'Done';
        },
      )..start();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      service.stop();

      // Empty file should not trigger callback
      expect(callbackCalled, isFalse);
    });

    test('detects actionable content in heartbeat file', () async {
      // Create HEARTBEAT.md with actionable content
      final heartbeatFile = File('${tempDir.path}/HEARTBEAT.md');
      await heartbeatFile.writeAsString('# Tasks\n- Do something important');

      var callbackCalled = false;

      final service = HeartbeatService(
        workspacePath: tempDir.path,
        interval: const Duration(milliseconds: 50),
        onHeartbeat: (prompt) async {
          callbackCalled = true;
          return 'Done';
        },
      )..start();

      await Future<void>.delayed(const Duration(milliseconds: 100));
      service.stop();

      expect(callbackCalled, isTrue);
    });

    test('treats headers-only as empty', () async {
      final heartbeatFile = File('${tempDir.path}/HEARTBEAT.md');
      await heartbeatFile.writeAsString('# Header Only\n## Another Header');

      var callbackCalled = false;

      final service = HeartbeatService(
        workspacePath: tempDir.path,
        interval: const Duration(milliseconds: 50),
        onHeartbeat: (prompt) async {
          callbackCalled = true;
          return 'Done';
        },
      )..start();

      await Future<void>.delayed(const Duration(milliseconds: 100));
      service.stop();

      expect(callbackCalled, isFalse);
    });

    test('treats checkboxes-only as empty', () async {
      final heartbeatFile = File('${tempDir.path}/HEARTBEAT.md');
      await heartbeatFile.writeAsString('- [ ]\n- [x]\n* [ ]');

      var callbackCalled = false;

      final service = HeartbeatService(
        workspacePath: tempDir.path,
        interval: const Duration(milliseconds: 50),
        onHeartbeat: (prompt) async {
          callbackCalled = true;
          return 'Done';
        },
      )..start();

      await Future<void>.delayed(const Duration(milliseconds: 100));
      service.stop();

      expect(callbackCalled, isFalse);
    });

    test('handles missing heartbeat file', () async {
      var callbackCalled = false;

      final service = HeartbeatService(
        workspacePath: tempDir.path,
        interval: const Duration(milliseconds: 50),
        onHeartbeat: (prompt) async {
          callbackCalled = true;
          return 'Done';
        },
      )..start();

      await Future<void>.delayed(const Duration(milliseconds: 100));
      service.stop();

      // No file = no callback
      expect(callbackCalled, isFalse);
    });

    test('does not start twice', () {
      HeartbeatService(
        workspacePath: tempDir.path,
        interval: const Duration(hours: 1),
      )
        ..start()
        ..start()
        ..stop();
      expect(true, isTrue);
    });
  });
}
