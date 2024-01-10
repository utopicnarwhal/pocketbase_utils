import 'package:yaml/yaml.dart' as yaml;

import '../utils/file_utils.dart';
import 'config_exception.dart';

class PubspecConfig {
  bool? _enabled;
  String? _pbSchemaPath;
  String? _outputDir;
  int? _lineLength;

  bool? get enabled => _enabled;

  String? get pbSchemaPath => _pbSchemaPath;

  String? get outputDir => _outputDir;

  int? get lineLength => _lineLength;

  PubspecConfig() {
    var pubspecFile = getPubspecFile();
    if (pubspecFile == null) {
      throw ConfigException("Can't find 'pubspec.yaml' file.");
    }

    var pubspecFileContent = pubspecFile.readAsStringSync();
    var pubspecYaml = yaml.loadYaml(pubspecFileContent);

    if (pubspecYaml is! yaml.YamlMap) {
      throw ConfigException(
        "Failed to extract config from the 'pubspec.yaml' file.\nExpected YAML map but got ${pubspecYaml.runtimeType}.",
      );
    }

    var pocketbaseUtilsConfig = pubspecYaml['pocketbase_utils'];
    if (pocketbaseUtilsConfig == null) {
      return;
    }

    _enabled = pocketbaseUtilsConfig['enabled'] is bool ? pocketbaseUtilsConfig['enabled'] : null;
    _pbSchemaPath = pocketbaseUtilsConfig['pb_schema_path'] is String ? pocketbaseUtilsConfig['pb_schema_path'] : null;
    _outputDir = pocketbaseUtilsConfig['output_dir'] is String ? pocketbaseUtilsConfig['output_dir'] : null;
    _lineLength = pocketbaseUtilsConfig['line_length'] is int ? pocketbaseUtilsConfig['line_length'] : null;
  }
}
