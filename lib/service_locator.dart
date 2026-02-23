import 'package:get_it/get_it.dart';
import 'package:flutter_starter_example/repositories/ai_repository.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton<AiRepository>(AiRepository());
}
