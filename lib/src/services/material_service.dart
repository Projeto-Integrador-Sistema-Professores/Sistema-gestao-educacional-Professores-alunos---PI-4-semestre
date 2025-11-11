// lib/src/services/material_service.dart
import 'package:uuid/uuid.dart';
import 'api_client.dart';
import '../models/material_item.dart';

class MaterialService {
  final ApiClient client;
  MaterialService(this.client);

  Future<List<MaterialItem>> listMaterials(String courseId) async {
    final res = await client.get('/courses/$courseId');
    final materials = (res.data['materials'] as List<dynamic>).cast<Map<String, dynamic>>();
    return materials.map((e) => MaterialItem.fromJson(e)).toList();
  }

  Future<MaterialItem> createMaterial({
    required String courseId,
    required String title,
    required String fileName,
    String? fileData, // Base64 ou path
  }) async {
    final id = const Uuid().v4();
    final payload = {
      'id': id,
      'title': title,
      'fileName': fileName,
      'fileUrl': fileData ?? '#', // URL ou base64
      if (fileData != null) 'fileData': fileData,
    };
    final res = await client.post('/courses/$courseId/materials', data: payload);
    return MaterialItem.fromJson(res.data['material']);
  }

  Future<Map<String, dynamic>> downloadMaterial(String materialId) async {
    final res = await client.get('/materials/$materialId/download');
    return res.data;
  }
}

