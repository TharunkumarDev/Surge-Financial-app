// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_image_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBillImageCollection on Isar {
  IsarCollection<BillImage> get billImages => this.collection();
}

const BillImageSchema = CollectionSchema(
  name: r'BillImage',
  id: 3919430896880918233,
  properties: {
    r'cloudUrl': PropertySchema(
      id: 0,
      name: r'cloudUrl',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'expenseId': PropertySchema(
      id: 2,
      name: r'expenseId',
      type: IsarType.long,
    ),
    r'imageId': PropertySchema(
      id: 3,
      name: r'imageId',
      type: IsarType.string,
    ),
    r'isUploaded': PropertySchema(
      id: 4,
      name: r'isUploaded',
      type: IsarType.bool,
    ),
    r'localPath': PropertySchema(
      id: 5,
      name: r'localPath',
      type: IsarType.string,
    ),
    r'ocrText': PropertySchema(
      id: 6,
      name: r'ocrText',
      type: IsarType.string,
    ),
    r'thumbnailPath': PropertySchema(
      id: 7,
      name: r'thumbnailPath',
      type: IsarType.string,
    ),
    r'uploadFailed': PropertySchema(
      id: 8,
      name: r'uploadFailed',
      type: IsarType.bool,
    ),
    r'uploadedAt': PropertySchema(
      id: 9,
      name: r'uploadedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _billImageEstimateSize,
  serialize: _billImageSerialize,
  deserialize: _billImageDeserialize,
  deserializeProp: _billImageDeserializeProp,
  idName: r'id',
  indexes: {
    r'expenseId': IndexSchema(
      id: -8289172275633362361,
      name: r'expenseId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'expenseId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _billImageGetId,
  getLinks: _billImageGetLinks,
  attach: _billImageAttach,
  version: '3.1.0+1',
);

int _billImageEstimateSize(
  BillImage object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.cloudUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.imageId.length * 3;
  {
    final value = object.localPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.ocrText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.thumbnailPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _billImageSerialize(
  BillImage object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cloudUrl);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeLong(offsets[2], object.expenseId);
  writer.writeString(offsets[3], object.imageId);
  writer.writeBool(offsets[4], object.isUploaded);
  writer.writeString(offsets[5], object.localPath);
  writer.writeString(offsets[6], object.ocrText);
  writer.writeString(offsets[7], object.thumbnailPath);
  writer.writeBool(offsets[8], object.uploadFailed);
  writer.writeDateTime(offsets[9], object.uploadedAt);
}

BillImage _billImageDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BillImage();
  object.cloudUrl = reader.readStringOrNull(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.expenseId = reader.readLong(offsets[2]);
  object.id = id;
  object.imageId = reader.readString(offsets[3]);
  object.isUploaded = reader.readBool(offsets[4]);
  object.localPath = reader.readStringOrNull(offsets[5]);
  object.ocrText = reader.readStringOrNull(offsets[6]);
  object.thumbnailPath = reader.readStringOrNull(offsets[7]);
  object.uploadFailed = reader.readBool(offsets[8]);
  object.uploadedAt = reader.readDateTimeOrNull(offsets[9]);
  return object;
}

P _billImageDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _billImageGetId(BillImage object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _billImageGetLinks(BillImage object) {
  return [];
}

void _billImageAttach(IsarCollection<dynamic> col, Id id, BillImage object) {
  object.id = id;
}

extension BillImageQueryWhereSort
    on QueryBuilder<BillImage, BillImage, QWhere> {
  QueryBuilder<BillImage, BillImage, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterWhere> anyExpenseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'expenseId'),
      );
    });
  }
}

extension BillImageQueryWhere
    on QueryBuilder<BillImage, BillImage, QWhereClause> {
  QueryBuilder<BillImage, BillImage, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<BillImage, BillImage, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterWhereClause> idBetween(
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

  QueryBuilder<BillImage, BillImage, QAfterWhereClause> expenseIdEqualTo(
      int expenseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'expenseId',
        value: [expenseId],
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterWhereClause> expenseIdNotEqualTo(
      int expenseId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'expenseId',
              lower: [],
              upper: [expenseId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'expenseId',
              lower: [expenseId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'expenseId',
              lower: [expenseId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'expenseId',
              lower: [],
              upper: [expenseId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterWhereClause> expenseIdGreaterThan(
    int expenseId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'expenseId',
        lower: [expenseId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterWhereClause> expenseIdLessThan(
    int expenseId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'expenseId',
        lower: [],
        upper: [expenseId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterWhereClause> expenseIdBetween(
    int lowerExpenseId,
    int upperExpenseId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'expenseId',
        lower: [lowerExpenseId],
        includeLower: includeLower,
        upper: [upperExpenseId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BillImageQueryFilter
    on QueryBuilder<BillImage, BillImage, QFilterCondition> {
  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> cloudUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cloudUrl',
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition>
      cloudUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cloudUrl',
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> cloudUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cloudUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> cloudUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cloudUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> cloudUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cloudUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> cloudUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cloudUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> cloudUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cloudUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> cloudUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cloudUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> cloudUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cloudUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> cloudUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cloudUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> cloudUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cloudUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition>
      cloudUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cloudUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> expenseIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expenseId',
        value: value,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition>
      expenseIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expenseId',
        value: value,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> expenseIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expenseId',
        value: value,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> expenseIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expenseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> idBetween(
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

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> imageIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> imageIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> imageIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> imageIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> imageIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> imageIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> imageIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> imageIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imageId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> imageIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageId',
        value: '',
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition>
      imageIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imageId',
        value: '',
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> isUploadedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isUploaded',
        value: value,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> localPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localPath',
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition>
      localPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'localPath',
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> localPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition>
      localPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> localPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> localPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> localPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> localPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> localPathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> localPathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> localPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localPath',
        value: '',
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition>
      localPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localPath',
        value: '',
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> ocrTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ocrText',
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> ocrTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ocrText',
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> ocrTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ocrText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> ocrTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ocrText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> ocrTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ocrText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> ocrTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ocrText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> ocrTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ocrText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> ocrTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ocrText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> ocrTextContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ocrText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> ocrTextMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ocrText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> ocrTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ocrText',
        value: '',
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition>
      ocrTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ocrText',
        value: '',
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition>
      thumbnailPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'thumbnailPath',
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition>
      thumbnailPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'thumbnailPath',
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition>
      thumbnailPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'thumbnailPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition>
      thumbnailPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'thumbnailPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition>
      thumbnailPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'thumbnailPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition>
      thumbnailPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'thumbnailPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition>
      thumbnailPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'thumbnailPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition>
      thumbnailPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'thumbnailPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition>
      thumbnailPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'thumbnailPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition>
      thumbnailPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'thumbnailPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition>
      thumbnailPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'thumbnailPath',
        value: '',
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition>
      thumbnailPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'thumbnailPath',
        value: '',
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> uploadFailedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uploadFailed',
        value: value,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> uploadedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'uploadedAt',
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition>
      uploadedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'uploadedAt',
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> uploadedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uploadedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition>
      uploadedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uploadedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> uploadedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uploadedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterFilterCondition> uploadedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uploadedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BillImageQueryObject
    on QueryBuilder<BillImage, BillImage, QFilterCondition> {}

extension BillImageQueryLinks
    on QueryBuilder<BillImage, BillImage, QFilterCondition> {}

extension BillImageQuerySortBy on QueryBuilder<BillImage, BillImage, QSortBy> {
  QueryBuilder<BillImage, BillImage, QAfterSortBy> sortByCloudUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudUrl', Sort.asc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> sortByCloudUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudUrl', Sort.desc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> sortByExpenseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseId', Sort.asc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> sortByExpenseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseId', Sort.desc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> sortByImageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageId', Sort.asc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> sortByImageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageId', Sort.desc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> sortByIsUploaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUploaded', Sort.asc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> sortByIsUploadedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUploaded', Sort.desc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> sortByLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localPath', Sort.asc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> sortByLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localPath', Sort.desc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> sortByOcrText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocrText', Sort.asc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> sortByOcrTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocrText', Sort.desc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> sortByThumbnailPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailPath', Sort.asc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> sortByThumbnailPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailPath', Sort.desc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> sortByUploadFailed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadFailed', Sort.asc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> sortByUploadFailedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadFailed', Sort.desc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> sortByUploadedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadedAt', Sort.asc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> sortByUploadedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadedAt', Sort.desc);
    });
  }
}

extension BillImageQuerySortThenBy
    on QueryBuilder<BillImage, BillImage, QSortThenBy> {
  QueryBuilder<BillImage, BillImage, QAfterSortBy> thenByCloudUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudUrl', Sort.asc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> thenByCloudUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudUrl', Sort.desc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> thenByExpenseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseId', Sort.asc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> thenByExpenseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseId', Sort.desc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> thenByImageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageId', Sort.asc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> thenByImageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageId', Sort.desc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> thenByIsUploaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUploaded', Sort.asc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> thenByIsUploadedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUploaded', Sort.desc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> thenByLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localPath', Sort.asc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> thenByLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localPath', Sort.desc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> thenByOcrText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocrText', Sort.asc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> thenByOcrTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocrText', Sort.desc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> thenByThumbnailPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailPath', Sort.asc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> thenByThumbnailPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailPath', Sort.desc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> thenByUploadFailed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadFailed', Sort.asc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> thenByUploadFailedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadFailed', Sort.desc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> thenByUploadedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadedAt', Sort.asc);
    });
  }

  QueryBuilder<BillImage, BillImage, QAfterSortBy> thenByUploadedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadedAt', Sort.desc);
    });
  }
}

extension BillImageQueryWhereDistinct
    on QueryBuilder<BillImage, BillImage, QDistinct> {
  QueryBuilder<BillImage, BillImage, QDistinct> distinctByCloudUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cloudUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BillImage, BillImage, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<BillImage, BillImage, QDistinct> distinctByExpenseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expenseId');
    });
  }

  QueryBuilder<BillImage, BillImage, QDistinct> distinctByImageId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BillImage, BillImage, QDistinct> distinctByIsUploaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isUploaded');
    });
  }

  QueryBuilder<BillImage, BillImage, QDistinct> distinctByLocalPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BillImage, BillImage, QDistinct> distinctByOcrText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ocrText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BillImage, BillImage, QDistinct> distinctByThumbnailPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'thumbnailPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BillImage, BillImage, QDistinct> distinctByUploadFailed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uploadFailed');
    });
  }

  QueryBuilder<BillImage, BillImage, QDistinct> distinctByUploadedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uploadedAt');
    });
  }
}

extension BillImageQueryProperty
    on QueryBuilder<BillImage, BillImage, QQueryProperty> {
  QueryBuilder<BillImage, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BillImage, String?, QQueryOperations> cloudUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cloudUrl');
    });
  }

  QueryBuilder<BillImage, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<BillImage, int, QQueryOperations> expenseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expenseId');
    });
  }

  QueryBuilder<BillImage, String, QQueryOperations> imageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageId');
    });
  }

  QueryBuilder<BillImage, bool, QQueryOperations> isUploadedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isUploaded');
    });
  }

  QueryBuilder<BillImage, String?, QQueryOperations> localPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localPath');
    });
  }

  QueryBuilder<BillImage, String?, QQueryOperations> ocrTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ocrText');
    });
  }

  QueryBuilder<BillImage, String?, QQueryOperations> thumbnailPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'thumbnailPath');
    });
  }

  QueryBuilder<BillImage, bool, QQueryOperations> uploadFailedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uploadFailed');
    });
  }

  QueryBuilder<BillImage, DateTime?, QQueryOperations> uploadedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uploadedAt');
    });
  }
}
