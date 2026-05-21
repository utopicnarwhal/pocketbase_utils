part of '../collection.dart';

code_builder.Method _copyWithMethod(String className, Iterable<Field> allFieldsExceptHidden, CollectionType collectionType) {
  return code_builder.Method((m) => m
    ..returns = code_builder.refer(className)
    ..name = 'copyWith'
    ..optionalParameters.addAll([
      for (final field in allFieldsExceptHidden.where((f) => !baseFields.contains(f)))
        code_builder.Parameter((p) => p
          ..named = true
          ..name = field.nameInCamelCase
          ..type = collectionType == CollectionType.view
              ? code_builder.refer('dynamic')
              : field.fieldTypeRef(className, forceNullable: true)),
    ])
    ..body = code_builder.Block(
      (bb) => bb
        ..statements.addAll([
          code_builder
              .refer(className)
              .newInstance([], {
                for (final baseField in collectionType == CollectionType.view ? viewFields : baseFields)
                  baseField.nameInCamelCase: code_builder.refer(baseField.nameInCamelCase),
                for (final field in allFieldsExceptHidden.where((f) => !(collectionType == CollectionType.view ? viewFields : baseFields).contains(f)))
                  field.nameInCamelCase:
                      code_builder.refer('${field.nameInCamelCase} ?? this.${field.nameInCamelCase}'),
              })
              .returned
              .statement,
        ]),
    ));
}
