import 'package:json_annotation/json_annotation.dart';
import 'package:code_builder/code_builder.dart' as code_builder;

part 'field.g.dart';

enum FieldType {
  text,
  editor,
  number,
  bool,
  email,
  url,
  date,
  select,
  relation,
  file,
  json,
}

@JsonSerializable()
final class Field {
  const Field({
    required this.name,
    required this.type,
    required this.required,
    this.id,
    this.options,
    this.hiddenSystem = false,
    this.docs,
  });

  final String? id;
  final String name;
  final FieldType type;
  final bool required;
  final FieldOptions? options;
  final bool hiddenSystem;
  final String? docs;

  factory Field.fromJson(Map<String, dynamic> json) => _$FieldFromJson(json);

  Map<String, dynamic> toJson() => _$FieldToJson(this);

  code_builder.Field toCodeBuilder() {
    var fieldTypeRef = switch (type) {
      FieldType.text || FieldType.editor || FieldType.email || FieldType.url => 'String',
      FieldType.number => 'int',
      FieldType.bool => 'bool',
      FieldType.date => 'DateTime',
      FieldType.select => options?.maxSelect == 1 ? 'String' : 'List<String>',
      FieldType.relation => options?.maxSelect == 1 ? 'String' : 'List<String>',
      FieldType.file => options?.maxSelect == 1 ? 'String' : 'List<String>',
      FieldType.json => 'dynamic',
    };

    if (!required && fieldTypeRef != 'dynamic') {
      fieldTypeRef += '?';
    }

    return code_builder.Field((f) => f
      ..name = name
      ..modifier = code_builder.FieldModifier.final$
      ..type = code_builder.refer(fieldTypeRef));
  }
}

@JsonSerializable()
class FieldOptions {
  const FieldOptions({required this.maxSelect, required this.values});

  final int? maxSelect;
  final List<String>? values;

  factory FieldOptions.fromJson(Map<String, dynamic> json) => _$FieldOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$FieldOptionsToJson(this);
}

const baseFields = [
  Field(
    name: 'id',
    type: FieldType.text,
    required: true,
  ),
  Field(
    name: 'created',
    type: FieldType.date,
    required: true,
  ),
  Field(
    name: 'updated',
    type: FieldType.date,
    required: true,
  ),
  Field(
    name: 'collectionId',
    type: FieldType.text,
    required: true,
  ),
  Field(
    name: 'collectionName',
    type: FieldType.text,
    required: true,
  ),
];

const authFields = [
  ...baseFields,
  Field(
    name: 'username',
    type: FieldType.text,
    required: true,
  ),
  Field(
    name: 'email',
    type: FieldType.email,
    required: true,
  ),
  Field(
    name: 'emailVisibility',
    type: FieldType.bool,
    required: true,
  ),
  Field(
    name: 'verified',
    type: FieldType.bool,
    required: true,
  ),
  Field(
    name: 'password',
    type: FieldType.text,
    hiddenSystem: true,
    required: false,
    docs: '/// THIS FIELD IS ONLY FOR CREATING AN AUTH TYPE RECORD',
  ),
  Field(
    name: 'passwordConfirm',
    type: FieldType.text,
    hiddenSystem: true,
    required: true,
    docs: '/// THIS FIELD IS ONLY FOR CREATING AN AUTH TYPE RECORD',
  ),
];
