import 'package:flutter/foundation.dart' show kIsWeb;

const bool useFakeApi = false; // set to false to use real backend

// Para Flutter Web, usa localhost. Para mobile, pode precisar do IP da máquina
const String apiBaseUrl = kIsWeb 
    ? 'http://localhost:8080/api'  // Web - localhost funciona
    : 'http://localhost:8080/api'; // Mobile - pode precisar do IP da máquina (ex: http://192.168.1.100:8080/api)
