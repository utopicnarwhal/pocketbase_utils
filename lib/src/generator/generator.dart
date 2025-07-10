import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:pocketbase_utils/src/config/pubspec_config.dart';
import 'package:pocketbase_utils/src/schema/collection/collection.dart';
import 'package:pocketbase_utils/src/templates/auth_record.dart';
import 'package:pocketbase_utils/src/templates/base_record.dart';
import 'package:pocketbase_utils/src/templates/date_time_json_methods.dart';
import 'package:pocketbase_utils/src/templates/empty_values.dart';
import 'package:pocketbase_utils/src/templates/geo_point_class.dart';
import 'package:pocketbase_utils/src/utils/file_utils.dart';
import 'package:pocketbase_utils/src/utils/utils.dart';
import 'package:recase/recase.dart';

const _defaultPbSchemaPath = 'pb_schema.json';
const _defaultOutputDir = 'lib/generated/pocketbase';
const _defaultLineLength = 80;
const _defaultGenerateSystemCollections = false;

/// The generator of models files.
class Generator {
  /// Creates a new generator with configuration from the 'pubspec.yaml' file.
  Generator() {
    final pubspecConfig = PubspecConfig();

    if (pubspecConfig.enabled != true) {
      warning(
        "The package is disabled by the 'enabled' option in your 'pubspec.yaml'",
      );
      return;
    }

    _pbSchemaPath = pubspecConfig.pbSchemaPath ?? _defaultPbSchemaPath;

    _outputDir = pubspecConfig.outputDir ?? _defaultOutputDir;
    if (!isValidPath(_outputDir)) {
      warning(r"Config parameter 'output_dir' requires valid path value (e.g. 'lib', 'lib\generated').");
    }

    _lineLength = pubspecConfig.lineLength ?? _defaultLineLength;

    _generateSystemCollections = pubspecConfig.generateSystemCollections ?? _defaultGenerateSystemCollections;
  }
  late String _pbSchemaPath;
  late String _outputDir;
  late int _lineLength;
  late bool _generateSystemCollections;

  /// Generates collections models files.
  Future<void> generateAsync() async {
    final pbSchemaFile = await _checkPbSchemaPath();
    final outputDir = await _updateGeneratedDir();
    await _generateDartFiles(pbSchemaFile, outputDir);
  }

  Future<File> _checkPbSchemaPath() async {
    final rootDirPath = getRootDirectoryPath();
    final absPbSchemaPath = path.join(rootDirPath, _pbSchemaPath);
    final pbSchemaFile = File(absPbSchemaPath);

    if (!pbSchemaFile.existsSync()) {
      exitWithError("File in absolute path $absPbSchemaPath doesn't exist!");
    }

    return pbSchemaFile;
  }

  Future<Directory> _updateGeneratedDir() async {
    final rootDirPath = getRootDirectoryPath();
    final outputDirPath = path.join(rootDirPath, _outputDir);

    return Directory(outputDirPath).create(recursive: true);
  }

  Future<void> _generateDartFiles(File pbSchemaFile, Directory outputDirectory) async {
    final pbSchemaFileContent = pbSchemaFile.readAsStringSync();
    final pbSchemaDecoded = jsonDecode(pbSchemaFileContent);
    if (pbSchemaDecoded is! List<dynamic>) {
      return;
    }

    final collections = <Collection>[];
    for (final collectionJson in pbSchemaDecoded) {
      if (collectionJson is! Map<String, dynamic>) {
        continue;
      }

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
    createFileAndWrite(
      path.join(outputDirectory.path, 'geo_point_class.dart'),
      geoPointClassGenerator('geo_point_class', _lineLength),
    );

    for (final collection in collections) {
      final fileName = '${ReCase(collection.name).snakeCase}_record';

      createFileAndWrite(
        path.join(outputDirectory.path, '$fileName.dart'),
        collection.generateClassCode(fileName, _lineLength),
      );
    }
  }
}
