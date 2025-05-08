part of '../collection.dart';

code_builder.Constructor _defaultConstructor(
  List<Field> superFields,
  List<Field> schema, [
  List<Field> fieldsToOverride = const [],
]) {
  return code_builder.Constructor(
    (d) => d
      ..optionalParameters.addAll([
        for (var field in superFields)
          code_builder.Parameter(
            (p) => p
              ..name = field.nameInCamelCase
              ..named = true
              ..toSuper = true
              ..required = field.isNonNullable
              ..docs.addAll([if (field.docs != null) field.docs!]),
          ),
        for (var field in schema)
          code_builder.Parameter(
            (p) => p
              ..toThis = true
              ..name = field.nameInCamelCase
              ..named = true
              ..required = field.isNonNullable
              ..docs.addAll([if (field.docs != null) field.docs!]),
          ),
      ])
      ..initializers.add(
        code_builder.refer('super').call(
          [],
          {
            for (var field in schema)
              if (fieldsToOverride.any((e) => e.name == field.name))
                field.name: code_builder.refer(field.nameInCamelCase),
          },
        ).code,
      ),
  );
}
