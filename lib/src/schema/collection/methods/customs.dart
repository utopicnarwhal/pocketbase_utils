part of '../collection.dart';

code_builder.Method _getExpandAndEnrich(Iterable<Field> fieldsWithoutSuperFields) {
  return code_builder.Method(
    (m) => m
      ..returns = code_builder.refer('Map<String, dynamic>?')
      ..name = 'getExpandAndEnrich'
      ..requiredParameters.addAll([
        code_builder.Parameter(
          (p) => p
            ..name = 'json'
            ..type = code_builder.refer('Map<String, dynamic>'),
        ),
      ])
      ..body = code_builder.Block(
        (bb) => bb
          ..statements.addAll([
            code_builder
                .declareConst('expectedFields')
                .assign(
                  code_builder.literalMap({
                    for (final field in fieldsWithoutSuperFields)
                      code_builder.literalString(field.name): code_builder.literalTrue,
                  }),
                )
                .statement,

            code_builder
                .declareFinal('extraFields')
                .assign(
                  code_builder
                      .refer('json')
                      .property('keys')
                      .property('whereNot')
                      .call([
                        code_builder.Method(
                          (m) => m
                            ..lambda = true
                            ..requiredParameters.add(code_builder.Parameter((p) => p.name = 'e'))
                            ..body = code_builder.refer('expectedFields').property('containsKey').call([
                              code_builder.refer('e'),
                            ]).code,
                        ).closure,
                      ])
                      .property('toList')
                      .call([code_builder.refer(' growable: false ')]),
                )
                .statement,

            ifStatement(
              code_builder.refer('extraFields').property('isEmpty'),
              code_builder.refer('null').returned.statement,
            ),

            code_builder
                .refer('Map.fromEntries')
                .call([
                  code_builder.refer('extraFields').property('map<MapEntry<String, dynamic>>').call([
                    code_builder.Method(
                      (m) => m
                        ..lambda = true
                        ..requiredParameters.add(code_builder.Parameter((p) => p.name = 'e'))
                        ..body = code_builder.refer('MapEntry').call([
                          code_builder.refer('e'),
                          code_builder.refer('json[e]'),
                        ]).code,
                    ).closure,
                  ]),
                ])
                .returned
                .statement,
          ]),
      ),
  );
}
