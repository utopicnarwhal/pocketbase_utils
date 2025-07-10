import 'dart:io' as io;

bool isValidPath(String value) => RegExp(r'^(?:[A-Za-z]:)?([\/\\]{0,2}\w*)+$').hasMatch(value);

void info(String message) => io.stdout.writeln('INFO: $message');

void warning(String message) => io.stdout.writeln('WARNING: $message');

void error(String message) => io.stderr.writeln('ERROR: $message');

void exitWithError(String message) {
  error(message);
  io.exit(2);
}

int? jsonValueParseToInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is String) {
    if (value.isEmpty) {
      return null;
    }
    return int.parse(value);
  }
  throw Exception("The type of value `$value` isn't `String` or `int`");
}
