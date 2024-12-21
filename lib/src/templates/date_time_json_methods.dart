import 'package:code_builder/code_builder.dart' as code_builder;
import 'package:dart_style/dart_style.dart';
import 'package:pocketbase_utils/src/templates/do_not_modify_by_hand.dart';

const String pocketBaseDateTimeToJsonMethodName = 'pocketBaseDateTimeToJson';
const String pocketBaseDateTimeFromJsonMethodName = 'pocketBaseDateTimeFromJson';
const String pocketBaseNullableDateTimeToJsonMethodName = 'pocketBaseNullableDateTimeToJson';
const String pocketBaseNullableDateTimeFromJsonMethodName = 'pocketBaseNullableDateTimeFromJson';

String dateTimeJsonMethodsGenerator(int lineLength) {
  final libraryCode = code_builder.Library(
    (l) => l
      ..body.addAll([
        _dateTimeFromJsonMethod(),
        _dateTimeToJsonMethod(),
        _nullableDateTimeFromJsonMethod(),
        _nullableDateTimeToJsonMethod(),
      ])
      ..generatedByComment = doNotModifyByHandTemplate,
  );

  final emitter = code_builder.DartEmitter.scoped(
    useNullSafetySyntax: true,
    orderDirectives: true,
  );

  return DartFormatter(pageWidth: lineLength).format('${libraryCode.accept(emitter)}');
}

code_builder.Method _dateTimeToJsonMethod() {
  return code_builder.Method((m) => m
    ..returns = code_builder.refer('String')
    ..name = pocketBaseDateTimeToJsonMethodName
    ..lambda = true
    ..requiredParameters.add(code_builder.Parameter((p) => p
      ..name = 'dateTime'
      ..type = code_builder.TypeReference((t) => t..symbol = 'DateTime')))
    ..body = code_builder.refer('dateTime').property('toIso8601String').call([]).code);
}

code_builder.Method _dateTimeFromJsonMethod() {
  return code_builder.Method((m) => m
    ..returns = code_builder.TypeReference((t) => t..symbol = 'DateTime')
    ..name = pocketBaseDateTimeFromJsonMethodName
    ..lambda = true
    ..requiredParameters.add(code_builder.Parameter((p) => p
      ..name = 'json'
      ..type = code_builder.refer('String')))
    ..body = code_builder.refer('DateTime').property('parse').call([code_builder.refer('json')]).code);
}

code_builder.Method _nullableDateTimeToJsonMethod() {
  return code_builder.Method((m) => m
    ..returns = code_builder.refer('String')
    ..name = pocketBaseNullableDateTimeToJsonMethodName
    ..lambda = true
    ..requiredParameters.add(code_builder.Parameter((p) => p
      ..name = 'dateTime'
      ..type = code_builder.TypeReference((t) => t
        ..symbol = 'DateTime'
        ..isNullable = true)))
    ..body = code_builder
        .refer('dateTime')
        .nullSafeProperty('toIso8601String')
        .call([])
        .ifNullThen(code_builder.literalString(''))
        .code);
}

code_builder.Method _nullableDateTimeFromJsonMethod() {
  return code_builder.Method((m) => m
    ..returns = code_builder.TypeReference((t) => t
      ..symbol = 'DateTime'
      ..isNullable = true)
    ..name = pocketBaseNullableDateTimeFromJsonMethodName
    ..lambda = true
    ..requiredParameters.add(code_builder.Parameter((p) => p
      ..name = 'json'
      ..type = code_builder.refer('String')))
    ..body = code_builder.refer('DateTime').property('tryParse').call([code_builder.refer('json')]).code);
}
