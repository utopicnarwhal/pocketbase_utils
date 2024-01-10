import 'dart:io' as io;

bool isValidPath(String value) => RegExp(r'^(?:[A-Za-z]:)?([\/\\]{0,2}\w*)+$').hasMatch(value);

void info(String message) => io.stdout.writeln('INFO: $message');

void warning(String message) => io.stdout.writeln('WARNING: $message');

void error(String message) => io.stderr.writeln('ERROR: $message');

void exitWithError(String message) {
  error(message);
  io.exit(2);
}
