import 'package:flutter/material.dart';
import 'package:flutter_starter_example/app.dart';
import 'package:flutter_starter_example/service_locator.dart';
import 'package:nobodywho/nobodywho.dart' as nobodywho;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await nobodywho.NobodyWho.init();
  setup();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: App());
  }
}
