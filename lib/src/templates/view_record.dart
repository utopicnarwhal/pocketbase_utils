import 'package:code_builder/code_builder.dart' as code_builder;
import 'package:dart_style/dart_style.dart';
import 'package:pocketbase_utils/src/schema/field.dart';
import 'package:pocketbase_utils/src/templates/do_not_modify_by_hand.dart';

/// Base class for PocketBase view collection records.
/// Views are read-only collections that aggregate data from other collections.
abstract base class ViewRecord {
  const ViewRecord({
    required this.id,
    required this.collectionId,
    required this.collectionName,
  });

  /// The unique identifier of the record.
  final String id;

  /// The identifier of the collection this record belongs to.
  final String collectionId;

  /// The name of the collection this record belongs to.
  final String collectionName;

  /// Override this in subclasses to provide props for Equatable
  List<Object?> get props => [id, collectionId, collectionName];
}

/// Fields that are available on all view records.
const viewFields = [
  Field(
    name: 'id',
    type: FieldType.text,
    required: true,
    system: true,
  ),
  Field(
    name: 'collectionId',
    type: FieldType.text,
    required: true,
    system: true,
  ),
  Field(
    name: 'collectionName',
    type: FieldType.text,
    required: true,
    system: true,
  ),
];

String viewRecordClassGenerator(int lineLength) {
  const className = 'ViewRecord';

  final classCode = code_builder.Class(
    (c) => c
      ..name = className
      ..abstract = true
      ..modifier = code_builder.ClassModifier.base
      ..extend = code_builder.refer('Equatable', 'package:equatable/equatable.dart')
      ..fields.addAll([
        for (final field in viewFields) field.toCodeBuilder(className),
      ])
      ..constructors.addAll([
        code_builder.Constructor((d) => d
          ..constant = true
          ..optionalParameters.addAll([
            for (final field in viewFields)
              code_builder.Parameter(
                (p) => p
                  ..toThis = true
                  ..name = field.nameInCamelCase
                  ..named = true
                  ..required = field.isNonNullable,
              ),
          ])),
      ])
      ..methods.addAll([
        code_builder.Method((m) => m
          ..annotations.add(code_builder.refer('override'))
          ..returns = code_builder.refer('List<Object?>')
          ..type = code_builder.MethodType.getter
          ..name = 'props'
          ..lambda = true
          ..body = code_builder.literalList([
            for (final field in viewFields) code_builder.refer(field.nameInCamelCase),
          ]).code),
      ]),
  );

  final libraryCode = code_builder.Library(
    (l) => l
      ..body.add(classCode)
      ..generatedByComment = doNotModifyByHandTemplate
      ..ignoreForFile.add('unused_import')
      ..directives.addAll([
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
