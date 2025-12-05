// lib/data/storage.dart
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class CampStorage {
  static const _storageKey = 'camp_data_v1';

  Future<List<Camp>> loadCamps() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data == null || data.isEmpty) return [];

    try {
      final decoded = jsonDecode(data) as List<dynamic>;
      return decoded
          .map((e) => Camp.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCamps(List<Camp> camps) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(camps.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, payload);
  }

  Future<String> buildBackupPayload(List<Camp> camps) async {
    return jsonEncode({
      'generatedAt': DateTime.now().toIso8601String(),
      'camps': camps.map((e) => e.toMap()).toList(),
    });
  }

  Future<String> saveBackupFile(String payload) async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${backupDir.path}/kamp_backup_$timestamp.json');
    await file.writeAsString(payload);
    return file.path;
  }

  Future<List<Camp>> restoreFromPayload(String payload) async {
    final decoded = jsonDecode(payload) as Map<String, dynamic>;
    final camps = decoded['camps'] as List<dynamic>?;
    if (camps == null) return [];

    return camps
        .map((e) => Camp.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
