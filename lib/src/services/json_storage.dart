// lib/src/services/json_storage.dart
// Conditional export: use a implementação IO (files) em mobile/desktop,
// e a implementação web quando compilado para web.
export 'json_storage_io.dart' if (dart.library.html) 'json_storage_web.dart';
