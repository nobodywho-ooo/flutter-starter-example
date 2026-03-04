import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_starter_example/models/models.dart';
import 'package:flutter_starter_example/repositories/repositories.dart';
import 'package:path_provider/path_provider.dart';

final circleAreaTool = AiTool(
  name: "circle_area",
  description: "Calculates the area of a circle given its radius",
  function: ({required double radius}) {
    final area = math.pi * radius * radius;
    return "Circle with radius $radius has area ${area.toStringAsFixed(2)}";
  },
);

final getWeatherTool = AiTool(
  name: "get_weather",
  description: "Get the weather of a city",
  function: ({required String city}) async {
    final weather = await fetchWeather(city);
    return weather;
  },
);

class AiRepository {
  AiChatModel? _chatModel;
  AiEncoder? _encoder;
  AiCrossEncoder? _crossEncoder;
  AiChat? _chat;

  AiChatModel? get chatModel => _chatModel;
  AiEncoder? get encoder => _encoder;
  AiCrossEncoder? get crossEncoder => _crossEncoder;
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

    _encoder = await AiEncoder.fromPath(modelPath: fileModel.path);
  }

  Future<void> loadReRankerModel() async {
    final dir = await getApplicationDocumentsDirectory();
    final fileModel = File('${dir.path}/reranker-model.gguf');

    if (!await fileModel.exists()) {
      final data = await rootBundle.load('assets/reranker-model.gguf');
      await fileModel.writeAsBytes(data.buffer.asUint8List(), flush: true);
    }

    _crossEncoder = await AiCrossEncoder.fromPath(modelPath: fileModel.path);
  }

  void dispose() {
    if (_chatModel case final model?) {
      if (!model.isDisposed) {
        model.dispose();
      }
    }
    if (_encoder case final model?) {
      if (!model.isDisposed) {
        model.dispose();
      }
    }
    if (_crossEncoder case final model?) {
      if (!model.isDisposed) {
        model.dispose();
      }
    }
  }

  void createChat({List<AiTool> tools = const [], String? systemPrompt}) {
    if (_chatModel case final model?) {
      _chat = AiChat(
        model: model,
        tools: tools,
        systemPrompt: systemPrompt,
        // Sampler example
        // sampler: AiSamplerBuilder()
        //     .temperature(temperature: 0.8)
        //     .topK(topK: 5)
        //     .dist(),
      );
    }
  }
}
