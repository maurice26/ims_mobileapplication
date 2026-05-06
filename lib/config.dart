import 'package:flutter/foundation.dart';

class Config {
  static const int apiPort = 7188;

  // Backend API base URLs (port $apiPort)
  // Web (chrome): localhost:$apiPort
  // Android Emulator: 10.0.2.2:$apiPort
  // Physical Android/iOS: $(ipconfig WiFi IPv4):$apiPort e.g. 192.168.x.x:$apiPort
  static const String baseUrl = 'http://192.168.100.122:$apiPort';
  static const String emulatorUrl = 'http://10.0.2.2:$apiPort';
  static const String localhostUrl = 'http://localhost:$apiPort';
  static const String graphqlUrl = '/graphql';

  static String getApiUrl() {
    if (kIsWeb) {
      return localhostUrl;
    }
    // TODO: Improve: detect emulator vs physical (kIsWeb false branch)
    // For now defaults to physical IP - update baseUrl IP as needed
    return baseUrl;
  }

  static String getGraphqlUrl() => getApiUrl() + graphqlUrl;
}
