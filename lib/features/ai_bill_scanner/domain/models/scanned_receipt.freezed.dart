// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scanned_receipt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ScannedReceipt _$ScannedReceiptFromJson(Map<String, dynamic> json) {
  return _ScannedReceipt.fromJson(json);
}

/// @nodoc
mixin _$ScannedReceipt {
  String get merchantName => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  DateTime? get date => throw _privateConstructorUsedError;
  List<ReceiptItem> get items => throw _privateConstructorUsedError;
  double get confidenceScore => throw _privateConstructorUsedError;
  bool get isAiEnhanced => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScannedReceiptCopyWith<ScannedReceipt> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScannedReceiptCopyWith<$Res> {
  factory $ScannedReceiptCopyWith(
          ScannedReceipt value, $Res Function(ScannedReceipt) then) =
      _$ScannedReceiptCopyWithImpl<$Res, ScannedReceipt>;
  @useResult
  $Res call(
      {String merchantName,
      double totalAmount,
      DateTime? date,
      List<ReceiptItem> items,
      double confidenceScore,
      bool isAiEnhanced});
}

/// @nodoc
class _$ScannedReceiptCopyWithImpl<$Res, $Val extends ScannedReceipt>
    implements $ScannedReceiptCopyWith<$Res> {
  _$ScannedReceiptCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? merchantName = null,
    Object? totalAmount = null,
    Object? date = freezed,
    Object? items = null,
    Object? confidenceScore = null,
    Object? isAiEnhanced = null,
  }) {
    return _then(_value.copyWith(
      merchantName: null == merchantName
          ? _value.merchantName
          : merchantName // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ReceiptItem>,
      confidenceScore: null == confidenceScore
          ? _value.confidenceScore
          : confidenceScore // ignore: cast_nullable_to_non_nullable
              as double,
      isAiEnhanced: null == isAiEnhanced
          ? _value.isAiEnhanced
          : isAiEnhanced // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScannedReceiptImplCopyWith<$Res>
    implements $ScannedReceiptCopyWith<$Res> {
  factory _$$ScannedReceiptImplCopyWith(_$ScannedReceiptImpl value,
          $Res Function(_$ScannedReceiptImpl) then) =
      __$$ScannedReceiptImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String merchantName,
      double totalAmount,
      DateTime? date,
      List<ReceiptItem> items,
      double confidenceScore,
      bool isAiEnhanced});
}

/// @nodoc
class __$$ScannedReceiptImplCopyWithImpl<$Res>
    extends _$ScannedReceiptCopyWithImpl<$Res, _$ScannedReceiptImpl>
    implements _$$ScannedReceiptImplCopyWith<$Res> {
  __$$ScannedReceiptImplCopyWithImpl(
      _$ScannedReceiptImpl _value, $Res Function(_$ScannedReceiptImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? merchantName = null,
    Object? totalAmount = null,
    Object? date = freezed,
    Object? items = null,
    Object? confidenceScore = null,
    Object? isAiEnhanced = null,
  }) {
    return _then(_$ScannedReceiptImpl(
      merchantName: null == merchantName
          ? _value.merchantName
          : merchantName // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ReceiptItem>,
      confidenceScore: null == confidenceScore
          ? _value.confidenceScore
          : confidenceScore // ignore: cast_nullable_to_non_nullable
              as double,
      isAiEnhanced: null == isAiEnhanced
          ? _value.isAiEnhanced
          : isAiEnhanced // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScannedReceiptImpl implements _ScannedReceipt {
  const _$ScannedReceiptImpl(
      {required this.merchantName,
      required this.totalAmount,
      required this.date,
      final List<ReceiptItem> items = const [],
      this.confidenceScore = 0.0,
      this.isAiEnhanced = false})
      : _items = items;

  factory _$ScannedReceiptImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScannedReceiptImplFromJson(json);

  @override
  final String merchantName;
  @override
  final double totalAmount;
  @override
  final DateTime? date;
  final List<ReceiptItem> _items;
  @override
  @JsonKey()
  List<ReceiptItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final double confidenceScore;
  @override
  @JsonKey()
  final bool isAiEnhanced;

  @override
  String toString() {
    return 'ScannedReceipt(merchantName: $merchantName, totalAmount: $totalAmount, date: $date, items: $items, confidenceScore: $confidenceScore, isAiEnhanced: $isAiEnhanced)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScannedReceiptImpl &&
            (identical(other.merchantName, merchantName) ||
                other.merchantName == merchantName) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.confidenceScore, confidenceScore) ||
                other.confidenceScore == confidenceScore) &&
            (identical(other.isAiEnhanced, isAiEnhanced) ||
                other.isAiEnhanced == isAiEnhanced));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      merchantName,
      totalAmount,
      date,
      const DeepCollectionEquality().hash(_items),
      confidenceScore,
      isAiEnhanced);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScannedReceiptImplCopyWith<_$ScannedReceiptImpl> get copyWith =>
      __$$ScannedReceiptImplCopyWithImpl<_$ScannedReceiptImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScannedReceiptImplToJson(
      this,
    );
  }
}

