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
    // IMPORTANT: for Flutter web running in the browser, localhost refers to the user's machine.
    // In most dev setups the backend runs on the developer machine LAN IP instead.
    // Prefer the LAN IP so the request reaches the backend.
    if (kIsWeb) {
      return baseUrl;
    }

    // Heuristic:
    // - Android Emulator uses 10.0.2.2
    // - Physical device should use the PC/LAN IP
    //
    // You can override by setting --dart-define=API_BASE_URL=http://x.x.x.x:7188
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }

    // Flutter doesn't provide direct emulator detection here without platform calls.
    // Keep the existing default for physical devices.
    return baseUrl;
  }

  static String getGraphqlUrl() => getApiUrl() + graphqlUrl;
}
