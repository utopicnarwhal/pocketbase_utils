// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Field _$FieldFromJson(Map<String, dynamic> json) => Field(
      name: json['name'] as String,
      type: $enumDecode(_$FieldTypeEnumMap, json['type']),
      required: json['required'] as bool,
      id: json['id'] as String?,
      options: json['options'] == null
          ? null
          : FieldOptions.fromJson(json['options'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FieldToJson(Field instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$FieldTypeEnumMap[instance.type]!,
      'required': instance.required,
      'options': instance.options?.toJson(),
    };

const _$FieldTypeEnumMap = {
  FieldType.text: 'text',
  FieldType.editor: 'editor',
  FieldType.number: 'number',
  FieldType.bool: 'bool',
  FieldType.email: 'email',
  FieldType.url: 'url',
  FieldType.date: 'date',
  FieldType.select: 'select',
  FieldType.relation: 'relation',
  FieldType.file: 'file',
  FieldType.json: 'json',
};

FieldOptions _$FieldOptionsFromJson(Map<String, dynamic> json) => FieldOptions(
      maxSelect: json['maxSelect'] as int?,
      values:
          (json['values'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$FieldOptionsToJson(FieldOptions instance) =>
    <String, dynamic>{
      'maxSelect': instance.maxSelect,
      'values': instance.values,
    };
