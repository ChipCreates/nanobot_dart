// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'types.freezed.dart';
part 'types.g.dart';

/// Schedule definition for a cron job.
@freezed
class CronSchedule with _$CronSchedule {
  const factory CronSchedule({
    /// Kind of schedule: 'at', 'every', 'cron'.
    required String kind,

    /// For "at": timestamp in ms.
    @JsonKey(name: 'atMs') int? atMs,

    /// For "every": interval in ms.
    @JsonKey(name: 'everyMs') int? everyMs,

    /// For "cron": cron expression (e.g. "0 9 * * *").
    String? expr,

    /// Timezone for cron expressions.
    String? tz,
  }) = _CronSchedule;

  factory CronSchedule.fromJson(Map<String, dynamic> json) =>
      _$CronScheduleFromJson(json);
}

/// What to do when the job runs.
@freezed
class CronPayload with _$CronPayload {
  const factory CronPayload({
    /// Kind of payload: 'system_event', 'agent_turn'.
    @Default('agent_turn') String kind,

    /// Message specific content.
    @Default('') String message,

    /// Deliver response to channel.
    @Default(false) bool deliver,

    /// Channel name (e.g. "whatsapp").
    String? channel,

    /// Recipient address (e.g. phone number).
    String? to,
  }) = _CronPayload;

  factory CronPayload.fromJson(Map<String, dynamic> json) =>
      _$CronPayloadFromJson(json);
}

/// Runtime state of a job.
@freezed
class CronJobState with _$CronJobState {
  const factory CronJobState({
    @JsonKey(name: 'nextRunAtMs') int? nextRunAtMs,
    @JsonKey(name: 'lastRunAtMs') int? lastRunAtMs,
    @JsonKey(name: 'lastStatus') String? lastStatus,
    @JsonKey(name: 'lastError') String? lastError,
  }) = _CronJobState;

  factory CronJobState.fromJson(Map<String, dynamic> json) =>
      _$CronJobStateFromJson(json);
}

/// A scheduled job.
@freezed
class CronJob with _$CronJob {
  const factory CronJob({
    required String id,
    required String name,
    required CronSchedule schedule,
    @JsonKey(name: 'createdAtMs') required int createdAtMs,
    @JsonKey(name: 'updatedAtMs') required int updatedAtMs,
    @Default(CronPayload()) CronPayload payload,
    @Default(CronJobState()) CronJobState state,
    @Default(true) bool enabled,
    @JsonKey(name: 'deleteAfterRun') @Default(false) bool deleteAfterRun,
  }) = _CronJob;

  factory CronJob.fromJson(Map<String, dynamic> json) =>
      _$CronJobFromJson(json);
}

/// Persistent store for cron jobs.
@freezed
class CronStore with _$CronStore {
  const factory CronStore({
    @Default(1) int version,
    @Default([]) List<CronJob> jobs,
  }) = _CronStore;

  factory CronStore.fromJson(Map<String, dynamic> json) =>
      _$CronStoreFromJson(json);
}
