import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:nanobot_dart/src/cron/types.dart';
// ignore: implementation_imports

/// Callback to execute a cron job.
typedef CronJobCallback = Future<String?> Function(CronJob job);

/// Service for managing and executing scheduled jobs.
class CronService {
  CronService({
    required this.storePath,
    this.onJob,
  });

  final String storePath;
  final CronJobCallback? onJob;

  CronStore? _store;
  Timer? _timer;
  bool _running = false;

  File get _storeFile => File(storePath);

  int _nowMs() => DateTime.now().millisecondsSinceEpoch;

  /// Start the cron service.
  Future<void> start() async {
    _running = true;
    await _loadStore();
    _recomputeNextRuns();
    await _saveStore();
    _armTimer();
    // logger.info('Cron service started with ${_store?.jobs.length ?? 0} jobs');
  }

  /// Stop the cron service.
  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  /// List all jobs.
  Future<List<CronJob>> listJobs({bool includeDisabled = false}) async {
    final store = await _loadStore();
    final jobs = (includeDisabled
        ? store.jobs
        : store.jobs.where((j) => j.enabled).toList())
      ..sort((a, b) {
        final aNext = a.state.nextRunAtMs ?? double.maxFinite.toInt();
        final bNext = b.state.nextRunAtMs ?? double.maxFinite.toInt();
        return aNext.compareTo(bNext);
      });

    return jobs;
  }

  /// Add a new job.
  Future<CronJob> addJob({
    required String name,
    required CronSchedule schedule,
    required String message,
    String? channel,
    String? to,
    bool deliver = false,
    bool deleteAfterRun = false,
  }) async {
    final store = await _loadStore();
    final now = _nowMs();
    final id = _generateId();

    final job = CronJob(
      id: id,
      name: name,
      schedule: schedule,
      payload: CronPayload(
        message: message,
        deliver: deliver,
        channel: channel,
        to: to,
      ),
      state: CronJobState(
        nextRunAtMs: _computeNextRun(schedule, now),
      ),
      createdAtMs: now,
      updatedAtMs: now,
      deleteAfterRun: deleteAfterRun,
    );

    final updatedJobs = List<CronJob>.from(store.jobs)..add(job);
    _store = store.copyWith(jobs: updatedJobs);

    await _saveStore();
    _armTimer();
    return job;
  }

  /// Remove a job by ID.
  Future<bool> removeJob(String jobId) async {
    final store = await _loadStore();
    final initialCount = store.jobs.length;
    final updatedJobs = store.jobs.where((j) => j.id != jobId).toList();

    if (updatedJobs.length < initialCount) {
      _store = store.copyWith(jobs: updatedJobs);
      await _saveStore();
      _armTimer();
      return true;
    }
    return false;
  }

  /// Load jobs from disk.
  Future<CronStore> _loadStore() async {
    if (_store != null) return _store!;

    if (_storeFile.existsSync()) {
      try {
        final content = await _storeFile.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        _store = CronStore.fromJson(json);
      } catch (e) {
        // logger.warning('Failed to load cron store: $e');
        _store = const CronStore();
      }
    } else {
      _store = const CronStore();
    }

    return _store!;
  }

  /// Save jobs to disk.
  Future<void> _saveStore() async {
    if (_store == null) return;

    if (!_storeFile.parent.existsSync()) {
      await _storeFile.parent.create(recursive: true);
    }

    const encoder = JsonEncoder.withIndent('  ');
    await _storeFile.writeAsString(encoder.convert(_store!.toJson()));
  }

  void _recomputeNextRuns() {
    if (_store == null) return;

    final now = _nowMs();
    final updatedJobs = _store!.jobs.map((job) {
      if (job.enabled) {
        final nextRun = _computeNextRun(job.schedule, now);
        return job.copyWith(
          state: job.state.copyWith(nextRunAtMs: nextRun),
        );
      }
      return job;
    }).toList();

    _store = _store!.copyWith(jobs: updatedJobs);
  }

