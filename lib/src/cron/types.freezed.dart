// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'types.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CronSchedule _$CronScheduleFromJson(Map<String, dynamic> json) {
  return _CronSchedule.fromJson(json);
}

/// @nodoc
mixin _$CronSchedule {
  /// Kind of schedule: 'at', 'every', 'cron'.
  String get kind => throw _privateConstructorUsedError;

  /// For "at": timestamp in ms.
  @JsonKey(name: 'atMs')
  int? get atMs => throw _privateConstructorUsedError;

  /// For "every": interval in ms.
  @JsonKey(name: 'everyMs')
  int? get everyMs => throw _privateConstructorUsedError;

  /// For "cron": cron expression (e.g. "0 9 * * *").
  String? get expr => throw _privateConstructorUsedError;

  /// Timezone for cron expressions.
  String? get tz => throw _privateConstructorUsedError;

  /// Serializes this CronSchedule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CronSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CronScheduleCopyWith<CronSchedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CronScheduleCopyWith<$Res> {
  factory $CronScheduleCopyWith(
          CronSchedule value, $Res Function(CronSchedule) then) =
      _$CronScheduleCopyWithImpl<$Res, CronSchedule>;
  @useResult
  $Res call(
      {String kind,
      @JsonKey(name: 'atMs') int? atMs,
      @JsonKey(name: 'everyMs') int? everyMs,
      String? expr,
      String? tz});
}

/// @nodoc
class _$CronScheduleCopyWithImpl<$Res, $Val extends CronSchedule>
    implements $CronScheduleCopyWith<$Res> {
  _$CronScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CronSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kind = null,
    Object? atMs = freezed,
    Object? everyMs = freezed,
    Object? expr = freezed,
    Object? tz = freezed,
  }) {
    return _then(_value.copyWith(
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as String,
      atMs: freezed == atMs
          ? _value.atMs
          : atMs // ignore: cast_nullable_to_non_nullable
              as int?,
      everyMs: freezed == everyMs
          ? _value.everyMs
          : everyMs // ignore: cast_nullable_to_non_nullable
              as int?,
      expr: freezed == expr
          ? _value.expr
          : expr // ignore: cast_nullable_to_non_nullable
              as String?,
      tz: freezed == tz
          ? _value.tz
          : tz // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CronScheduleImplCopyWith<$Res>
    implements $CronScheduleCopyWith<$Res> {
  factory _$$CronScheduleImplCopyWith(
          _$CronScheduleImpl value, $Res Function(_$CronScheduleImpl) then) =
      __$$CronScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String kind,
      @JsonKey(name: 'atMs') int? atMs,
      @JsonKey(name: 'everyMs') int? everyMs,
      String? expr,
      String? tz});
}

/// @nodoc
class __$$CronScheduleImplCopyWithImpl<$Res>
    extends _$CronScheduleCopyWithImpl<$Res, _$CronScheduleImpl>
    implements _$$CronScheduleImplCopyWith<$Res> {
  __$$CronScheduleImplCopyWithImpl(
      _$CronScheduleImpl _value, $Res Function(_$CronScheduleImpl) _then)
      : super(_value, _then);

  /// Create a copy of CronSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kind = null,
    Object? atMs = freezed,
    Object? everyMs = freezed,
    Object? expr = freezed,
    Object? tz = freezed,
  }) {
    return _then(_$CronScheduleImpl(
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as String,
      atMs: freezed == atMs
          ? _value.atMs
          : atMs // ignore: cast_nullable_to_non_nullable
              as int?,
      everyMs: freezed == everyMs
          ? _value.everyMs
          : everyMs // ignore: cast_nullable_to_non_nullable
              as int?,
      expr: freezed == expr
          ? _value.expr
          : expr // ignore: cast_nullable_to_non_nullable
              as String?,
      tz: freezed == tz
          ? _value.tz
          : tz // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CronScheduleImpl implements _CronSchedule {
  const _$CronScheduleImpl(
      {required this.kind,
      @JsonKey(name: 'atMs') this.atMs,
      @JsonKey(name: 'everyMs') this.everyMs,
      this.expr,
      this.tz});

  factory _$CronScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$CronScheduleImplFromJson(json);

  /// Kind of schedule: 'at', 'every', 'cron'.
  @override
  final String kind;

  /// For "at": timestamp in ms.
  @override
  @JsonKey(name: 'atMs')
  final int? atMs;

  /// For "every": interval in ms.
  @override
  @JsonKey(name: 'everyMs')
  final int? everyMs;

  /// For "cron": cron expression (e.g. "0 9 * * *").
  @override
  final String? expr;

  /// Timezone for cron expressions.
  @override
  final String? tz;

  @override
  String toString() {
    return 'CronSchedule(kind: $kind, atMs: $atMs, everyMs: $everyMs, expr: $expr, tz: $tz)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CronScheduleImpl &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.atMs, atMs) || other.atMs == atMs) &&
            (identical(other.everyMs, everyMs) || other.everyMs == everyMs) &&
            (identical(other.expr, expr) || other.expr == expr) &&
            (identical(other.tz, tz) || other.tz == tz));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, kind, atMs, everyMs, expr, tz);

  /// Create a copy of CronSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CronScheduleImplCopyWith<_$CronScheduleImpl> get copyWith =>
      __$$CronScheduleImplCopyWithImpl<_$CronScheduleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CronScheduleImplToJson(
      this,
    );
  }
}

