import 'package:flutter/material.dart';
import 'package:flutter_starter_example/app.dart';
import 'package:flutter_starter_example/service_locator.dart';
import 'package:nobodywho/nobodywho.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NobodyWho.init();
  setup();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;

    return ShadApp.custom(
      themeMode: themeMode,
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: ShadColorScheme.fromName(
          'neutral',
          brightness: Brightness.dark,
        ),
      ),
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: ShadColorScheme.fromName(
          'neutral',
          brightness: Brightness.light,
        ),
      ),
      appBuilder: (context) {
        return MaterialApp(
          theme: Theme.of(context),
          home: App(),
          builder: (context, child) {
            return ShadAppBuilder(child: child!);
          },
        );
      },
    );
  }
}
