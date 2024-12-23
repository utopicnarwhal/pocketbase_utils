import 'package:json_annotation/json_annotation.dart';
import 'package:code_builder/code_builder.dart' as code_builder;
import 'package:pocketbase_utils/src/templates/date_time_json_methods.dart';
import 'package:pocketbase_utils/src/utils/string_utils.dart';
import 'package:pocketbase_utils/src/utils/utils.dart';

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

  String enumTypeName(String className) => '$className${name.capFirstChar()}Enum';

  code_builder.Reference fieldTypeRef(String className, {forceNullable = false}) {
    var fieldTypeRef = switch (type) {
      FieldType.text || FieldType.editor || FieldType.email || FieldType.url => 'String',
      FieldType.number => options?.noDecimal == true ? 'int' : 'double',
      FieldType.bool => 'bool',
      FieldType.date => 'DateTime',
      FieldType.select => options?.maxSelect == 1 ? enumTypeName(className) : 'List<${enumTypeName(className)}>',
      FieldType.relation => options?.maxSelect == 1 ? 'String' : 'List<String>',
      FieldType.file => options?.maxSelect == 1 ? 'String' : 'List<String>',
      FieldType.json => 'dynamic',
    };

    if ((!required || forceNullable) && fieldTypeRef != 'dynamic') {
      fieldTypeRef += '?';
    }

    return code_builder.refer(fieldTypeRef);
  }

  code_builder.Expression? fieldAnnotation(String className) {
    var result = switch (type) {
      FieldType.date => code_builder.refer('JsonKey', 'package:json_annotation/json_annotation.dart').newInstance(
          [],
          {
            'toJson': required
                ? code_builder.refer(pocketBaseDateTimeToJsonMethodName)
                : code_builder.refer(pocketBaseNullableDateTimeToJsonMethodName),
            'fromJson': required
                ? code_builder.refer(pocketBaseDateTimeFromJsonMethodName)
                : code_builder.refer(pocketBaseNullableDateTimeFromJsonMethodName),
          },
        ),
      _ => null,
    };

    return result;
  }

  code_builder.Field toCodeBuilder(String className) {
    return code_builder.Field((f) {
      final annotation = fieldAnnotation(className);

      f
        ..name = name
        ..modifier = code_builder.FieldModifier.final$
        ..type = fieldTypeRef(className)
        ..annotations.addAll([
          if (annotation != null) annotation,
        ]);
    });
  }

  List<code_builder.Field> additionalFieldOptionsAsFields() {
    return [
      if (options?.min != null)
        code_builder.Field((f) => f
          ..static = true
          ..modifier = code_builder.FieldModifier.constant
          ..name = '${name}MinValue'
          ..assignment = code_builder.Code(options!.min.toString())),
      if (options?.max != null)
        code_builder.Field((f) => f
          ..static = true
          ..modifier = code_builder.FieldModifier.constant
          ..name = '${name}MaxValue'
          ..assignment = code_builder.Code(options!.max.toString()))
    ];
  }
}

@JsonSerializable()
class FieldOptions {
  const FieldOptions({
    required this.min,
    required this.max,
    required this.noDecimal,
    required this.maxSelect,
    required this.values,
  });

  final int? maxSelect;
  @JsonKey(fromJson: jsonValueParseToInt)
  final int? min;
  @JsonKey(fromJson: jsonValueParseToInt)
  final int? max;
  final bool? noDecimal;
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
