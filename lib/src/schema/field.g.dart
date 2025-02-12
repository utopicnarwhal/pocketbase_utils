// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Field _$FieldFromJson(Map<String, dynamic> json) => Field(
      name: json['name'] as String,
      type: $enumDecode(_$FieldTypeEnumMap, json['type']),
      maxSelect: (json['maxSelect'] as num?)?.toInt(),
      min: jsonValueParseToInt(json['min']),
      max: jsonValueParseToInt(json['max']),
      onlyInt: json['onlyInt'] as bool?,
      required: json['required'] as bool?,
      id: json['id'] as String?,
      values:
          (json['values'] as List<dynamic>?)?.map((e) => e as String).toList(),
      hidden: json['hidden'] as bool? ?? false,
      system: json['system'] as bool? ?? false,
      docs: json['docs'] as String?,
    );

Map<String, dynamic> _$FieldToJson(Field instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$FieldTypeEnumMap[instance.type]!,
      'required': instance.required,
      'maxSelect': instance.maxSelect,
      'min': instance.min,
      'max': instance.max,
      'onlyInt': instance.onlyInt,
      'values': instance.values,
      'hidden': instance.hidden,
      'system': instance.system,
      'docs': instance.docs,
    };

const _$FieldTypeEnumMap = {
  FieldType.text: 'text',
  FieldType.editor: 'editor',
  FieldType.number: 'number',
  FieldType.bool: 'bool',
  FieldType.email: 'email',
  FieldType.url: 'url',
  FieldType.date: 'date',
  FieldType.autodate: 'autodate',
  FieldType.select: 'select',
  FieldType.relation: 'relation',
  FieldType.file: 'file',
  FieldType.json: 'json',
  FieldType.password: 'password',
};
