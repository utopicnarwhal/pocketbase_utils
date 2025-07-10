import 'package:code_builder/code_builder.dart' as code_builder;
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pocketbase_utils/src/schema/field.dart';
import 'package:pocketbase_utils/src/templates/do_not_modify_by_hand.dart';
import 'package:pocketbase_utils/src/utils/code_builder.dart';
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
    required this.system,
    required this.fields,
  });

  factory Collection.fromJson(Map<String, dynamic> json) => _$CollectionFromJson(json);

  final String id;
  final String name;
  final CollectionType type;
  final bool system;
  final List<Field> fields;

  Map<String, dynamic> toJson() => _$CollectionToJson(this);

  String generateClassCode(String fileName, int lineLength) {
    final code_builder.Reference? extend;
    final superFields = <Field>[];

    /// A list of fields that has to be overridden in the generated class
    final fieldsToOverride = <Field>[];

    switch (type) {
      case CollectionType.base:
        extend = code_builder.refer('BaseRecord', 'base_record.dart');
        superFields.addAll(baseFields);
      case CollectionType.auth:
        extend = code_builder.refer('AuthRecord', 'auth_record.dart');

        /// We override the "email" field to a non-nullable one in case when
        /// the schema has both "email" and "emailVisibility" fields set to "required"
        /// because otherwise it can be hidden from the API response or be null.
        final isEmailFieldInSchemaRequired = fields.firstWhereOrNull((e) => e.name == 'email')?.required == true &&
            fields.firstWhereOrNull((e) => e.name == 'emailVisibility')?.required == true;

        if (isEmailFieldInSchemaRequired) {
          for (final field in authFields) {
            if (field.name == 'email') {
              fieldsToOverride.add(field);
            } else {
              superFields.add(field);
            }
          }
        } else {
          superFields.addAll(authFields);
        }
      case CollectionType.view:
        return '';
    }

    final fieldsWithoutSuperFields = fields.whereNot((f) => superFields.any((sf) => sf.name == f.name)).toList();
    final fieldsWithoutSuperFieldsAndHidden = fieldsWithoutSuperFields.whereNot((f) => f.hidden).toList()
      ..sort((a, b) => a.required == b.required ? 0 : (a.required == true ? -1 : 1));

    final superFieldsWithoutHidden = superFields.whereNot((f) => f.hidden).toList();

    final allFieldsWithoutHidden = [...superFieldsWithoutHidden, ...fieldsWithoutSuperFieldsAndHidden].toList();

    final className = '${ReCase(name).pascalCase}Record';

    final enumFieldsCode = code_builder.Enum(
      (e) => e
        ..name = '${className}FieldsEnum'
        ..fields.addAll([
          code_builder.Field(
            (f) => f
              ..name = 'nameInSchema'
              ..modifier = code_builder.FieldModifier.final$
              ..type = code_builder.refer('String'),
          )
        ])
        ..constructors.add(
          code_builder.Constructor(
            (co) => co
              ..constant = true
              ..requiredParameters.add(code_builder.Parameter((p) => p
                ..toThis = true
                ..name = 'nameInSchema')),
          ),
        )
        ..values.addAll([
          for (final field in allFieldsWithoutHidden)
            code_builder.EnumValue(
              (ev) => ev
                ..name = field.nameInCamelCase
                ..arguments.add(code_builder.literalString(field.name))
                ..docs.addAll([if (field.docs != null) field.docs!]),
            ),
          for (final field in [...fieldsWithoutSuperFields, ...superFields].where((f) => f.hidden))
            code_builder.EnumValue(
              (ev) => ev
                ..name = 'hidden\$${field.nameInCamelCase}'
                ..arguments.add(code_builder.literalString(field.name))
                ..docs.addAll([if (field.docs != null) field.docs!]),
            ),
        ]),
    );

    final enumSelectValuesCode = [
      for (final field
          in allFieldsWithoutHidden.where((f) => f.type == FieldType.select && f.values?.isNotEmpty == true))
        code_builder.Enum(
          (e) => e
            ..name = field.enumTypeName(className)
            ..fields.addAll([
              code_builder.Field(
                (f) => f
                  ..name = 'nameInSchema'
                  ..modifier = code_builder.FieldModifier.final$
                  ..type = code_builder.refer('String'),
              )
            ])
            ..constructors.add(
              code_builder.Constructor(
                (co) => co
                  ..constant = true
                  ..requiredParameters.add(code_builder.Parameter((p) => p
                    ..toThis = true
                    ..name = 'nameInSchema')),
              ),
            )
            ..values.addAll([
              if (field.values != null)
                for (final value in field.values!)
                  code_builder.EnumValue((ev) => ev
                    ..name = ReCase(value).camelCase
                    ..arguments.add(code_builder.literalString(value))
                    ..annotations.add(
                      code_builder
                          .refer('JsonValue', 'package:json_annotation/json_annotation.dart')
                          .newInstance([code_builder.literalString(value)]),
                    )),
            ]),
        ),
    ];

    final classCode = code_builder.Class(
      (c) => c
        ..name = className
        ..extend = extend
        ..modifier = code_builder.ClassModifier.final$
        ..annotations
            .add(code_builder.refer('JsonSerializable', 'package:json_annotation/json_annotation.dart').newInstance([]))
        ..fields.addAll([
          for (final field in fieldsWithoutSuperFieldsAndHidden) ...[
            field.toCodeBuilder(
              className,
              shouldOverride: fieldsToOverride.any((e) => e.name == field.name),
            ),
            ...field.additionalFieldOptionsAsFields(),
          ],
          for (final staticCollectionRefFieldName in ['collectionId', 'collectionName'])
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
          _defaultConstructor(superFieldsWithoutHidden, fieldsWithoutSuperFieldsAndHidden, fieldsToOverride),
          _fromJsonConstructor(className),
          _fromRecordModelConstructor(className),
        ])
        ..methods.addAll([
          _toJsonMethod(className),
          _copyWithMethod(className, allFieldsWithoutHidden),
          _takeDiffMethod(className, allFieldsWithoutHidden),
          _propsMethod(fieldsWithoutSuperFieldsAndHidden),
          _forCreateRequestMethod(className, allFieldsWithoutHidden),
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
        ..ignoreForFile.add('unused_import')
        ..directives.addAll([
          code_builder.Directive.part('$fileName.g.dart'),
          // We need to always import these to make the import directives in `$fileName.g.dart` work
          // The `refer` method makes the imports with ending `import '...' as _i1` which breakes the improrts in part file
          code_builder.Directive.import('date_time_json_methods.dart'),
          code_builder.Directive.import('geo_point_class.dart'),
          code_builder.Directive.import('package:json_annotation/json_annotation.dart'),
        ]),
    );

    final emitter = code_builder.DartEmitter.scoped(
      useNullSafetySyntax: true,
      orderDirectives: true,
    );

    return DartFormatter(
      languageVersion: DartFormatter.latestShortStyleLanguageVersion,
      pageWidth: lineLength,
    ).format('${libraryCode.accept(emitter)}');
  }
}
