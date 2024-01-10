import 'package:code_builder/code_builder.dart' as code_builder;
import 'package:dart_style/dart_style.dart';
import 'package:pocketbase_utils/src/schema/field.dart';
import 'package:pocketbase_utils/src/templates/do_not_modify_by_hand.dart';

String authRecordClassGenerator(int lineLength) {
  final classCode = code_builder.Class(
    (c) => c
      ..name = 'AuthRecord'
      ..abstract = true
      ..modifier = code_builder.ClassModifier.base
      ..fields.addAll([
        for (var field in authFields.where((sf) => !sf.hiddenSystem)) field.toCodeBuilder(),
      ])
      ..methods.addAll(collectionRefMethodBuilderList.map((e) => code_builder.Method(e)))
      ..constructors.addAll([
        code_builder.Constructor((d) => d
          ..optionalParameters.addAll([
            for (var field in authFields.where((sf) => !sf.hiddenSystem))
              code_builder.Parameter(
                (p) => p
                  ..toThis = true
                  ..name = field.name
                  ..named = true
                  ..required = field.required,
              ),
          ])),
      ]),
  );

  final libraryCode = code_builder.Library(
    (l) => l
      ..body.add(classCode)
      ..generatedByComment = doNotModifyByHandTemplate,
  );

  final emitter = code_builder.DartEmitter(
    useNullSafetySyntax: true,
    orderDirectives: true,
  );

  return DartFormatter(pageWidth: lineLength).format('${libraryCode.accept(emitter)}');
}
