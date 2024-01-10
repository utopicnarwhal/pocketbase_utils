import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:pocketbase_utils/src/schema/collection.dart';
import 'package:pocketbase_utils/src/templates/auth_record.dart';
import 'package:pocketbase_utils/src/templates/base_record.dart';
import 'package:pocketbase_utils/src/utils/string_utils.dart';

import '../config/pubspec_config.dart';
import '../utils/file_utils.dart';
import '../utils/utils.dart';

const _defaultPbSchemaPath = 'pb_schema.json';
const _defaultOutputDir = 'lib/generated/pocketbase';
const _defaultLineLength = 80;

/// The generator of models files.
class Generator {
  late String _pbSchemaPath;
  late String _outputDir;
  late int _lineLength;

  /// Creates a new generator with configuration from the 'pubspec.yaml' file.
  Generator() {
    var pubspecConfig = PubspecConfig();

    if (pubspecConfig.enabled != true) {
      warning(
        "The package is disabled by the 'enabled' option in your 'pubspec.yaml'",
      );
      return;
    }

    _pbSchemaPath = pubspecConfig.pbSchemaPath ?? _defaultPbSchemaPath;

    _outputDir = pubspecConfig.outputDir ?? _defaultOutputDir;
    if (!isValidPath(_outputDir)) {
      warning("Config parameter 'output_dir' requires valid path value (e.g. 'lib', 'lib\\generated').");
    }

    _lineLength = pubspecConfig.lineLength ?? _defaultLineLength;
  }

  /// Generates collections models files.
  Future<void> generateAsync() async {
    final pbSchemaFile = await _checkPbSchemaPath();
    final outputDir = await _updateGeneratedDir();
    await _generateDartFiles(pbSchemaFile, outputDir);
  }

  Future<File> _checkPbSchemaPath() async {
    var rootDirPath = getRootDirectoryPath();
    var absPbSchemaPath = path.join(rootDirPath, _pbSchemaPath);
    var pbSchemaFile = File(absPbSchemaPath);

    if (!pbSchemaFile.existsSync()) {
      exitWithError("File in absolute path $absPbSchemaPath doesn't exist!");
    }

    return pbSchemaFile;
  }

  Future<Directory> _updateGeneratedDir() async {
    var rootDirPath = getRootDirectoryPath();
    var outputDirPath = path.join(rootDirPath, _outputDir);

    return Directory(outputDirPath).create(recursive: true);
  }

  Future<void> _generateDartFiles(File pbSchemaFile, Directory outputDirectory) async {
    final pbSchemaFileContent = pbSchemaFile.readAsStringSync();
    final List<dynamic> pbSchemaDecoded = jsonDecode(pbSchemaFileContent);

    final collections = <Collection>[];
    for (Map<String, dynamic> collectionJson in pbSchemaDecoded) {
      collections.add(Collection.fromJson(collectionJson));
    }

    createFileAndWrite(
      path.join(outputDirectory.path, 'base_record.dart'),
      baseRecordClassGenerator(_lineLength),
    );
    createFileAndWrite(
      path.join(outputDirectory.path, 'auth_record.dart'),
      authRecordClassGenerator(_lineLength),
    );

    for (var collection in collections) {
      final fileName = '${collection.name.toSnakeCase()}_record';

      createFileAndWrite(
        path.join(outputDirectory.path, '$fileName.dart'),
        collection.generateClassCode(fileName, _lineLength),
      );
    }
  }
}
