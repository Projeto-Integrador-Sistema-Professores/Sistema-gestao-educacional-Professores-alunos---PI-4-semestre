// lib/src/services/material_service.dart
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
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
    String? fileData, // Base64 (web) ou path (mobile/desktop)
  }) async {
    if (fileData == null) {
      throw Exception('Arquivo não fornecido');
    }

    // Cria FormData para multipart/form-data
    final formData = FormData();

    // Adiciona o título
    formData.fields.add(MapEntry('title', title));

    // Adiciona o arquivo
    if (kIsWeb) {
      // Web: fileData é base64, precisa converter para bytes
      final bytes = base64Decode(fileData);
      formData.files.add(MapEntry(
        'file',
        MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      ));
    } else {
      // Mobile/Desktop: fileData é o path do arquivo
      final file = File(fileData);
      if (!await file.exists()) {
        throw Exception('Arquivo não encontrado: $fileData');
      }
      formData.files.add(MapEntry(
        'file',
        await MultipartFile.fromFile(
          fileData,
          filename: fileName,
        ),
      ));
    }

    // Faz a requisição POST com multipart/form-data
    final res = await client.postMultipart('/courses/$courseId/materials', formData: formData);
    return MaterialItem.fromJson(res.data['material']);
  }

  Future<Map<String, dynamic>> downloadMaterial(String fileStorageId, {String? fileName}) async {
    // Baixa o arquivo como bytes
    final res = await client.dio.get(
      '/materials/$fileStorageId/download',
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );

    // Extrai o nome do arquivo do header Content-Disposition se disponível
    String? downloadedFileName = fileName;
    final contentDisposition = res.headers.value('content-disposition');
    if (contentDisposition != null) {
      // Tenta extrair o nome do arquivo do header
      // Formato: attachment; filename="arquivo.pdf" ou attachment; filename=arquivo.pdf
      final filenameMatch = RegExp(r'filename[^;=\n]*=([^;\n]+)').firstMatch(contentDisposition);
      if (filenameMatch != null) {
        final extractedName = filenameMatch.group(1);
        if (extractedName != null) {
          downloadedFileName = extractedName.trim().replaceAll('"', '').replaceAll("'", '');
        }
      }
    }

    // Converte bytes para base64 para compatibilidade com o código existente
    final base64Data = base64Encode(res.data as List<int>);

    return {
      'fileData': base64Data,
      'fileName': downloadedFileName ?? 'material',
      'bytes': res.data,
    };
  }
}

