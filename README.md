# PocketBase Utils

[![pub package](https://img.shields.io/pub/v/pocketbase_utils.svg)](https://pub.dev/packages/pocketbase_utils)

Dart package that creates a binding between your pocketbase server and your Flutter app by generating typesafe boilerplate code of your collections from `pb_schema.json` file.

## Usage

You can use this package directly through the command line on any device with Dart installed.

Follow these steps to get started:

### 1. Download the collections schema

- Open your pocketbase admin panel and go to `Settings/Export collections`.
- Click on "Download as JSON" button.
- Save the file into the project (the root is default by the config).
- `Reminder`: You may also want to add your file into the `.gitignore`.

### 2. Install the package

Add the package into your `pubspec.yaml`:

```yaml
...
dev_dependencies:
    ...
    pocketbase_utils: x.x.x
```

You also may have to install the [json_serializable](https://pub.dev/packages/json_serializable), [equatable](https://pub.dev/packages/equatable), [collection](https://pub.dev/packages/collection), and [pocketbase](https://pub.dev/packages/pocketbase) packages.

### 3. Configure package

Add package configuration to your `pubspec.yaml` file. Here is a full configuration for the package:

```yaml

---
pocketbase_utils:
  enabled: true # Required. Must be set to true to activate the package. Default: false
  pb_schema_path: pb_schema.json # Optional. Sets the path of your collection schema file. Default: pb_schema.json
  output_dir: lib/generated/pocketbase # Optional. Sets the directory of generated model files. If the directory doesn't exist — it'll be created. Default: lib/generated/pocketbase
  line_length: 80 # Optional. Sets the length of line for dart formatter of generated code. Default: 80
  generate_system_collections: false # Optional. Generate models for the system level collections like `_mfas`, `_otps`, and `_superusers`. Default: false
```

### 4. Run the generator

In the root of your flutter project run:

```sh
dart run pocketbase_utils:generate
```

This will produce files inside `lib/generated/pocketbase` directory.
You can also change the output folder to a custom directory by adding the `output_dir` line in your `pubspec.yaml` file.

And then to build the `toJson` and `fromJson` run:

```sh
dart run build_runner build --delete-conflicting-outputs
```

## Contributing

Contributions are welcome! Please create an issue or make a fork and propose a PR to contribute to this project.

## Commands

### Publish package

```sh
dart pub publish --dry-run
```

### Generate code inside the package

```sh
dart run build_runner build --delete-conflicting-outputs
```

## License

This project is licensed under the [Apache License 2.0](LICENSE).
