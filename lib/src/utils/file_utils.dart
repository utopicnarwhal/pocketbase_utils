import 'dart:io';

import 'package:path/path.dart' as path;

/// Gets the root directory path.
String getRootDirectoryPath() => getRootDirectory().path;

/// Gets the root directory.
///
/// Note: The current working directory is assumed to be the root of a project.
Directory getRootDirectory() => Directory.current;

/// Gets the pubspec file.
File? getPubspecFile() {
  final rootDirPath = getRootDirectoryPath();
  final pubspecFilePath = path.join(rootDirPath, 'pubspec.yaml');
  final pubspecFile = File(pubspecFilePath);

  return pubspecFile.existsSync() ? pubspecFile : null;
}

/// Creates a file in [path] recursively, truncates the file if it already exists, and flushes the [content] into it.
void createFileAndWrite(String path, String content) {
  final file = File(path);

  if (!file.existsSync()) {
    file.createSync(recursive: true);
  }

  file.writeAsStringSync(content, flush: true);
}
