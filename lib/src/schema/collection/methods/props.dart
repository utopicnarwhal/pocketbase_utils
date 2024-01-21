part of '../collection.dart';

code_builder.Method _propsMethod(List<Field> schema) {
  return code_builder.Method((m) => m
    ..annotations.add(code_builder.refer('override'))
    ..returns = code_builder.refer('List<Object?>')
    ..type = code_builder.MethodType.getter
    ..name = 'props'
    ..lambda = true
    ..body = code_builder.literalList([
      code_builder.refer('super.props').spread,
      for (var field in schema) code_builder.refer(field.name),
    ]).code);
}
