// lib/src/services/material_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MaterialStorage {
  static const String _key = 'materials_list';

  Future<List<Map<String, dynamic>>> loadMaterials() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> saveMaterials(List<Map<String, dynamic>> materials) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(materials));
  }

  Future<void> addMaterial(Map<String, dynamic> material) async {
    final list = await loadMaterials();
    list.add(material);
    await saveMaterials(list);
  }

  Future<void> removeMaterial(String id) async {
    final list = await loadMaterials();
    list.removeWhere((m) => (m['id'] ?? '') == id);
    await saveMaterials(list);
  }

  Future<List<Map<String, dynamic>>> getMaterialsForCourse(String courseId) async {
    final all = await loadMaterials();
    return all.where((m) => m['courseId'] == courseId).toList();
  }
}