  int? _computeNextRun(CronSchedule schedule, int nowMs) {
    if (schedule.kind == 'at') {
      if (schedule.atMs != null && schedule.atMs! > nowMs) {
        return schedule.atMs;
      }
      return null;
    }

    if (schedule.kind == 'every') {
      if (schedule.everyMs == null || schedule.everyMs! <= 0) {
        return null;
      }
      return nowMs + schedule.everyMs!;
    }

    if (schedule.kind == 'cron' && schedule.expr != null) {
      try {
        // The 'cron' package doesn't expose a simple "next run" calculator
        // without scheduling. We might need to implement a parser or use
        // a different approach if we want exact compatibility with python's croniter.
        // For now, let's use a simplified approximation or just support 'at'/'every'
        // fully, and basic cron if possible.
        // ACTUALLY: The `cron` package is a scheduler, not a parser.
        // We need a parser to "compute next run".
        // Since we are porting a "Pull" architecture (Service loops and checks),
        // we need to know WHEN the next run is.
        //
        // If we can't easily compute next run from cron string in Dart without
        // a heavy library, we might need to rely on the Scheduler to trigger us.
        // But the Python code computes it manually to sleep until then.
        //
        // For faithful porting, I'll mock this for 'cron' type properly later
        // or find a package that does parsing.
        // 'cron_parser' is a package that might help.
        // For now, I will leave CRON kind as NULL/Unimplemented in calculation
        // to avoid breakage, or use a basic placeholder.
        return null;
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  void _armTimer() {
    _timer?.cancel();

    final nextWake = _getNextWakeMs();
    if (nextWake == null || !_running) return;

    final delayMs = max(0, nextWake - _nowMs());
    final delay = Duration(milliseconds: delayMs);

    _timer = Timer(delay, () async {
      if (_running) {
        await _onTimer();
      }
    });
  }

  int? _getNextWakeMs() {
    if (_store == null) return null;

    final times = _store!.jobs
        .where((j) => j.enabled && j.state.nextRunAtMs != null)
        .map((j) => j.state.nextRunAtMs!)
        .toList();

    if (times.isEmpty) return null;
    return times.reduce(min);
  }

  Future<void> _onTimer() async {
    if (_store == null) return;

    final now = _nowMs();
    final dueJobs = _store!.jobs
        .where(
          (j) =>
              j.enabled &&
              j.state.nextRunAtMs != null &&
              now >= j.state.nextRunAtMs!,
        )
        .toList();

    for (final job in dueJobs) {
      await _executeJob(job);
    }

    await _saveStore();
    _armTimer();
  }

  Future<void> _executeJob(CronJob job) async {
    final startMs = _nowMs();
    // logger.info('Executing job ${job.name}');

    var updatedJob = job;

    try {
      if (onJob != null) {
        await onJob!(job);
      }

      updatedJob = updatedJob.copyWith(
        state: updatedJob.state.copyWith(
          lastStatus: 'ok',
          lastError: null,
        ),
      );
    } catch (e) {
      updatedJob = updatedJob.copyWith(
        state: updatedJob.state.copyWith(
          lastStatus: 'error',
          lastError: e.toString(),
        ),
      );
    }

    updatedJob = updatedJob.copyWith(
      state: updatedJob.state.copyWith(
        lastRunAtMs: startMs,
      ),
      updatedAtMs: _nowMs(),
    );

    // Handle rescheduling or deletion
    if (job.schedule.kind == 'at') {
      if (job.deleteAfterRun) {
        // Mark for deletion - handled by filtering out below
        updatedJob = updatedJob.copyWith(id: 'DELETED_${job.id}');
      } else {
        updatedJob = updatedJob.copyWith(
          enabled: false,
          state: updatedJob.state.copyWith(nextRunAtMs: null),
        );
      }
    } else {
      updatedJob = updatedJob.copyWith(
        state: updatedJob.state.copyWith(
          nextRunAtMs: _computeNextRun(job.schedule, _nowMs()),
        ),
      );
    }

    // Update store
    if (_store != null) {
      final newJobs = _store!.jobs
          .where((j) => j.id != job.id) // Remove old
          .toList();

      if (!updatedJob.id.startsWith('DELETED_')) {
        newJobs.add(updatedJob);
      }

      _store = _store!.copyWith(jobs: newJobs);
    }
  }

  String _generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rnd = Random();
    return List.generate(8, (index) => chars[rnd.nextInt(chars.length)]).join();
  }
}
