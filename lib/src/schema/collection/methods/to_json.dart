part of '../collection.dart';

code_builder.Method _toJsonMethod(String className) {
  return code_builder.Method((m) => m
    ..returns = code_builder.refer('Map<String, dynamic>')
    ..name = 'toJson'
    ..lambda = true
    ..body = code_builder.Code('_\$${className}ToJson(this)'));
}
