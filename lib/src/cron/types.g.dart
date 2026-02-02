// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CronScheduleImpl _$$CronScheduleImplFromJson(Map<String, dynamic> json) =>
    _$CronScheduleImpl(
      kind: json['kind'] as String,
      atMs: (json['atMs'] as num?)?.toInt(),
      everyMs: (json['everyMs'] as num?)?.toInt(),
      expr: json['expr'] as String?,
      tz: json['tz'] as String?,
    );

Map<String, dynamic> _$$CronScheduleImplToJson(_$CronScheduleImpl instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'atMs': instance.atMs,
      'everyMs': instance.everyMs,
      'expr': instance.expr,
      'tz': instance.tz,
    };

_$CronPayloadImpl _$$CronPayloadImplFromJson(Map<String, dynamic> json) =>
    _$CronPayloadImpl(
      kind: json['kind'] as String? ?? 'agent_turn',
      message: json['message'] as String? ?? '',
      deliver: json['deliver'] as bool? ?? false,
      channel: json['channel'] as String?,
      to: json['to'] as String?,
    );

Map<String, dynamic> _$$CronPayloadImplToJson(_$CronPayloadImpl instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'message': instance.message,
      'deliver': instance.deliver,
      'channel': instance.channel,
      'to': instance.to,
    };

_$CronJobStateImpl _$$CronJobStateImplFromJson(Map<String, dynamic> json) =>
    _$CronJobStateImpl(
      nextRunAtMs: (json['nextRunAtMs'] as num?)?.toInt(),
      lastRunAtMs: (json['lastRunAtMs'] as num?)?.toInt(),
      lastStatus: json['lastStatus'] as String?,
      lastError: json['lastError'] as String?,
    );

Map<String, dynamic> _$$CronJobStateImplToJson(_$CronJobStateImpl instance) =>
    <String, dynamic>{
      'nextRunAtMs': instance.nextRunAtMs,
      'lastRunAtMs': instance.lastRunAtMs,
      'lastStatus': instance.lastStatus,
      'lastError': instance.lastError,
    };

_$CronJobImpl _$$CronJobImplFromJson(Map<String, dynamic> json) =>
    _$CronJobImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      schedule: CronSchedule.fromJson(json['schedule'] as Map<String, dynamic>),
      createdAtMs: (json['createdAtMs'] as num).toInt(),
      updatedAtMs: (json['updatedAtMs'] as num).toInt(),
      payload: json['payload'] == null
          ? const CronPayload()
          : CronPayload.fromJson(json['payload'] as Map<String, dynamic>),
      state: json['state'] == null
          ? const CronJobState()
          : CronJobState.fromJson(json['state'] as Map<String, dynamic>),
      enabled: json['enabled'] as bool? ?? true,
      deleteAfterRun: json['deleteAfterRun'] as bool? ?? false,
    );

Map<String, dynamic> _$$CronJobImplToJson(_$CronJobImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'schedule': instance.schedule,
      'createdAtMs': instance.createdAtMs,
      'updatedAtMs': instance.updatedAtMs,
      'payload': instance.payload,
      'state': instance.state,
      'enabled': instance.enabled,
      'deleteAfterRun': instance.deleteAfterRun,
    };

_$CronStoreImpl _$$CronStoreImplFromJson(Map<String, dynamic> json) =>
    _$CronStoreImpl(
      version: (json['version'] as num?)?.toInt() ?? 1,
      jobs: (json['jobs'] as List<dynamic>?)
              ?.map((e) => CronJob.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CronStoreImplToJson(_$CronStoreImpl instance) =>
    <String, dynamic>{
      'version': instance.version,
      'jobs': instance.jobs,
    };
