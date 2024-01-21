part of '../collection.dart';

code_builder.Method _forCreateRequestMethod(String className, Iterable<Field> allFieldsExceptHidden) {
  return code_builder.Method((m) => m
    ..returns = code_builder.refer('Map<String, dynamic>')
    ..name = 'forCreateRequest'
    ..static = true
    ..optionalParameters.addAll([
      for (final field in allFieldsExceptHidden.where((f) => !baseFields.contains(f)))
        code_builder.Parameter((p) => p
          ..named = true
          ..name = field.name
          ..required = field.required
          ..type = field.fieldTypeRef(className)),
    ])
    ..body = code_builder.Block((bb) {
      code_builder.Code addFieldToResultWithCheckCode(Field field) {
        final addFieldCode = code_builder.refer('result').property('addAll').call([
          code_builder.literalMap({
            code_builder.refer('${className}FieldsEnum.${field.name}.name'): code_builder.refer(field.name),
          })
        ]).statement;

        if (field.required) {
          return addFieldCode;
        }

        return ifStatement(
          code_builder.refer(field.name).notEqualTo(code_builder.literalNull),
          addFieldCode,
        );
      }

      bb.statements.addAll([
        code_builder
            .declareFinal('result', type: code_builder.refer('Map<String, dynamic>'))
            .assign(code_builder.literalMap({}))
            .statement,
        for (final field in allFieldsExceptHidden.where((f) => !baseFields.contains(f)))
          addFieldToResultWithCheckCode(field),
        code_builder.refer('result').returned.statement,
      ]);
    }));
}