abstract class _CronSchedule implements CronSchedule {
  const factory _CronSchedule(
      {required final String kind,
      @JsonKey(name: 'atMs') final int? atMs,
      @JsonKey(name: 'everyMs') final int? everyMs,
      final String? expr,
      final String? tz}) = _$CronScheduleImpl;

  factory _CronSchedule.fromJson(Map<String, dynamic> json) =
      _$CronScheduleImpl.fromJson;

  /// Kind of schedule: 'at', 'every', 'cron'.
  @override
  String get kind;

  /// For "at": timestamp in ms.
  @override
  @JsonKey(name: 'atMs')
  int? get atMs;

  /// For "every": interval in ms.
  @override
  @JsonKey(name: 'everyMs')
  int? get everyMs;

  /// For "cron": cron expression (e.g. "0 9 * * *").
  @override
  String? get expr;

  /// Timezone for cron expressions.
  @override
  String? get tz;

  /// Create a copy of CronSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CronScheduleImplCopyWith<_$CronScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CronPayload _$CronPayloadFromJson(Map<String, dynamic> json) {
  return _CronPayload.fromJson(json);
}

/// @nodoc
mixin _$CronPayload {
  /// Kind of payload: 'system_event', 'agent_turn'.
  String get kind => throw _privateConstructorUsedError;

  /// Message specific content.
  String get message => throw _privateConstructorUsedError;

  /// Deliver response to channel.
  bool get deliver => throw _privateConstructorUsedError;

  /// Channel name (e.g. "whatsapp").
  String? get channel => throw _privateConstructorUsedError;

  /// Recipient address (e.g. phone number).
  String? get to => throw _privateConstructorUsedError;

  /// Serializes this CronPayload to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CronPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CronPayloadCopyWith<CronPayload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CronPayloadCopyWith<$Res> {
  factory $CronPayloadCopyWith(
          CronPayload value, $Res Function(CronPayload) then) =
      _$CronPayloadCopyWithImpl<$Res, CronPayload>;
  @useResult
  $Res call(
      {String kind, String message, bool deliver, String? channel, String? to});
}

