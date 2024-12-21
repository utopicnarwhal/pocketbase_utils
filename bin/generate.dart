library;

import 'package:pocketbase_utils/pocketbase_utils.dart';
import 'package:pocketbase_utils/src/generator/generator_exception.dart';
import 'package:pocketbase_utils/src/utils/utils.dart';

Future<void> main(List<String> args) async {
  try {
    var generator = Generator();
    await generator.generateAsync();
  } on GeneratorException catch (e) {
    exitWithError(e.message);
  } catch (e, stackTrace) {
    exitWithError('Failed to generate collections models files.\n$e\n StackTrace: $stackTrace');
  }
}
