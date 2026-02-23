// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_reminder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SubscriptionReminder {
  String get id => throw _privateConstructorUsedError;
  SubscriptionTier get tier => throw _privateConstructorUsedError;
  DateTime get planStartDate => throw _privateConstructorUsedError;
  DateTime get planExpiryDate => throw _privateConstructorUsedError;
  DateTime? get lastReminderSent => throw _privateConstructorUsedError;
  List<DateTime> get scheduledReminders => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SubscriptionReminderCopyWith<SubscriptionReminder> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionReminderCopyWith<$Res> {
  factory $SubscriptionReminderCopyWith(SubscriptionReminder value,
          $Res Function(SubscriptionReminder) then) =
      _$SubscriptionReminderCopyWithImpl<$Res, SubscriptionReminder>;
  @useResult
  $Res call(
      {String id,
      SubscriptionTier tier,
      DateTime planStartDate,
      DateTime planExpiryDate,
      DateTime? lastReminderSent,
      List<DateTime> scheduledReminders});
}

/// @nodoc
class _$SubscriptionReminderCopyWithImpl<$Res,
        $Val extends SubscriptionReminder>
    implements $SubscriptionReminderCopyWith<$Res> {
  _$SubscriptionReminderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tier = null,
    Object? planStartDate = null,
    Object? planExpiryDate = null,
    Object? lastReminderSent = freezed,
    Object? scheduledReminders = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as SubscriptionTier,
      planStartDate: null == planStartDate
          ? _value.planStartDate
          : planStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      planExpiryDate: null == planExpiryDate
          ? _value.planExpiryDate
          : planExpiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastReminderSent: freezed == lastReminderSent
          ? _value.lastReminderSent
          : lastReminderSent // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      scheduledReminders: null == scheduledReminders
          ? _value.scheduledReminders
          : scheduledReminders // ignore: cast_nullable_to_non_nullable
              as List<DateTime>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubscriptionReminderImplCopyWith<$Res>
    implements $SubscriptionReminderCopyWith<$Res> {
  factory _$$SubscriptionReminderImplCopyWith(_$SubscriptionReminderImpl value,
          $Res Function(_$SubscriptionReminderImpl) then) =
      __$$SubscriptionReminderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      SubscriptionTier tier,
      DateTime planStartDate,
      DateTime planExpiryDate,
      DateTime? lastReminderSent,
      List<DateTime> scheduledReminders});
}

/// @nodoc
class __$$SubscriptionReminderImplCopyWithImpl<$Res>
    extends _$SubscriptionReminderCopyWithImpl<$Res, _$SubscriptionReminderImpl>
    implements _$$SubscriptionReminderImplCopyWith<$Res> {
  __$$SubscriptionReminderImplCopyWithImpl(_$SubscriptionReminderImpl _value,
      $Res Function(_$SubscriptionReminderImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tier = null,
    Object? planStartDate = null,
    Object? planExpiryDate = null,
    Object? lastReminderSent = freezed,
    Object? scheduledReminders = null,
  }) {
    return _then(_$SubscriptionReminderImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as SubscriptionTier,
      planStartDate: null == planStartDate
          ? _value.planStartDate
          : planStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      planExpiryDate: null == planExpiryDate
          ? _value.planExpiryDate
          : planExpiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastReminderSent: freezed == lastReminderSent
          ? _value.lastReminderSent
          : lastReminderSent // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      scheduledReminders: null == scheduledReminders
          ? _value._scheduledReminders
          : scheduledReminders // ignore: cast_nullable_to_non_nullable
              as List<DateTime>,
    ));
  }
}

/// @nodoc

class _$SubscriptionReminderImpl extends _SubscriptionReminder {
  const _$SubscriptionReminderImpl(
      {required this.id,
      required this.tier,
      required this.planStartDate,
      required this.planExpiryDate,
      this.lastReminderSent,
      required final List<DateTime> scheduledReminders})
      : _scheduledReminders = scheduledReminders,
        super._();

  @override
  final String id;
  @override
  final SubscriptionTier tier;
  @override
  final DateTime planStartDate;
  @override
  final DateTime planExpiryDate;
  @override
  final DateTime? lastReminderSent;
  final List<DateTime> _scheduledReminders;
  @override
  List<DateTime> get scheduledReminders {
    if (_scheduledReminders is EqualUnmodifiableListView)
      return _scheduledReminders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scheduledReminders);
  }

  @override
  String toString() {
    return 'SubscriptionReminder(id: $id, tier: $tier, planStartDate: $planStartDate, planExpiryDate: $planExpiryDate, lastReminderSent: $lastReminderSent, scheduledReminders: $scheduledReminders)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionReminderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.planStartDate, planStartDate) ||
                other.planStartDate == planStartDate) &&
            (identical(other.planExpiryDate, planExpiryDate) ||
                other.planExpiryDate == planExpiryDate) &&
            (identical(other.lastReminderSent, lastReminderSent) ||
                other.lastReminderSent == lastReminderSent) &&
            const DeepCollectionEquality()
                .equals(other._scheduledReminders, _scheduledReminders));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tier,
      planStartDate,
      planExpiryDate,
      lastReminderSent,
      const DeepCollectionEquality().hash(_scheduledReminders));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionReminderImplCopyWith<_$SubscriptionReminderImpl>
      get copyWith =>
          __$$SubscriptionReminderImplCopyWithImpl<_$SubscriptionReminderImpl>(
              this, _$identity);
}

abstract class _SubscriptionReminder extends SubscriptionReminder {
  const factory _SubscriptionReminder(
          {required final String id,
          required final SubscriptionTier tier,
          required final DateTime planStartDate,
          required final DateTime planExpiryDate,
          final DateTime? lastReminderSent,
          required final List<DateTime> scheduledReminders}) =
      _$SubscriptionReminderImpl;
  const _SubscriptionReminder._() : super._();

  @override
  String get id;
  @override
  SubscriptionTier get tier;
  @override
  DateTime get planStartDate;
  @override
  DateTime get planExpiryDate;
  @override
  DateTime? get lastReminderSent;
  @override
  List<DateTime> get scheduledReminders;
  @override
  @JsonKey(ignore: true)
  _$$SubscriptionReminderImplCopyWith<_$SubscriptionReminderImpl>
      get copyWith => throw _privateConstructorUsedError;
}