/// @nodoc
class _$CronPayloadCopyWithImpl<$Res, $Val extends CronPayload>
    implements $CronPayloadCopyWith<$Res> {
  _$CronPayloadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CronPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kind = null,
    Object? message = null,
    Object? deliver = null,
    Object? channel = freezed,
    Object? to = freezed,
  }) {
    return _then(_value.copyWith(
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      deliver: null == deliver
          ? _value.deliver
          : deliver // ignore: cast_nullable_to_non_nullable
              as bool,
      channel: freezed == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as String?,
      to: freezed == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CronPayloadImplCopyWith<$Res>
    implements $CronPayloadCopyWith<$Res> {
  factory _$$CronPayloadImplCopyWith(
          _$CronPayloadImpl value, $Res Function(_$CronPayloadImpl) then) =
      __$$CronPayloadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String kind, String message, bool deliver, String? channel, String? to});
}

/// @nodoc
class __$$CronPayloadImplCopyWithImpl<$Res>
    extends _$CronPayloadCopyWithImpl<$Res, _$CronPayloadImpl>
    implements _$$CronPayloadImplCopyWith<$Res> {
  __$$CronPayloadImplCopyWithImpl(
      _$CronPayloadImpl _value, $Res Function(_$CronPayloadImpl) _then)
      : super(_value, _then);

  /// Create a copy of CronPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kind = null,
    Object? message = null,
    Object? deliver = null,
    Object? channel = freezed,
    Object? to = freezed,
  }) {
    return _then(_$CronPayloadImpl(
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      deliver: null == deliver
          ? _value.deliver
          : deliver // ignore: cast_nullable_to_non_nullable
              as bool,
      channel: freezed == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as String?,
      to: freezed == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CronPayloadImpl implements _CronPayload {
  const _$CronPayloadImpl(
      {this.kind = 'agent_turn',
      this.message = '',
      this.deliver = false,
      this.channel,
      this.to});

  factory _$CronPayloadImpl.fromJson(Map<String, dynamic> json) =>
      _$$CronPayloadImplFromJson(json);

  /// Kind of payload: 'system_event', 'agent_turn'.
  @override
  @JsonKey()
  final String kind;

  /// Message specific content.
  @override
  @JsonKey()
  final String message;

  /// Deliver response to channel.
  @override
  @JsonKey()
  final bool deliver;

  /// Channel name (e.g. "whatsapp").
  @override
  final String? channel;

  /// Recipient address (e.g. phone number).
  @override
  final String? to;

  @override
  String toString() {
    return 'CronPayload(kind: $kind, message: $message, deliver: $deliver, channel: $channel, to: $to)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CronPayloadImpl &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.deliver, deliver) || other.deliver == deliver) &&
            (identical(other.channel, channel) || other.channel == channel) &&
            (identical(other.to, to) || other.to == to));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, kind, message, deliver, channel, to);

  /// Create a copy of CronPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CronPayloadImplCopyWith<_$CronPayloadImpl> get copyWith =>
      __$$CronPayloadImplCopyWithImpl<_$CronPayloadImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CronPayloadImplToJson(
      this,
    );
  }
}

abstract class _CronPayload implements CronPayload {
  const factory _CronPayload(
      {final String kind,
      final String message,
      final bool deliver,
      final String? channel,
      final String? to}) = _$CronPayloadImpl;

  factory _CronPayload.fromJson(Map<String, dynamic> json) =
      _$CronPayloadImpl.fromJson;

  /// Kind of payload: 'system_event', 'agent_turn'.
  @override
  String get kind;

  /// Message specific content.
  @override
  String get message;

  /// Deliver response to channel.
  @override
  bool get deliver;

  /// Channel name (e.g. "whatsapp").
  @override
  String? get channel;

  /// Recipient address (e.g. phone number).
  @override
  String? get to;

  /// Create a copy of CronPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CronPayloadImplCopyWith<_$CronPayloadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CronJobState _$CronJobStateFromJson(Map<String, dynamic> json) {
  return _CronJobState.fromJson(json);
}

/// @nodoc
mixin _$CronJobState {
  @JsonKey(name: 'nextRunAtMs')
  int? get nextRunAtMs => throw _privateConstructorUsedError;
  @JsonKey(name: 'lastRunAtMs')
  int? get lastRunAtMs => throw _privateConstructorUsedError;
  @JsonKey(name: 'lastStatus')
  String? get lastStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'lastError')
  String? get lastError => throw _privateConstructorUsedError;

  /// Serializes this CronJobState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CronJobState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CronJobStateCopyWith<CronJobState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CronJobStateCopyWith<$Res> {
  factory $CronJobStateCopyWith(
          CronJobState value, $Res Function(CronJobState) then) =
      _$CronJobStateCopyWithImpl<$Res, CronJobState>;
  @useResult
  $Res call(
      {@JsonKey(name: 'nextRunAtMs') int? nextRunAtMs,
      @JsonKey(name: 'lastRunAtMs') int? lastRunAtMs,
      @JsonKey(name: 'lastStatus') String? lastStatus,
      @JsonKey(name: 'lastError') String? lastError});
}

