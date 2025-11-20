// lib/src/ui/download_helper.dart
export 'download_helper_io.dart' if (dart.library.html) 'download_helper_web.dart';

// Exporta a função downloadFileIO para uso em mobile/desktop
import 'download_helper_io.dart' if (dart.library.html) 'download_helper_web.dart' as helper;
Future<void> downloadFileIO(List<int> bytes, String fileName) => helper.downloadFileIO(bytes, fileName);

