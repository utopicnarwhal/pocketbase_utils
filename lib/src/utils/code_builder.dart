import 'package:code_builder/code_builder.dart';

Block ifStatement(
  Expression conditional,
  Code body, {
  bool addCurlyBraces = true,
}) {
  return Block.of([
    Code('if ('),
    conditional.code,
    Code(')'),
    if (addCurlyBraces) Code('{'),
    body,
    if (addCurlyBraces) Code('}'),
  ]);
}

Block forLoop(
  Expression defineLoopCode,
  Code body, {
  bool addCurlyBraces = true,
}) {
  return Block.of([
    Code('for '),
    defineLoopCode.parenthesized.code,
    if (addCurlyBraces) Code('{'),
    body,
    if (addCurlyBraces) Code('}'),
  ]);
}
