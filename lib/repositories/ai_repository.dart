import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_starter_example/models/models.dart';
import 'package:flutter_starter_example/repositories/repositories.dart';
import 'package:path_provider/path_provider.dart';

final _circleAreaTool = AiTool(
  name: "circle_area",
  description: "Calculates the area of a circle given its radius",
  function: ({required double radius}) {
    final area = math.pi * radius * radius;
    return "Circle with radius $radius has area ${area.toStringAsFixed(2)}";
  },
);

final _getWeather = AiTool(
  name: "get_weather",
  description: "Get the weather of a city",
  function: ({required String city}) async {
    final weather = await fetchWeather(city);
    return weather;
  },
);

class AiRepository {
  AiModel? _model;
  AiChat? _chat;

  AiModel? get model => _model;
  AiChat? get chat => _chat;

  AiRepository();

  Future<void> loadModel() async {
    final dir = await getApplicationDocumentsDirectory();
    final fileModel = File('${dir.path}/model.gguf');

    if (!await fileModel.exists()) {
      final data = await rootBundle.load('assets/model.gguf');
      await fileModel.writeAsBytes(data.buffer.asUint8List(), flush: true);
    }

    _model = await AiModel.load(modelPath: fileModel.path);
  }

  void createChat({bool enableTool = false}) {
    final List<AiTool> tools = enableTool ? [_circleAreaTool, _getWeather] : [];

    if (_model case final model?) {
      _chat = AiChat(model: model, tools: tools);
    }
  }
}
