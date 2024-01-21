part of '../collection.dart';

code_builder.Method _takeDiffMethod(String className, Iterable<Field> allFieldsExceptHidden) {
  return code_builder.Method((m) => m
    ..returns = code_builder.refer('Map<String, dynamic>')
    ..name = 'takeDiff'
    ..optionalParameters.addAll([
      for (final field in allFieldsExceptHidden.where((f) => !baseFields.contains(f)))
        code_builder.Parameter((p) => p
          ..named = true
          ..name = field.name
          ..type = field.fieldTypeRef(className, forceNullable: true)),
    ])
    ..body = code_builder.Block(
      (bb) => bb
        ..statements.addAll([
          code_builder
              .declareFinal('result', type: code_builder.refer('Map<String, dynamic>'))
              .assign(code_builder.literalMap({}))
              .statement,
          code_builder
              .declareFinal('deepCollectionEquality',
                  type: code_builder.refer('DeepCollectionEquality', 'package:collection/collection.dart'))
              .assign(
                  code_builder.refer('DeepCollectionEquality', 'package:collection/collection.dart').newInstance([]))
              .statement,
          for (final field in allFieldsExceptHidden.where((f) => !baseFields.contains(f)))
            ifStatement(
              code_builder.refer(field.name).notEqualTo(code_builder.literalNull).and(code_builder
                  .refer('deepCollectionEquality')
                  .property('equals')
                  .call([code_builder.refer('this.${field.name}'), code_builder.refer(field.name)]).negate()),
              code_builder.refer('result').property('addAll').call([
                code_builder.literalMap({
                  code_builder.refer('${className}FieldsEnum.${field.name}.name'): field.type != FieldType.date
                      ? code_builder.refer(field.name)
                      : code_builder
                          .refer(field.name)
                          .isNotA(code_builder.refer('EmptyDateTime', 'empty_values.dart'))
                          .conditional(code_builder.refer(field.name), code_builder.literalNull)
                })
              ]).statement,
            ),
          code_builder.refer('result').returned.statement,
        ]),
    ));
}
