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
          ..name = field.nameInCamelCase
          ..required = field.required == true
          ..type = field.fieldTypeRef(className)),
    ])
    ..body = code_builder.Block((bb) {
      code_builder.Code addFieldToResultWithCheckCode(Field field) {
        final addFieldCode = code_builder.refer('result').property('addAll').call([
          code_builder.literalMap({
            code_builder.refer('${className}FieldsEnum.${field.nameInCamelCase}.nameInSchema'): code_builder
                .refer('jsonMap')
                .index(code_builder.refer('${className}FieldsEnum.${field.nameInCamelCase}.nameInSchema')),
          })
        ]).statement;

        if (field.required == true) {
          return addFieldCode;
        }

        return ifStatement(
          code_builder.refer(field.nameInCamelCase).notEqualTo(code_builder.literalNull),
          addFieldCode,
        );
      }

      bb.statements.addAll([
        code_builder
            .declareFinal('jsonMap')
            .assign(
              code_builder.refer(className).newInstance([], {
                for (final baseField in baseFields)
                  baseField.nameInCamelCase: switch (baseField.nameInCamelCase) {
                    'id' => code_builder.literalString(''),
                    'created' || 'updated' => code_builder.refer('EmptyDateTime', 'empty_values.dart').newInstance([]),
                    'collectionId' || 'collectionName' => code_builder.refer('\$${baseField.nameInCamelCase}'),
                    _ => code_builder.refer(baseField.nameInCamelCase),
                  },
                for (final field in allFieldsExceptHidden.where((f) => !baseFields.contains(f)))
                  field.nameInCamelCase: code_builder.refer(field.nameInCamelCase),
              }),
            )
            .property('toJson')
            .call([]).statement,
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
