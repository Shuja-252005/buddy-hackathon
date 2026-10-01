/// Flutter-side connection settings for the local Mac controller.
///
/// On a phone, pass the Mac's LAN address at launch, for example:
/// `flutter run --dart-define=BUDDY_SERVER_URL=http://192.168.1.20:8000`
/// The Python server is added in a later project phase.
abstract final class ApiConfig {
  static const serverBaseUrl = String.fromEnvironment(
    'BUDDY_SERVER_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
}
