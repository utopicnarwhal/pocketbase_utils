// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Collection _$CollectionFromJson(Map<String, dynamic> json) => Collection(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$CollectionTypeEnumMap, json['type']),
      system: json['system'] as bool,
      fields: (json['fields'] as List<dynamic>)
          .map((e) => Field.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CollectionToJson(Collection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$CollectionTypeEnumMap[instance.type]!,
      'system': instance.system,
      'fields': instance.fields.map((e) => e.toJson()).toList(),
    };

const _$CollectionTypeEnumMap = {
  CollectionType.auth: 'auth',
  CollectionType.base: 'base',
  CollectionType.view: 'view',
};
