import 'package:pocketbase_utils/src/config/config_exception.dart';
import 'package:pocketbase_utils/src/utils/file_utils.dart';
import 'package:yaml/yaml.dart' as yaml;

class PubspecConfig {
  PubspecConfig() {
    final pubspecFile = getPubspecFile();
    if (pubspecFile == null) {
      throw ConfigException("Can't find 'pubspec.yaml' file.");
    }

    final pubspecFileContent = pubspecFile.readAsStringSync();
    final pubspecYaml = yaml.loadYaml(pubspecFileContent);
    if (pubspecYaml is! yaml.YamlMap) {
      throw ConfigException(
        "Failed to extract config from the 'pubspec.yaml' file.\nExpected YAML map but got ${pubspecYaml.runtimeType}.",
      );
    }

    final pocketbaseUtilsConfig = pubspecYaml['pocketbase_utils'];
    if (pocketbaseUtilsConfig is! yaml.YamlMap) {
      throw ConfigException(
        "Failed to extract pocketbaseUtilsConfig from the 'pubspec.yaml' file.\nExpected YAML map but got ${pocketbaseUtilsConfig.runtimeType}.",
      );
    }

    _enabled = pocketbaseUtilsConfig['enabled'] is bool ? pocketbaseUtilsConfig['enabled'] as bool : null;
    _pbSchemaPath =
        pocketbaseUtilsConfig['pb_schema_path'] is String ? pocketbaseUtilsConfig['pb_schema_path'] as String : null;
    _outputDir = pocketbaseUtilsConfig['output_dir'] is String ? pocketbaseUtilsConfig['output_dir'] as String : null;
    _lineLength = pocketbaseUtilsConfig['line_length'] is int ? pocketbaseUtilsConfig['line_length'] as int : null;
    _generateSystemCollections = pocketbaseUtilsConfig['generate_system_collections'] is bool
        ? pocketbaseUtilsConfig['generate_system_collections'] as bool
        : null;
  }

  bool? _enabled;
  String? _pbSchemaPath;
  String? _outputDir;
  int? _lineLength;
  bool? _generateSystemCollections;

  bool? get enabled => _enabled;

  String? get pbSchemaPath => _pbSchemaPath;

  String? get outputDir => _outputDir;

  int? get lineLength => _lineLength;

  bool? get generateSystemCollections => _generateSystemCollections;
}
