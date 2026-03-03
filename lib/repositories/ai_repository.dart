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

final _getWeatherTool = AiTool(
  name: "get_weather",
  description: "Get the weather of a city",
  function: ({required String city}) async {
    final weather = await fetchWeather(city);
    return weather;
  },
);

class AiRepository {
  AiChatModel? _chatModel;
  AiEncoderModel? _encoderModel;
  AiCrossEncoderModel? _crossEncoderModel;
  AiChat? _chat;

  AiChatModel? get chatModel => _chatModel;
  AiEncoderModel? get encoderModel => _encoderModel;
  AiCrossEncoderModel? get crossEncoderModel => _crossEncoderModel;
  AiChat? get chat => _chat;

  AiRepository();

  Future<void> loadChatModel() async {
    final dir = await getApplicationDocumentsDirectory();
    final fileModel = File('${dir.path}/chat-model.gguf');

    if (!await fileModel.exists()) {
      final data = await rootBundle.load('assets/chat-model.gguf');
      await fileModel.writeAsBytes(data.buffer.asUint8List(), flush: true);
    }

    _chatModel = await AiChatModel.load(modelPath: fileModel.path);
  }

  Future<void> loadEmbeddingModel() async {
    final dir = await getApplicationDocumentsDirectory();
    final fileModel = File('${dir.path}/embedding-model.gguf');

    if (!await fileModel.exists()) {
      final data = await rootBundle.load('assets/embedding-model.gguf');
      await fileModel.writeAsBytes(data.buffer.asUint8List(), flush: true);
    }

    _encoderModel = await AiEncoderModel.fromPath(modelPath: fileModel.path);
  }

  Future<void> loadRerankerModel() async {
    final dir = await getApplicationDocumentsDirectory();
    final fileModel = File('${dir.path}/reranker-model.gguf');

    if (!await fileModel.exists()) {
      final data = await rootBundle.load('assets/reranker-model.gguf');
      await fileModel.writeAsBytes(data.buffer.asUint8List(), flush: true);
    }

    _crossEncoderModel = await AiCrossEncoderModel.fromPath(
      modelPath: fileModel.path,
    );
  }

  void dispose() {
    if (_chatModel case final model?) {
      if (!model.isDisposed) {
        model.dispose();
      }
    }
    if (_encoderModel case final model?) {
      if (!model.isDisposed) {
        model.dispose();
      }
    }
    if (_crossEncoderModel case final model?) {
      if (!model.isDisposed) {
        model.dispose();
      }
    }
  }

  void createChat({bool enableTool = false}) {
    final List<AiTool> tools = enableTool
        ? [_circleAreaTool, _getWeatherTool]
        : [];

    if (_chatModel case final model?) {
      _chat = AiChat(
        model: model,
        tools: tools,
        // Sampler example
        // sampler: AiSamplerBuilder()
        //     .temperature(temperature: 0.8)
        //     .topK(topK: 5)
        //     .dist(),
      );
    }
  }
}
