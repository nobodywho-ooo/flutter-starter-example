import 'dart:math' as math;

import 'package:flutter_starter_example/helpers/helpers.dart';
import 'package:flutter_starter_example/models/models.dart';
import 'package:flutter_starter_example/repositories/repositories.dart';

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

  Future<void> loadChatVisionModel() async {
    final chatModelPath = await copyAssetToDocuments('assets/chat-model.gguf');
    final visionModelPath = await copyAssetToDocuments('assets/vision-model.gguf');

    _chatModel = await AiChatModel.load(
      modelPath: chatModelPath,
      imageIngestion: visionModelPath,
    );
  }

  Future<void> loadEmbeddingModel() async {
    final modelPath = await copyAssetToDocuments('assets/embedding-model.gguf');
    _encoder = await AiEncoder.fromPath(modelPath: modelPath);
  }

  Future<void> loadReRankerModel() async {
    final modelPath = await copyAssetToDocuments('assets/reranker-model.gguf');
    _crossEncoder = await AiCrossEncoder.fromPath(modelPath: modelPath);
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
