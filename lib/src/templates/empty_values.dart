import 'package:code_builder/code_builder.dart' as code_builder;
import 'package:dart_style/dart_style.dart';
import 'package:pocketbase_utils/src/templates/do_not_modify_by_hand.dart';

String emptyValuesGenerator(int lineLength) {
  final classCode = code_builder.Class((c) => c
    ..name = 'EmptyDateTime'
    ..extend = code_builder.refer('DateTime')
    ..constructors.addAll([
      code_builder.Constructor(
        (d) => d..initializers.add(code_builder.Code('super(0)')),
      )
    ]));

  final libraryCode = code_builder.Library(
    (l) => l
      ..body.add(classCode)
      ..generatedByComment = doNotModifyByHandTemplate,
  );

  final emitter = code_builder.DartEmitter.scoped(
    useNullSafetySyntax: true,
    orderDirectives: true,
  );

  return DartFormatter(
    languageVersion: DartFormatter.latestShortStyleLanguageVersion,
    pageWidth: lineLength,
  ).format('${libraryCode.accept(emitter)}');
}
