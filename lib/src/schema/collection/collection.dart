import 'package:code_builder/code_builder.dart' as code_builder;
import 'package:dart_style/dart_style.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pocketbase_utils/src/schema/field.dart';
import 'package:pocketbase_utils/src/templates/do_not_modify_by_hand.dart';
import 'package:pocketbase_utils/src/utils/code_builder.dart';
import 'package:pocketbase_utils/src/utils/string_utils.dart';
import 'package:recase/recase.dart';

part 'collection.g.dart';
part 'constructors/default.dart';
part 'constructors/from_json.dart';
part 'constructors/from_record_model.dart';
part 'methods/copy_with.dart';
part 'methods/for_create_request.dart';
part 'methods/props.dart';
part 'methods/take_diff.dart';
part 'methods/to_json.dart';

enum CollectionType {
  /// [Read more](https://pocketbase.io/docs/collections/#auth-collection)
  auth,

  /// [Read more](https://pocketbase.io/docs/collections/#base-collection)
  base,

  /// [Read more](https://pocketbase.io/docs/collections/#view-collection)
  view,
}

@JsonSerializable()
final class Collection {
  Collection({
    required this.id,
    required this.name,
    required this.type,
    required this.schema,
  });

  final String id;
  final String name;
  final CollectionType type;
  final List<Field> schema;

  factory Collection.fromJson(Map<String, dynamic> json) => _$CollectionFromJson(json);

  Map<String, dynamic> toJson() => _$CollectionToJson(this);

  String generateClassCode(String fileName, int lineLength) {
    final code_builder.Reference? extend;
    final List<Field>? superFields;

    switch (type) {
      case CollectionType.base:
        extend = code_builder.refer('BaseRecord', 'base_record.dart');
        superFields = baseFields;
      case CollectionType.auth:
        extend = code_builder.refer('AuthRecord', 'auth_record.dart');
        superFields = authFields;
      case CollectionType.view:
        return '';
    }
    schema.sort((a, b) => a.required == b.required ? 0 : (a.required ? -1 : 1));
    final allFields = [...superFields, ...schema];
    final allFieldsExceptHidden = allFields.where((f) => !f.hiddenSystem);

    final className = '${name.capFirstChar()}Record';

    final enumFieldsCode = code_builder.Enum(
      (e) => e
        ..name = '${className}FieldsEnum'
        ..values.addAll([
          for (var field in allFields)
            code_builder.EnumValue(
              (ev) => ev
                ..name = field.name
                ..docs.addAll([if (field.docs != null) field.docs!]),
            ),
        ]),
    );

    final enumSelectValuesCode = [
      for (final field in schema.where((f) => f.type == FieldType.select && f.options?.values?.isNotEmpty == true))
        code_builder.Enum(
          (e) => e
            ..name = field.enumTypeName(className)
            ..values.addAll([
              if (field.options?.values != null)
                for (final value in field.options!.values!)
                  code_builder.EnumValue((ev) => ev
                    ..name = ReCase(value).camelCase
                    ..annotations.add(code_builder.refer("JsonValue('$value')"))),
            ]),
        ),
    ];

    final classCode = code_builder.Class(
      (c) => c
        ..name = className
        ..extend = extend
        ..modifier = code_builder.ClassModifier.final$
        ..annotations.add(code_builder.refer('JsonSerializable()'))
        ..fields.addAll([
          for (var field in schema) ...[
            field.toCodeBuilder(className),
            ...field.additionalFieldOptionsAsFields(),
          ],
          for (var staticCollectionRefFieldName in ['collectionId', 'collectionName'])
            code_builder.Field(
              (f) => f
                ..name = '\$$staticCollectionRefFieldName'
                ..static = true
                ..modifier = code_builder.FieldModifier.constant
                ..assignment = code_builder
                    .literalString(switch (staticCollectionRefFieldName) {
                      'collectionName' => name,
                      'collectionId' => id,
                      _ => '',
                    })
                    .code,
            ),
        ])
        ..constructors.addAll([
          _defaultConstructor(superFields, schema),
          _fromJsonConstructor(className),
          _fromRecordModelConstructor(className),
        ])
        ..methods.addAll([
          _toJsonMethod(className),
          _copyWithMethod(className, allFieldsExceptHidden),
          _takeDiffMethod(className, allFieldsExceptHidden),
          _propsMethod(schema),
          _forCreateRequestMethod(className, allFieldsExceptHidden),
        ]),
    );

    final libraryCode = code_builder.Library(
      (l) => l
        ..body.addAll([
          enumFieldsCode,
          ...enumSelectValuesCode,
          classCode,
        ])
        ..generatedByComment = doNotModifyByHandTemplate
        ..directives.addAll([
          code_builder.Directive.part('$fileName.g.dart'),
          code_builder.Directive.import('package:json_annotation/json_annotation.dart'),
        ]),
    );

    final emitter = code_builder.DartEmitter.scoped(
      useNullSafetySyntax: true,
      orderDirectives: true,
    );

    return DartFormatter(pageWidth: lineLength).format('${libraryCode.accept(emitter)}');
  }
}
