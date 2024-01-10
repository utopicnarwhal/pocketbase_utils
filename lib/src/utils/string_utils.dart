extension StringExtension on String {
  String capFirstChar() {
    if (isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + substring(1);
  }

  String toSnakeCase() {
    final exp = RegExp('(?<=[a-z])[A-Z]');
    return replaceAllMapped(exp, (m) => '_${m.group(0)}').toLowerCase();
  }
}
