part of '../collection.dart';

code_builder.Constructor _fromJsonConstructor(String className) {
  return code_builder.Constructor(
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
  );
}