/// @nodoc
class _$CronJobStateCopyWithImpl<$Res, $Val extends CronJobState>
    implements $CronJobStateCopyWith<$Res> {
  _$CronJobStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CronJobState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nextRunAtMs = freezed,
    Object? lastRunAtMs = freezed,
    Object? lastStatus = freezed,
    Object? lastError = freezed,
  }) {
    return _then(_value.copyWith(
      nextRunAtMs: freezed == nextRunAtMs
          ? _value.nextRunAtMs
          : nextRunAtMs // ignore: cast_nullable_to_non_nullable
              as int?,
      lastRunAtMs: freezed == lastRunAtMs
          ? _value.lastRunAtMs
          : lastRunAtMs // ignore: cast_nullable_to_non_nullable
              as int?,
      lastStatus: freezed == lastStatus
          ? _value.lastStatus
          : lastStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      lastError: freezed == lastError
          ? _value.lastError
          : lastError // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CronJobStateImplCopyWith<$Res>
    implements $CronJobStateCopyWith<$Res> {
  factory _$$CronJobStateImplCopyWith(
          _$CronJobStateImpl value, $Res Function(_$CronJobStateImpl) then) =
      __$$CronJobStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'nextRunAtMs') int? nextRunAtMs,
      @JsonKey(name: 'lastRunAtMs') int? lastRunAtMs,
      @JsonKey(name: 'lastStatus') String? lastStatus,
      @JsonKey(name: 'lastError') String? lastError});
}

