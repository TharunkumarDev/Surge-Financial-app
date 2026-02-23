// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_transaction.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAutoTransactionCollection on Isar {
  IsarCollection<AutoTransaction> get autoTransactions => this.collection();
}

const AutoTransactionSchema = CollectionSchema(
  name: r'AutoTransaction',
  id: -8295670207841270771,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.double,
    ),
    r'hash': PropertySchema(
      id: 1,
      name: r'hash',
      type: IsarType.string,
    ),
    r'isIgnored': PropertySchema(
      id: 2,
      name: r'isIgnored',
      type: IsarType.bool,
    ),
    r'isProcessed': PropertySchema(
      id: 3,
      name: r'isProcessed',
      type: IsarType.bool,
    ),
    r'merchantName': PropertySchema(
      id: 4,
      name: r'merchantName',
      type: IsarType.string,
    ),
    r'originalSmsBody': PropertySchema(
      id: 5,
      name: r'originalSmsBody',
      type: IsarType.string,
    ),
    r'receivedAt': PropertySchema(
      id: 6,
      name: r'receivedAt',
      type: IsarType.dateTime,
    ),
    r'senderId': PropertySchema(
      id: 7,
      name: r'senderId',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 8,
      name: r'type',
      type: IsarType.byte,
      enumMap: _AutoTransactiontypeEnumValueMap,
    )
  },
  estimateSize: _autoTransactionEstimateSize,
  serialize: _autoTransactionSerialize,
  deserialize: _autoTransactionDeserialize,
  deserializeProp: _autoTransactionDeserializeProp,
  idName: r'id',
  indexes: {
    r'hash': IndexSchema(
      id: -7973251393006690288,
      name: r'hash',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'hash',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _autoTransactionGetId,
  getLinks: _autoTransactionGetLinks,
  attach: _autoTransactionAttach,
  version: '3.1.0+1',
);

int _autoTransactionEstimateSize(
  AutoTransaction object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.hash.length * 3;
  {
    final value = object.merchantName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.originalSmsBody.length * 3;
  bytesCount += 3 + object.senderId.length * 3;
  return bytesCount;
}

void _autoTransactionSerialize(
  AutoTransaction object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeString(offsets[1], object.hash);
  writer.writeBool(offsets[2], object.isIgnored);
  writer.writeBool(offsets[3], object.isProcessed);
  writer.writeString(offsets[4], object.merchantName);
  writer.writeString(offsets[5], object.originalSmsBody);
  writer.writeDateTime(offsets[6], object.receivedAt);
  writer.writeString(offsets[7], object.senderId);
  writer.writeByte(offsets[8], object.type.index);
}

AutoTransaction _autoTransactionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AutoTransaction(
    amount: reader.readDoubleOrNull(offsets[0]),
    hash: reader.readString(offsets[1]),
    isIgnored: reader.readBoolOrNull(offsets[2]) ?? false,
    isProcessed: reader.readBoolOrNull(offsets[3]) ?? false,
    merchantName: reader.readStringOrNull(offsets[4]),
    originalSmsBody: reader.readString(offsets[5]),
    receivedAt: reader.readDateTime(offsets[6]),
    senderId: reader.readString(offsets[7]),
    type: _AutoTransactiontypeValueEnumMap[reader.readByteOrNull(offsets[8])] ??
        TransactionType.unknown,
  );
  object.id = id;
  return object;
}

P _autoTransactionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (_AutoTransactiontypeValueEnumMap[reader.readByteOrNull(offset)] ??
          TransactionType.unknown) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AutoTransactiontypeEnumValueMap = {
  'debit': 0,
  'credit': 1,
  'unknown': 2,
};
const _AutoTransactiontypeValueEnumMap = {
  0: TransactionType.debit,
  1: TransactionType.credit,
  2: TransactionType.unknown,
};

Id _autoTransactionGetId(AutoTransaction object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _autoTransactionGetLinks(AutoTransaction object) {
  return [];
}

void _autoTransactionAttach(
    IsarCollection<dynamic> col, Id id, AutoTransaction object) {
  object.id = id;
}

extension AutoTransactionByIndex on IsarCollection<AutoTransaction> {
  Future<AutoTransaction?> getByHash(String hash) {
    return getByIndex(r'hash', [hash]);
  }

  AutoTransaction? getByHashSync(String hash) {
    return getByIndexSync(r'hash', [hash]);
  }

  Future<bool> deleteByHash(String hash) {
    return deleteByIndex(r'hash', [hash]);
  }

  bool deleteByHashSync(String hash) {
    return deleteByIndexSync(r'hash', [hash]);
  }

  Future<List<AutoTransaction?>> getAllByHash(List<String> hashValues) {
    final values = hashValues.map((e) => [e]).toList();
    return getAllByIndex(r'hash', values);
  }

  List<AutoTransaction?> getAllByHashSync(List<String> hashValues) {
    final values = hashValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'hash', values);
  }

  Future<int> deleteAllByHash(List<String> hashValues) {
    final values = hashValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'hash', values);
  }

  int deleteAllByHashSync(List<String> hashValues) {
    final values = hashValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'hash', values);
  }

  Future<Id> putByHash(AutoTransaction object) {
    return putByIndex(r'hash', object);
  }

  Id putByHashSync(AutoTransaction object, {bool saveLinks = true}) {
    return putByIndexSync(r'hash', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByHash(List<AutoTransaction> objects) {
    return putAllByIndex(r'hash', objects);
  }

  List<Id> putAllByHashSync(List<AutoTransaction> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'hash', objects, saveLinks: saveLinks);
  }
}

