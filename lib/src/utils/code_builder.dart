import 'package:code_builder/code_builder.dart';

Block ifStatement(
  Expression conditional,
  Code body, {
  bool addCurlyBraces = true,
}) {
  return Block.of([
    const Code('if ('),
    conditional.code,
    const Code(')'),
    if (addCurlyBraces) const Code('{'),
    body,
    if (addCurlyBraces) const Code('}'),
  ]);
}

Block forLoop(
  Expression defineLoopCode,
  Code body, {
  bool addCurlyBraces = true,
}) {
  return Block.of([
    const Code('for '),
    defineLoopCode.parenthesized.code,
    if (addCurlyBraces) const Code('{'),
    body,
    if (addCurlyBraces) const Code('}'),
  ]);
}
