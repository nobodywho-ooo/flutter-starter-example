import 'package:material_ui/material_ui.dart';
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
    return ShadApp.custom(
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
        // ShadApp still exposes a `package:flutter/material` theme
        final materialTheme = _materialTheme(ShadTheme.of(context));

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: materialTheme,
          darkTheme: materialTheme.copyWith(
            dialogTheme: DialogThemeData(backgroundColor: Colors.grey[850]),
            bottomSheetTheme: BottomSheetThemeData(
              backgroundColor: Colors.grey[850],
            ),
          ),
          home: App(),
          builder: (context, child) {
            // shadcn_ui has not migrated to `material_ui` yet.
            // ignore: deprecated_member_use
            return MaterialUiCompatibilityBridge(
              child: ShadAppBuilder(child: child!),
            );
          },
        );
      },
    );
  }
}

/// Mirrors the Material theme `ShadApp` builds internally, but as a
/// `material_ui` [ThemeData].
ThemeData _materialTheme(ShadThemeData shadTheme) {
  final colors = shadTheme.colorScheme;

  return ThemeData(
    fontFamily: shadTheme.textTheme.family,
    brightness: shadTheme.brightness,
    colorScheme: ColorScheme(
      brightness: shadTheme.brightness,
      primary: colors.primary,
      onPrimary: colors.primaryForeground,
      secondary: colors.secondary,
      onSecondary: colors.secondaryForeground,
      error: colors.destructive,
      onError: colors.destructiveForeground,
      surface: colors.background,
      onSurface: colors.foreground,
    ),
    scaffoldBackgroundColor: colors.background,
    dividerTheme: DividerThemeData(
      color: shadTheme.separatorTheme.color ?? colors.border,
      thickness: shadTheme.separatorTheme.thickness ?? 1,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: colors.primary,
      selectionColor: colors.selection,
      selectionHandleColor: colors.primary,
    ),
    iconTheme: IconThemeData(size: 16, color: colors.foreground),
    scrollbarTheme: ScrollbarThemeData(
      crossAxisMargin: 1,
      mainAxisMargin: 1,
      thickness: const WidgetStatePropertyAll(8),
      radius: const Radius.circular(999),
      thumbColor: WidgetStatePropertyAll(colors.border),
    ),
  );
}
