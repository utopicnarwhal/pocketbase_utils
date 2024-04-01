part of '../collection.dart';

code_builder.Method _takeDiffMethod(String className, Iterable<Field> allFieldsExceptHidden) {
  return code_builder.Method((m) => m
    ..returns = code_builder.refer('Map<String, dynamic>')
    ..name = 'takeDiff'
    ..requiredParameters.addAll([
      code_builder.Parameter((p) => p
        ..name = 'other'
        ..type = code_builder.refer(className)),
    ])
    ..body = code_builder.Block((bb) => bb
      ..statements.addAll([
        code_builder.declareFinal('thisInJsonMap').assign(code_builder.refer('toJson').call([])).statement,
        code_builder
            .declareFinal('otherInJsonMap')
            .assign(code_builder.refer('other').property('toJson').call([]))
            .statement,
        code_builder
            .declareFinal('result', type: code_builder.refer('Map<String, dynamic>'))
            .assign(code_builder.literalMap({}))
            .statement,
        code_builder
            .declareFinal('deepCollectionEquality',
                type: code_builder.refer('DeepCollectionEquality', 'package:collection/collection.dart'))
            .assign(code_builder.refer('DeepCollectionEquality', 'package:collection/collection.dart').newInstance([]))
            .statement,
        forLoop(
          code_builder.CodeExpression(
            code_builder.Code('${code_builder.declareFinal('mapEntry').code} in thisInJsonMap.entries'),
          ),
          code_builder.Block(
            (block) => block.statements.addAll([
              code_builder.declareFinal('thisValue').assign(code_builder.refer('mapEntry.value')).statement,
              code_builder
                  .declareFinal('otherValue')
                  .assign(code_builder.refer('otherInJsonMap[mapEntry.key]'))
                  .statement,
              ifStatement(
                code_builder
                    .refer('deepCollectionEquality')
                    .property('equals')
                    .call([code_builder.refer('thisValue'), code_builder.refer('otherValue')]).negate(),
                code_builder
                    .refer('result')
                    .property('addAll')
                    .call([code_builder.refer('{mapEntry.key: otherValue}')]).statement,
              ),
            ]),
          ),
        ),
        code_builder.refer('result').returned.statement,
      ])));
}
