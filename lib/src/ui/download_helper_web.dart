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

