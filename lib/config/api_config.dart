/// Flutter-side connection settings for the local Mac controller.
///
/// On a phone, pass the Mac's LAN address at launch, for example:
/// `flutter run --dart-define=BUDDY_SERVER_URL=http://192.168.1.20:8000`
/// Android emulator uses 10.0.2.2 to reach the host Mac. On a physical phone,
/// pass the Mac's Wi-Fi/LAN address with BUDDY_SERVER_URL.
abstract final class ApiConfig {
  static const serverBaseUrl = String.fromEnvironment(
    'BUDDY_SERVER_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
}
