import 'package:get_it/get_it.dart';
import 'package:flutter_starter_example/repositories/repositories.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton<AiRepository>(AiRepository());
}
