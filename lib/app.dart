part of 'main.dart';

const _bg = Color(0xFF0E1013);
const _panel = Color(0xFF181B20);
const _blue = Color(0xFF82A6F6);
const _muted = Color(0xFF858C97);

void main() => runApp(const BuddyApp());

class BuddyApp extends StatelessWidget {
  const BuddyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Buddy',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: _bg,
      colorScheme: const ColorScheme.dark(primary: _blue, surface: _bg),
      textSelectionTheme: const TextSelectionThemeData(cursorColor: _blue),
    ),
    home: const BuddyHome(),
  );
}
