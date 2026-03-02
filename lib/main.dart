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
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: ShadNeutralColorScheme.light(
          custom: {'surfaceMessage': Color.fromARGB(255, 245, 245, 245)},
        ),
      ),
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: ShadNeutralColorScheme.dark(
          custom: {'surfaceMessage': Color.fromARGB(255, 52, 52, 52)},
        ),
      ),
      appBuilder: (context) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
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
