// lib/src/ui/download_helper_io.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void downloadFileWeb(String fileData, String fileName) {
  // Em mobile/desktop, implementar download usando path_provider
  // Por enquanto, apenas retorna
}

Future<void> downloadFileIO(List<int> bytes, String fileName) async {
  try {
    // Obtém o diretório de downloads
    Directory? directory;
    if (Platform.isAndroid) {
      // Android: tenta usar o diretório de downloads externo
      try {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          // Fallback para o diretório de documentos
          directory = await getApplicationDocumentsDirectory();
        }
      } catch (e) {
        // Se falhar, usa o diretório de documentos
        directory = await getApplicationDocumentsDirectory();
      }
    } else if (Platform.isIOS) {
      // iOS: usa o diretório de documentos
      directory = await getApplicationDocumentsDirectory();
    } else {
      // Desktop: usa o diretório de downloads do usuário
      final downloadsDir = await getDownloadsDirectory();
      directory = downloadsDir ?? await getApplicationDocumentsDirectory();
    }

    if (directory == null) {
      throw Exception('Não foi possível encontrar o diretório de downloads');
    }

    // Cria o arquivo
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
  } catch (e) {
    // Se falhar, tenta salvar no diretório de documentos
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
    } catch (e2) {
      throw Exception('Erro ao salvar arquivo: $e2');
    }
  }
}

