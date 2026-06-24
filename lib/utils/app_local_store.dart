import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AppLocalStore {
  static const String _fileName = 'app_preferences.json';

  static Future<String?> readString(String key) async {
    final values = await _readAll();
    final value = values[key];
    return value is String && value.isNotEmpty ? value : null;
  }

  static Future<void> writeString(String key, String value) async {
    final values = await _readAll();
    values[key] = value;
    await _writeAll(values);
  }

  static Future<Map<String, dynamic>> _readAll() async {
    final file = await _file();
    if (!await file.exists()) {
      return <String, dynamic>{};
    }

    try {
      final contents = await file.readAsString();
      final decoded = jsonDecode(contents);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Ignore corrupt preference data and fall back to defaults.
    }
    return <String, dynamic>{};
  }

  static Future<void> _writeAll(Map<String, dynamic> values) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(values));
  }

  static Future<File> _file() async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/$_fileName');
  }
}
