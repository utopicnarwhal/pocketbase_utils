import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:pocketbase_utils/src/schema/collection/collection.dart';
import 'package:pocketbase_utils/src/templates/auth_record.dart';
import 'package:pocketbase_utils/src/templates/base_record.dart';
import 'package:pocketbase_utils/src/templates/date_time_json_methods.dart';
import 'package:pocketbase_utils/src/templates/empty_values.dart';
import 'package:recase/recase.dart';

import '../config/pubspec_config.dart';
import '../utils/file_utils.dart';
import '../utils/utils.dart';

const _defaultPbSchemaPath = 'pb_schema.json';
const _defaultOutputDir = 'lib/generated/pocketbase';
const _defaultLineLength = 80;
const _defaultGenerateSystemCollections = false;

/// The generator of models files.
class Generator {
  late String _pbSchemaPath;
  late String _outputDir;
  late int _lineLength;
  late bool _generateSystemCollections;

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

    _generateSystemCollections = pubspecConfig.generateSystemCollections ?? _defaultGenerateSystemCollections;
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
      final collectionModel = Collection.fromJson(collectionJson);
      if (_generateSystemCollections || !collectionModel.system) {
        collections.add(collectionModel);
      }
    }

    createFileAndWrite(
      path.join(outputDirectory.path, 'base_record.dart'),
      baseRecordClassGenerator(_lineLength),
    );
    createFileAndWrite(
      path.join(outputDirectory.path, 'auth_record.dart'),
      authRecordClassGenerator(_lineLength),
    );
    createFileAndWrite(
      path.join(outputDirectory.path, 'empty_values.dart'),
      emptyValuesGenerator(_lineLength),
    );
    createFileAndWrite(
      path.join(outputDirectory.path, 'date_time_json_methods.dart'),
      dateTimeJsonMethodsGenerator(_lineLength),
    );

    for (var collection in collections) {
      final fileName = '${ReCase(collection.name).snakeCase}_record';

      createFileAndWrite(
        path.join(outputDirectory.path, '$fileName.dart'),
        collection.generateClassCode(fileName, _lineLength),
      );
    }
  }
}