/// @nodoc
class __$$CronJobStateImplCopyWithImpl<$Res>
    extends _$CronJobStateCopyWithImpl<$Res, _$CronJobStateImpl>
    implements _$$CronJobStateImplCopyWith<$Res> {
  __$$CronJobStateImplCopyWithImpl(
      _$CronJobStateImpl _value, $Res Function(_$CronJobStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of CronJobState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nextRunAtMs = freezed,
    Object? lastRunAtMs = freezed,
    Object? lastStatus = freezed,
    Object? lastError = freezed,
  }) {
    return _then(_$CronJobStateImpl(
      nextRunAtMs: freezed == nextRunAtMs
          ? _value.nextRunAtMs
          : nextRunAtMs // ignore: cast_nullable_to_non_nullable
              as int?,
      lastRunAtMs: freezed == lastRunAtMs
          ? _value.lastRunAtMs
          : lastRunAtMs // ignore: cast_nullable_to_non_nullable
              as int?,
      lastStatus: freezed == lastStatus
          ? _value.lastStatus
          : lastStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      lastError: freezed == lastError
          ? _value.lastError
          : lastError // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CronJobStateImpl implements _CronJobState {
  const _$CronJobStateImpl(
      {@JsonKey(name: 'nextRunAtMs') this.nextRunAtMs,
      @JsonKey(name: 'lastRunAtMs') this.lastRunAtMs,
      @JsonKey(name: 'lastStatus') this.lastStatus,
      @JsonKey(name: 'lastError') this.lastError});

  factory _$CronJobStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$CronJobStateImplFromJson(json);

  @override
  @JsonKey(name: 'nextRunAtMs')
  final int? nextRunAtMs;
  @override
  @JsonKey(name: 'lastRunAtMs')
  final int? lastRunAtMs;
  @override
  @JsonKey(name: 'lastStatus')
  final String? lastStatus;
  @override
  @JsonKey(name: 'lastError')
  final String? lastError;

  @override
  String toString() {
    return 'CronJobState(nextRunAtMs: $nextRunAtMs, lastRunAtMs: $lastRunAtMs, lastStatus: $lastStatus, lastError: $lastError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CronJobStateImpl &&
            (identical(other.nextRunAtMs, nextRunAtMs) ||
                other.nextRunAtMs == nextRunAtMs) &&
            (identical(other.lastRunAtMs, lastRunAtMs) ||
                other.lastRunAtMs == lastRunAtMs) &&
            (identical(other.lastStatus, lastStatus) ||
                other.lastStatus == lastStatus) &&
            (identical(other.lastError, lastError) ||
                other.lastError == lastError));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, nextRunAtMs, lastRunAtMs, lastStatus, lastError);

  /// Create a copy of CronJobState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CronJobStateImplCopyWith<_$CronJobStateImpl> get copyWith =>
      __$$CronJobStateImplCopyWithImpl<_$CronJobStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CronJobStateImplToJson(
      this,
    );
  }
}

abstract class _CronJobState implements CronJobState {
  const factory _CronJobState(
          {@JsonKey(name: 'nextRunAtMs') final int? nextRunAtMs,
          @JsonKey(name: 'lastRunAtMs') final int? lastRunAtMs,
          @JsonKey(name: 'lastStatus') final String? lastStatus,
          @JsonKey(name: 'lastError') final String? lastError}) =
      _$CronJobStateImpl;

  factory _CronJobState.fromJson(Map<String, dynamic> json) =
      _$CronJobStateImpl.fromJson;

  @override
  @JsonKey(name: 'nextRunAtMs')
  int? get nextRunAtMs;
  @override
  @JsonKey(name: 'lastRunAtMs')
  int? get lastRunAtMs;
  @override
  @JsonKey(name: 'lastStatus')
  String? get lastStatus;
  @override
  @JsonKey(name: 'lastError')
  String? get lastError;

  /// Create a copy of CronJobState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CronJobStateImplCopyWith<_$CronJobStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CronJob _$CronJobFromJson(Map<String, dynamic> json) {
  return _CronJob.fromJson(json);
}

/// @nodoc
mixin _$CronJob {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  CronSchedule get schedule => throw _privateConstructorUsedError;
  @JsonKey(name: 'createdAtMs')
  int get createdAtMs => throw _privateConstructorUsedError;
  @JsonKey(name: 'updatedAtMs')
  int get updatedAtMs => throw _privateConstructorUsedError;
  CronPayload get payload => throw _privateConstructorUsedError;
  CronJobState get state => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;
  @JsonKey(name: 'deleteAfterRun')
  bool get deleteAfterRun => throw _privateConstructorUsedError;

  /// Serializes this CronJob to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CronJob
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CronJobCopyWith<CronJob> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CronJobCopyWith<$Res> {
  factory $CronJobCopyWith(CronJob value, $Res Function(CronJob) then) =
      _$CronJobCopyWithImpl<$Res, CronJob>;
  @useResult
  $Res call(
      {String id,
      String name,
      CronSchedule schedule,
      @JsonKey(name: 'createdAtMs') int createdAtMs,
      @JsonKey(name: 'updatedAtMs') int updatedAtMs,
      CronPayload payload,
      CronJobState state,
      bool enabled,
      @JsonKey(name: 'deleteAfterRun') bool deleteAfterRun});

  $CronScheduleCopyWith<$Res> get schedule;
  $CronPayloadCopyWith<$Res> get payload;
  $CronJobStateCopyWith<$Res> get state;
}

/// @nodoc
class _$CronJobCopyWithImpl<$Res, $Val extends CronJob>
    implements $CronJobCopyWith<$Res> {
  _$CronJobCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CronJob
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? schedule = null,
    Object? createdAtMs = null,
    Object? updatedAtMs = null,
    Object? payload = null,
    Object? state = null,
    Object? enabled = null,
    Object? deleteAfterRun = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      schedule: null == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as CronSchedule,
      createdAtMs: null == createdAtMs
          ? _value.createdAtMs
          : createdAtMs // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAtMs: null == updatedAtMs
          ? _value.updatedAtMs
          : updatedAtMs // ignore: cast_nullable_to_non_nullable
              as int,
      payload: null == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as CronPayload,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as CronJobState,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      deleteAfterRun: null == deleteAfterRun
          ? _value.deleteAfterRun
          : deleteAfterRun // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of CronJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CronScheduleCopyWith<$Res> get schedule {
    return $CronScheduleCopyWith<$Res>(_value.schedule, (value) {
      return _then(_value.copyWith(schedule: value) as $Val);
    });
  }

  /// Create a copy of CronJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CronPayloadCopyWith<$Res> get payload {
    return $CronPayloadCopyWith<$Res>(_value.payload, (value) {
      return _then(_value.copyWith(payload: value) as $Val);
    });
  }

  /// Create a copy of CronJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CronJobStateCopyWith<$Res> get state {
    return $CronJobStateCopyWith<$Res>(_value.state, (value) {
      return _then(_value.copyWith(state: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CronJobImplCopyWith<$Res> implements $CronJobCopyWith<$Res> {
  factory _$$CronJobImplCopyWith(
          _$CronJobImpl value, $Res Function(_$CronJobImpl) then) =
      __$$CronJobImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      CronSchedule schedule,
      @JsonKey(name: 'createdAtMs') int createdAtMs,
      @JsonKey(name: 'updatedAtMs') int updatedAtMs,
      CronPayload payload,
      CronJobState state,
      bool enabled,
      @JsonKey(name: 'deleteAfterRun') bool deleteAfterRun});

  @override
  $CronScheduleCopyWith<$Res> get schedule;
  @override
  $CronPayloadCopyWith<$Res> get payload;
  @override
  $CronJobStateCopyWith<$Res> get state;
}

/// @nodoc
class __$$CronJobImplCopyWithImpl<$Res>
    extends _$CronJobCopyWithImpl<$Res, _$CronJobImpl>
    implements _$$CronJobImplCopyWith<$Res> {
  __$$CronJobImplCopyWithImpl(
      _$CronJobImpl _value, $Res Function(_$CronJobImpl) _then)
      : super(_value, _then);

  /// Create a copy of CronJob
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? schedule = null,
    Object? createdAtMs = null,
    Object? updatedAtMs = null,
    Object? payload = null,
    Object? state = null,
    Object? enabled = null,
    Object? deleteAfterRun = null,
  }) {
    return _then(_$CronJobImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      schedule: null == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as CronSchedule,
      createdAtMs: null == createdAtMs
          ? _value.createdAtMs
          : createdAtMs // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAtMs: null == updatedAtMs
          ? _value.updatedAtMs
          : updatedAtMs // ignore: cast_nullable_to_non_nullable
              as int,
      payload: null == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as CronPayload,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as CronJobState,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      deleteAfterRun: null == deleteAfterRun
          ? _value.deleteAfterRun
          : deleteAfterRun // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CronJobImpl implements _CronJob {
  const _$CronJobImpl(
      {required this.id,
      required this.name,
      required this.schedule,
      @JsonKey(name: 'createdAtMs') required this.createdAtMs,
      @JsonKey(name: 'updatedAtMs') required this.updatedAtMs,
      required this.payload = const CronPayload(),
      required this.state = const CronJobState(),
      this.enabled = true,
      @JsonKey(name: 'deleteAfterRun') this.deleteAfterRun = false});

  factory _$CronJobImpl.fromJson(Map<String, dynamic> json) =>
      _$$CronJobImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final CronSchedule schedule;
  @override
  @JsonKey(name: 'createdAtMs')
  final int createdAtMs;
  @override
  @JsonKey(name: 'updatedAtMs')
  final int updatedAtMs;
  @override
  @JsonKey()
  final CronPayload payload;
  @override
  @JsonKey()
  final CronJobState state;
  @override
  @JsonKey()
  final bool enabled;
  @override
  @JsonKey(name: 'deleteAfterRun')
  final bool deleteAfterRun;

  @override
  String toString() {
    return 'CronJob(id: $id, name: $name, schedule: $schedule, createdAtMs: $createdAtMs, updatedAtMs: $updatedAtMs, payload: $payload, state: $state, enabled: $enabled, deleteAfterRun: $deleteAfterRun)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CronJobImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.schedule, schedule) ||
                other.schedule == schedule) &&
            (identical(other.createdAtMs, createdAtMs) ||
                other.createdAtMs == createdAtMs) &&
            (identical(other.updatedAtMs, updatedAtMs) ||
                other.updatedAtMs == updatedAtMs) &&
            (identical(other.payload, payload) || other.payload == payload) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.deleteAfterRun, deleteAfterRun) ||
                other.deleteAfterRun == deleteAfterRun));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, schedule, createdAtMs,
      updatedAtMs, payload, state, enabled, deleteAfterRun);

  /// Create a copy of CronJob
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CronJobImplCopyWith<_$CronJobImpl> get copyWith =>
      __$$CronJobImplCopyWithImpl<_$CronJobImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CronJobImplToJson(
      this,
    );
  }
}

