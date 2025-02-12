part of '../collection.dart';

code_builder.Constructor _defaultConstructor(List<Field>? superFields, List<Field> schema) {
  return code_builder.Constructor(
    (d) => d
      ..optionalParameters.addAll([
        if (superFields != null)
          for (var field in superFields)
            code_builder.Parameter(
              (p) => p
                ..name = field.name
                ..named = true
                ..toSuper = true
                ..required = field.required == true
                ..docs.addAll([if (field.docs != null) field.docs!]),
            ),
        for (var field in schema)
          code_builder.Parameter(
            (p) => p
              ..toThis = true
              ..name = field.name
              ..named = true
              ..required = field.required == true
              ..docs.addAll([if (field.docs != null) field.docs!]),
          ),
      ]),
  );
}