extension AutoTransactionQueryWhereSort
    on QueryBuilder<AutoTransaction, AutoTransaction, QWhere> {
  QueryBuilder<AutoTransaction, AutoTransaction, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AutoTransactionQueryWhere
    on QueryBuilder<AutoTransaction, AutoTransaction, QWhereClause> {
  QueryBuilder<AutoTransaction, AutoTransaction, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterWhereClause> hashEqualTo(
      String hash) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'hash',
        value: [hash],
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterWhereClause>
      hashNotEqualTo(String hash) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hash',
              lower: [],
              upper: [hash],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hash',
              lower: [hash],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hash',
              lower: [hash],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hash',
              lower: [],
              upper: [hash],
              includeUpper: false,
            ));
      }
    });
  }
}

extension AutoTransactionQueryFilter
    on QueryBuilder<AutoTransaction, AutoTransaction, QFilterCondition> {
  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      amountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'amount',
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      amountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'amount',
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      amountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      amountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      amountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      amountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      hashEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      hashGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      hashLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      hashBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      hashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      hashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      hashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      hashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      hashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hash',
        value: '',
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      hashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hash',
        value: '',
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      isIgnoredEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isIgnored',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      isProcessedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isProcessed',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      merchantNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'merchantName',
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      merchantNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'merchantName',
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      merchantNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'merchantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      merchantNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'merchantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      merchantNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'merchantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      merchantNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'merchantName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      merchantNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'merchantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      merchantNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'merchantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      merchantNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'merchantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      merchantNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'merchantName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      merchantNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'merchantName',
        value: '',
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      merchantNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'merchantName',
        value: '',
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      originalSmsBodyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalSmsBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      originalSmsBodyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'originalSmsBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      originalSmsBodyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'originalSmsBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      originalSmsBodyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'originalSmsBody',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      originalSmsBodyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'originalSmsBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      originalSmsBodyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'originalSmsBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      originalSmsBodyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'originalSmsBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      originalSmsBodyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'originalSmsBody',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      originalSmsBodyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalSmsBody',
        value: '',
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      originalSmsBodyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'originalSmsBody',
        value: '',
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      receivedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receivedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      receivedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'receivedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      receivedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'receivedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      receivedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'receivedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      senderIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      senderIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      senderIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      senderIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'senderId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      senderIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      senderIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      senderIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      senderIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      senderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderId',
        value: '',
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      senderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderId',
        value: '',
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      typeEqualTo(TransactionType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      typeGreaterThan(
    TransactionType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      typeLessThan(
    TransactionType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterFilterCondition>
      typeBetween(
    TransactionType lower,
    TransactionType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AutoTransactionQueryObject
    on QueryBuilder<AutoTransaction, AutoTransaction, QFilterCondition> {}

extension AutoTransactionQueryLinks
    on QueryBuilder<AutoTransaction, AutoTransaction, QFilterCondition> {}

extension AutoTransactionQuerySortBy
    on QueryBuilder<AutoTransaction, AutoTransaction, QSortBy> {
  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy> sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy> sortByHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.asc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      sortByHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.desc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      sortByIsIgnored() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isIgnored', Sort.asc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      sortByIsIgnoredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isIgnored', Sort.desc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      sortByIsProcessed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProcessed', Sort.asc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      sortByIsProcessedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProcessed', Sort.desc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      sortByMerchantName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantName', Sort.asc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      sortByMerchantNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantName', Sort.desc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      sortByOriginalSmsBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalSmsBody', Sort.asc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      sortByOriginalSmsBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalSmsBody', Sort.desc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      sortByReceivedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedAt', Sort.asc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      sortByReceivedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedAt', Sort.desc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      sortBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      sortBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension AutoTransactionQuerySortThenBy
    on QueryBuilder<AutoTransaction, AutoTransaction, QSortThenBy> {
  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy> thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy> thenByHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.asc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      thenByHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.desc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      thenByIsIgnored() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isIgnored', Sort.asc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      thenByIsIgnoredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isIgnored', Sort.desc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      thenByIsProcessed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProcessed', Sort.asc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      thenByIsProcessedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProcessed', Sort.desc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      thenByMerchantName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantName', Sort.asc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      thenByMerchantNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantName', Sort.desc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      thenByOriginalSmsBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalSmsBody', Sort.asc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      thenByOriginalSmsBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalSmsBody', Sort.desc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      thenByReceivedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedAt', Sort.asc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      thenByReceivedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedAt', Sort.desc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      thenBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      thenBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension AutoTransactionQueryWhereDistinct
    on QueryBuilder<AutoTransaction, AutoTransaction, QDistinct> {
  QueryBuilder<AutoTransaction, AutoTransaction, QDistinct> distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QDistinct> distinctByHash(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QDistinct>
      distinctByIsIgnored() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isIgnored');
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QDistinct>
      distinctByIsProcessed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isProcessed');
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QDistinct>
      distinctByMerchantName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'merchantName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QDistinct>
      distinctByOriginalSmsBody({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originalSmsBody',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QDistinct>
      distinctByReceivedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receivedAt');
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QDistinct> distinctBySenderId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutoTransaction, AutoTransaction, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension AutoTransactionQueryProperty
    on QueryBuilder<AutoTransaction, AutoTransaction, QQueryProperty> {
  QueryBuilder<AutoTransaction, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AutoTransaction, double?, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<AutoTransaction, String, QQueryOperations> hashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hash');
    });
  }

  QueryBuilder<AutoTransaction, bool, QQueryOperations> isIgnoredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isIgnored');
    });
  }

  QueryBuilder<AutoTransaction, bool, QQueryOperations> isProcessedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isProcessed');
    });
  }

  QueryBuilder<AutoTransaction, String?, QQueryOperations>
      merchantNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'merchantName');
    });
  }

  QueryBuilder<AutoTransaction, String, QQueryOperations>
      originalSmsBodyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalSmsBody');
    });
  }

  QueryBuilder<AutoTransaction, DateTime, QQueryOperations>
      receivedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receivedAt');
    });
  }

  QueryBuilder<AutoTransaction, String, QQueryOperations> senderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderId');
    });
  }

  QueryBuilder<AutoTransaction, TransactionType, QQueryOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
