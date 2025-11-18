// lib/src/ui/download_helper_web.dart
// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;

void downloadFileWeb(String fileData, String fileName) {
  final bytes = base64Decode(fileData);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}

// Função stub para web (não usada, mas necessária para compatibilidade)
Future<void> downloadFileIO(List<int> bytes, String fileName) async {
  // Na web, usa downloadFileWeb ao invés disso
  final base64Data = base64Encode(bytes);
  downloadFileWeb(base64Data, fileName);
}