abstract class _CronJob implements CronJob {
  const factory _CronJob(
          {required final String id,
          required final String name,
          required final CronSchedule schedule,
          @JsonKey(name: 'createdAtMs') required final int createdAtMs,
          @JsonKey(name: 'updatedAtMs') required final int updatedAtMs,
          required final CronPayload payload,
          required final CronJobState state,
          final bool enabled,
          @JsonKey(name: 'deleteAfterRun') final bool deleteAfterRun}) =
      _$CronJobImpl;

  factory _CronJob.fromJson(Map<String, dynamic> json) = _$CronJobImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  CronSchedule get schedule;
  @override
  @JsonKey(name: 'createdAtMs')
  int get createdAtMs;
  @override
  @JsonKey(name: 'updatedAtMs')
  int get updatedAtMs;
  @override
  CronPayload get payload;
  @override
  CronJobState get state;
  @override
  bool get enabled;
  @override
  @JsonKey(name: 'deleteAfterRun')
  bool get deleteAfterRun;

  /// Create a copy of CronJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CronJobImplCopyWith<_$CronJobImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CronStore _$CronStoreFromJson(Map<String, dynamic> json) {
  return _CronStore.fromJson(json);
}

/// @nodoc
mixin _$CronStore {
  int get version => throw _privateConstructorUsedError;
  List<CronJob> get jobs => throw _privateConstructorUsedError;

  /// Serializes this CronStore to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CronStore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CronStoreCopyWith<CronStore> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CronStoreCopyWith<$Res> {
  factory $CronStoreCopyWith(CronStore value, $Res Function(CronStore) then) =
      _$CronStoreCopyWithImpl<$Res, CronStore>;
  @useResult
  $Res call({int version, List<CronJob> jobs});
}

