import 'package:code_builder/code_builder.dart' as code_builder;
import 'package:dart_style/dart_style.dart';
import 'package:pocketbase_utils/src/templates/do_not_modify_by_hand.dart';

String geoPointClassGenerator(String fileName, int lineLength) {
  final className = 'GeoPoint';

  final classCode = code_builder.Class((c) => c
    ..annotations
        .add(code_builder.refer('JsonSerializable', 'package:json_annotation/json_annotation.dart').newInstance([]))
    ..name = className
    ..extend = code_builder.refer('Equatable', 'package:equatable/equatable.dart')
    ..constructors.addAll([
      code_builder.Constructor(
        (constr) => constr.requiredParameters.addAll([
          code_builder.Parameter(
            (p) => p
              ..toThis = true
              ..name = 'lon',
          ),
          code_builder.Parameter(
            (p) => p
              ..toThis = true
              ..name = 'lat',
          ),
        ]),
      ),
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
    ])
    ..methods.addAll([
      code_builder.Method((m) => m
        ..returns = code_builder.refer('Map<String, dynamic>')
        ..name = 'toJson'
        ..lambda = true
        ..body = code_builder.Code('_\$${className}ToJson(this)')),
      code_builder.Method((m) => m
        ..annotations.add(code_builder.refer('override'))
        ..returns = code_builder.refer('List<Object?>')
        ..type = code_builder.MethodType.getter
        ..name = 'props'
        ..lambda = true
        ..body = code_builder.literalList([
          code_builder.refer('lat'),
          code_builder.refer('lon'),
        ]).code),
    ])
    ..fields.addAll([
      code_builder.Field((f) => f
        ..modifier = code_builder.FieldModifier.final$
        ..type = code_builder.refer('double')
        ..name = 'lon'),
      code_builder.Field((f) => f
        ..modifier = code_builder.FieldModifier.final$
        ..type = code_builder.refer('double')
        ..name = 'lat')
    ]));

  final libraryCode = code_builder.Library(
    (l) => l
      ..body.add(classCode)
      ..generatedByComment = doNotModifyByHandTemplate
      ..directives.add(code_builder.Directive.part('$fileName.g.dart')),
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
