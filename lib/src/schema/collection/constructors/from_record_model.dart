part of '../collection.dart';

code_builder.Constructor _fromRecordModelConstructor(String className) {
  return code_builder.Constructor(
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
                  for (var recordFieldName in ['id', 'collectionId', 'collectionName'])
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
  );
}
