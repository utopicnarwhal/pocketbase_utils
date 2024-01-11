import 'package:code_builder/code_builder.dart' as code_builder;
import 'package:dart_style/dart_style.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pocketbase_utils/src/schema/field.dart';
import 'package:pocketbase_utils/src/templates/do_not_modify_by_hand.dart';
import 'package:pocketbase_utils/src/utils/string_utils.dart';

part 'collection.g.dart';

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

    final enumCode = code_builder.Enum(
      (e) => e
        ..name = '${name.capFirstChar()}RecordFieldsEnum'
        ..values.addAll([
          if (superFields != null)
            for (var field in superFields)
              code_builder.EnumValue(
                (ev) => ev
                  ..name = field.name
                  ..docs.addAll([if (field.docs != null) field.docs!]),
              ),
          for (var field in schema)
            code_builder.EnumValue(
              (ev) => ev
                ..name = field.name
                ..docs.addAll([if (field.docs != null) field.docs!]),
            ),
        ]),
    );

    final className = '${name.capFirstChar()}Record';

    final classCode = code_builder.Class(
      (c) => c
        ..name = className
        ..extend = extend
        ..modifier = code_builder.ClassModifier.final$
        ..annotations.add(code_builder.refer('JsonSerializable()', 'package:json_annotation/json_annotation.dart'))
        ..fields.addAll([
          for (var field in schema) field.toCodeBuilder(),
          for (var staticCollectionRefFieldName in ['collectionId', 'collectionName'])
            code_builder.Field(
              (f) => f
                ..name = '\$$staticCollectionRefFieldName'
                ..static = true
                ..modifier = code_builder.FieldModifier.constant
                ..assignment = code_builder
                    .literalString(switch (staticCollectionRefFieldName) {
                      r'collectionName' => name,
                      r'collectionId' => id,
                      _ => '',
                    })
                    .code,
            ),
        ])
        ..constructors.addAll([
          code_builder.Constructor((d) => d
            ..optionalParameters.addAll([
              if (superFields != null)
                for (var field in superFields.where((sf) => !sf.hiddenSystem))
                  code_builder.Parameter(
                    (p) => p
                      ..name = field.name
                      ..named = true
                      ..toSuper = true
                      ..required = field.required
                      ..docs.addAll([if (field.docs != null) field.docs!]),
                  ),
              for (var field in schema)
                code_builder.Parameter(
                  (p) => p
                    ..toThis = true
                    ..name = field.name
                    ..named = true
                    ..required = field.required
                    ..docs.addAll([if (field.docs != null) field.docs!]),
                ),
            ])),
          code_builder.Constructor(
            (d) => d
              ..factory = true
              ..name = 'fromJson'
              ..lambda = true
              ..requiredParameters.add(
                code_builder.Parameter(
                  (p) => p
                    ..type = code_builder.refer('Map<String, dynamic>')
                    ..name = 'json',
                ),
              )
              ..body = code_builder.Code('_\$${className}FromJson(json)'),
          ),
          code_builder.Constructor(
            (d) => d
              ..factory = true
              ..name = 'fromRecordModel'
              ..requiredParameters.add(
                code_builder.Parameter(
                  (p) => p
                    ..type = code_builder.refer('RecordModel', 'package:pocketbase/pocketbase.dart')
                    ..name = 'recordModel',
                ),
              )
              ..body = code_builder.Block(
                (b) => b
                  ..statements.addAll([
                    code_builder
                        .declareFinal('extendedJsonMap')
                        .assign(code_builder.literalMap({
                          code_builder.literalSpread(): code_builder.refer('recordModel.data'),
                          for (var recordFieldName in ['id', 'created', 'updated', 'collectionId', 'collectionName'])
                            code_builder.refer('${className}FieldsEnum.$recordFieldName.name'):
                                code_builder.refer('recordModel.$recordFieldName'),
                        }))
                        .statement,
                    code_builder.InvokeExpression.newOf(
                      code_builder.refer('$className.fromJson'),
                      [code_builder.refer('extendedJsonMap')],
                    ).returned.statement,
                  ]),
              ),
          ),
        ])
        ..methods.addAll([
          code_builder.Method((m) => m
            ..returns = code_builder.refer('Map<String, dynamic>')
            ..name = 'toJson'
            ..lambda = true
            ..body = code_builder.Code('_\$${className}ToJson(this)')),
        ]),
    );

    final libraryCode = code_builder.Library(
      (l) => l
        ..body.addAll([
          enumCode,
          classCode,
        ])
        ..generatedByComment = doNotModifyByHandTemplate
        ..directives.add(code_builder.Directive.part('$fileName.g.dart')),
    );

    final emitter = code_builder.DartEmitter.scoped(
      useNullSafetySyntax: true,
      orderDirectives: true,
    );

    return DartFormatter(pageWidth: lineLength).format('${libraryCode.accept(emitter)}');
  }
}