/// @nodoc
class _$CronStoreCopyWithImpl<$Res, $Val extends CronStore>
    implements $CronStoreCopyWith<$Res> {
  _$CronStoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CronStore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? jobs = null,
  }) {
    return _then(_value.copyWith(
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
      jobs: null == jobs
          ? _value.jobs
          : jobs // ignore: cast_nullable_to_non_nullable
              as List<CronJob>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CronStoreImplCopyWith<$Res>
    implements $CronStoreCopyWith<$Res> {
  factory _$$CronStoreImplCopyWith(
          _$CronStoreImpl value, $Res Function(_$CronStoreImpl) then) =
      __$$CronStoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int version, List<CronJob> jobs});
}

/// @nodoc
class __$$CronStoreImplCopyWithImpl<$Res>
    extends _$CronStoreCopyWithImpl<$Res, _$CronStoreImpl>
    implements _$$CronStoreImplCopyWith<$Res> {
  __$$CronStoreImplCopyWithImpl(
      _$CronStoreImpl _value, $Res Function(_$CronStoreImpl) _then)
      : super(_value, _then);

  /// Create a copy of CronStore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? jobs = null,
  }) {
    return _then(_$CronStoreImpl(
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
      jobs: null == jobs
          ? _value._jobs
          : jobs // ignore: cast_nullable_to_non_nullable
              as List<CronJob>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CronStoreImpl implements _CronStore {
  const _$CronStoreImpl({this.version = 1, final List<CronJob> jobs = const []})
      : _jobs = jobs;

  factory _$CronStoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$CronStoreImplFromJson(json);

  @override
  @JsonKey()
  final int version;
  final List<CronJob> _jobs;
  @override
  @JsonKey()
  List<CronJob> get jobs {
    if (_jobs is EqualUnmodifiableListView) return _jobs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_jobs);
  }

  @override
  String toString() {
    return 'CronStore(version: $version, jobs: $jobs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CronStoreImpl &&
            (identical(other.version, version) || other.version == version) &&
            const DeepCollectionEquality().equals(other._jobs, _jobs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, version, const DeepCollectionEquality().hash(_jobs));

  /// Create a copy of CronStore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CronStoreImplCopyWith<_$CronStoreImpl> get copyWith =>
      __$$CronStoreImplCopyWithImpl<_$CronStoreImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CronStoreImplToJson(
      this,
    );
  }
}

abstract class _CronStore implements CronStore {
  const factory _CronStore({final int version, final List<CronJob> jobs}) =
      _$CronStoreImpl;

  factory _CronStore.fromJson(Map<String, dynamic> json) =
      _$CronStoreImpl.fromJson;

  @override
  int get version;
  @override
  List<CronJob> get jobs;

  /// Create a copy of CronStore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CronStoreImplCopyWith<_$CronStoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