abstract class _ScannedReceipt implements ScannedReceipt {
  const factory _ScannedReceipt(
      {required final String merchantName,
      required final double totalAmount,
      required final DateTime? date,
      final List<ReceiptItem> items,
      final double confidenceScore,
      final bool isAiEnhanced}) = _$ScannedReceiptImpl;

  factory _ScannedReceipt.fromJson(Map<String, dynamic> json) =
      _$ScannedReceiptImpl.fromJson;

  @override
  String get merchantName;
  @override
  double get totalAmount;
  @override
  DateTime? get date;
  @override
  List<ReceiptItem> get items;
  @override
  double get confidenceScore;
  @override
  bool get isAiEnhanced;
  @override
  @JsonKey(ignore: true)
  _$$ScannedReceiptImplCopyWith<_$ScannedReceiptImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReceiptItem _$ReceiptItemFromJson(Map<String, dynamic> json) {
  return _ReceiptItem.fromJson(json);
}

/// @nodoc
mixin _$ReceiptItem {
  String get name => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReceiptItemCopyWith<ReceiptItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReceiptItemCopyWith<$Res> {
  factory $ReceiptItemCopyWith(
          ReceiptItem value, $Res Function(ReceiptItem) then) =
      _$ReceiptItemCopyWithImpl<$Res, ReceiptItem>;
  @useResult
  $Res call({String name, double price, int quantity, double confidence});
}

/// @nodoc
class _$ReceiptItemCopyWithImpl<$Res, $Val extends ReceiptItem>
    implements $ReceiptItemCopyWith<$Res> {
  _$ReceiptItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? price = null,
    Object? quantity = null,
    Object? confidence = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReceiptItemImplCopyWith<$Res>
    implements $ReceiptItemCopyWith<$Res> {
  factory _$$ReceiptItemImplCopyWith(
          _$ReceiptItemImpl value, $Res Function(_$ReceiptItemImpl) then) =
      __$$ReceiptItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, double price, int quantity, double confidence});
}

/// @nodoc
class __$$ReceiptItemImplCopyWithImpl<$Res>
    extends _$ReceiptItemCopyWithImpl<$Res, _$ReceiptItemImpl>
    implements _$$ReceiptItemImplCopyWith<$Res> {
  __$$ReceiptItemImplCopyWithImpl(
      _$ReceiptItemImpl _value, $Res Function(_$ReceiptItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? price = null,
    Object? quantity = null,
    Object? confidence = null,
  }) {
    return _then(_$ReceiptItemImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReceiptItemImpl implements _ReceiptItem {
  const _$ReceiptItemImpl(
      {required this.name,
      required this.price,
      this.quantity = 1,
      this.confidence = 0.0});

  factory _$ReceiptItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReceiptItemImplFromJson(json);

  @override
  final String name;
  @override
  final double price;
  @override
  @JsonKey()
  final int quantity;
  @override
  @JsonKey()
  final double confidence;

  @override
  String toString() {
    return 'ReceiptItem(name: $name, price: $price, quantity: $quantity, confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceiptItemImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, price, quantity, confidence);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReceiptItemImplCopyWith<_$ReceiptItemImpl> get copyWith =>
      __$$ReceiptItemImplCopyWithImpl<_$ReceiptItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReceiptItemImplToJson(
      this,
    );
  }
}

abstract class _ReceiptItem implements ReceiptItem {
  const factory _ReceiptItem(
      {required final String name,
      required final double price,
      final int quantity,
      final double confidence}) = _$ReceiptItemImpl;

  factory _ReceiptItem.fromJson(Map<String, dynamic> json) =
      _$ReceiptItemImpl.fromJson;

  @override
  String get name;
  @override
  double get price;
  @override
  int get quantity;
  @override
  double get confidence;
  @override
  @JsonKey(ignore: true)
  _$$ReceiptItemImplCopyWith<_$ReceiptItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
