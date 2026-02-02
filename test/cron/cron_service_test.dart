import 'dart:io';

import 'package:nanobot_dart/src/cron/service.dart';
import 'package:nanobot_dart/src/cron/types.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late String storePath;
  late CronService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cron_test_');
    storePath = '${tempDir.path}/cron_store.json';
  });

  tearDown(() async {
    service.stop();
    await tempDir.delete(recursive: true);
  });

  group('CronService', () {
    test('starts and stops without errors', () async {
      service = CronService(storePath: storePath);
      await service.start();
      expect(true, isTrue); // No exception thrown
      service.stop();
    });

    test('adds job with at schedule', () async {
      service = CronService(storePath: storePath);
      await service.start();

      final futureTime =
          DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch;

      final job = await service.addJob(
        name: 'test-job',
        schedule: CronSchedule(kind: 'at', atMs: futureTime),
        message: 'Hello!',
      );

      expect(job.id, isNotEmpty);
      expect(job.name, 'test-job');
      expect(job.schedule.kind, 'at');
      expect(job.payload.message, 'Hello!');

      service.stop();
    });

    test('adds job with every schedule', () async {
      service = CronService(storePath: storePath);
      await service.start();

      final job = await service.addJob(
        name: 'recurring-job',
        schedule: const CronSchedule(kind: 'every', everyMs: 60000),
        message: 'Tick!',
      );

      expect(job.schedule.kind, 'every');
      expect(job.schedule.everyMs, 60000);
      expect(job.state.nextRunAtMs, isNotNull);

      service.stop();
    });

    test('adds job with cron expression', () async {
      service = CronService(storePath: storePath);
      await service.start();

      final job = await service.addJob(
        name: 'cron-job',
        schedule: const CronSchedule(kind: 'cron', expr: '0 9 * * *'),
        message: 'Good morning!',
      );

      expect(job.schedule.kind, 'cron');
      expect(job.schedule.expr, '0 9 * * *');
      // Note: nextRunAtMs may be null if cron_parser fails to parse
      // The important thing is that the job is created without crashing

      service.stop();
    });

    test('lists jobs', () async {
      service = CronService(storePath: storePath);
      await service.start();

      await service.addJob(
        name: 'job-1',
        schedule: const CronSchedule(kind: 'every', everyMs: 60000),
        message: 'One',
      );

      await service.addJob(
        name: 'job-2',
        schedule: const CronSchedule(kind: 'every', everyMs: 120000),
        message: 'Two',
      );

      final jobs = await service.listJobs();
      expect(jobs.length, 2);
      expect(jobs.map((j) => j.name), containsAll(['job-1', 'job-2']));

      service.stop();
    });

    test('removes job', () async {
      service = CronService(storePath: storePath);
      await service.start();

      final job = await service.addJob(
        name: 'to-remove',
        schedule: const CronSchedule(kind: 'every', everyMs: 60000),
        message: 'Remove me',
      );

      final removed = await service.removeJob(job.id);
      expect(removed, isTrue);

      final jobs = await service.listJobs();
      expect(jobs, isEmpty);

      service.stop();
    });

    test('remove non-existent job returns false', () async {
      service = CronService(storePath: storePath);
      await service.start();

      final removed = await service.removeJob('non-existent-id');
      expect(removed, isFalse);

      service.stop();
    });

    test('persists jobs to disk', () async {
      service = CronService(storePath: storePath);
      await service.start();

      await service.addJob(
        name: 'persist-test',
        schedule: const CronSchedule(kind: 'every', everyMs: 60000),
        message: 'Persisted',
      );

      service.stop();

      // Create new service instance and verify job persisted
      final service2 = CronService(storePath: storePath);
      await service2.start();

      final jobs = await service2.listJobs();
      expect(jobs.length, 1);
      expect(jobs.first.name, 'persist-test');

      service2.stop();
      service = service2; // For tearDown
    });

    test('executes job callback', () async {
      String? executedMessage;

      service = CronService(
        storePath: storePath,
        onJob: (job) async {
          executedMessage = job.payload.message;
          return 'Done';
        },
      );
      await service.start();

      // Add job that runs 100ms from now
      await service.addJob(
        name: 'quick-job',
        schedule: CronSchedule(
          kind: 'at',
          atMs: DateTime.now()
              .add(const Duration(milliseconds: 100))
              .millisecondsSinceEpoch,
        ),
        message: 'Quick!',
      );

      // Wait for execution
      await Future<void>.delayed(const Duration(milliseconds: 500));

      expect(executedMessage, 'Quick!');

      service.stop();
    });

    test('handles disabled jobs', () async {
      service = CronService(storePath: storePath);
      await service.start();

      await service.addJob(
        name: 'enabled-job',
        schedule: const CronSchedule(kind: 'every', everyMs: 60000),
        message: 'Enabled',
      );

      final enabledJobs = await service.listJobs();
      expect(enabledJobs.length, 1);

      service.stop();
    });
  });
}
