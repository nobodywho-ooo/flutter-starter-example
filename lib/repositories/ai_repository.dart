import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_starter_example/helpers/helpers.dart';
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
  AiChatModel? _visionChatModel;
  AiEncoder? _encoder;
  AiCrossEncoder? _crossEncoder;
  AiChat? _chat;
  AiChat? _chatWithToolCalling;
  AiChat? _visionChat;

  AiChatModel? get chatModel => _chatModel;
  AiChatModel? get visionChatModel => _visionChatModel;
  AiEncoder? get encoder => _encoder;
  AiCrossEncoder? get crossEncoder => _crossEncoder;
  AiChat? get chat => _chat;
  AiChat? get chatWithToolCalling => _chatWithToolCalling;
  AiChat? get visionChat => _visionChat;

  AiRepository();

  Future<void> loadChatModel() async {
    if (Platform.isAndroid) {
      final chatModelPath = await copyAssetToDocuments(
        'assets/chat-model.gguf',
      );

      _chatModel = await AiChatModel.load(modelPath: chatModelPath);
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final chatModelFile = File('${dir.path}/chat-model.gguf');

      final data = await rootBundle.load('assets/chat-model.gguf');
      await chatModelFile.writeAsBytes(data.buffer.asUint8List(), flush: true);

      _chatModel = await AiChatModel.load(modelPath: chatModelFile.path);
    }
  }

  Future<void> loadChatVisionModel() async {
    if (Platform.isAndroid) {
      final chatModelPath = await copyAssetToDocuments(
        'assets/chat-model.gguf',
      );
      final visionModelPath = await copyAssetToDocuments(
        'assets/vision-model.gguf',
      );

      _visionChatModel = await AiChatModel.load(
        modelPath: chatModelPath,
        imageIngestion: visionModelPath,
      );
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final chatModelFile = File('${dir.path}/chat-model.gguf');
      final visionModelFile = File('${dir.path}/vision-model.gguf');

      final data = await rootBundle.load('assets/chat-model.gguf');
      await chatModelFile.writeAsBytes(data.buffer.asUint8List(), flush: true);

      final visionData = await rootBundle.load('assets/vision-model.gguf');
      await visionModelFile.writeAsBytes(
        visionData.buffer.asUint8List(),
        flush: true,
      );

      _visionChatModel = await AiChatModel.load(
        modelPath: chatModelFile.path,
        imageIngestion: visionModelFile.path,
      );
    }
  }

  Future<void> loadEmbeddingModel() async {
    if (Platform.isAndroid) {
      final modelPath = await copyAssetToDocuments(
        'assets/embedding-model.gguf',
      );
      _encoder = await AiEncoder.fromPath(modelPath: modelPath);
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final fileModel = File('${dir.path}/embedding-model.gguf');

      final data = await rootBundle.load('assets/embedding-model.gguf');
      await fileModel.writeAsBytes(data.buffer.asUint8List(), flush: true);

      _encoder = await AiEncoder.fromPath(modelPath: fileModel.path);
    }
  }

  Future<void> loadReRankerModel() async {
    if (Platform.isAndroid) {
      final modelPath = await copyAssetToDocuments(
        'assets/reranker-model.gguf',
      );
      _crossEncoder = await AiCrossEncoder.fromPath(modelPath: modelPath);
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final fileModel = File('${dir.path}/reranker-model.gguf');

      final data = await rootBundle.load('assets/reranker-model.gguf');
      await fileModel.writeAsBytes(data.buffer.asUint8List(), flush: true);

      _crossEncoder = await AiCrossEncoder.fromPath(modelPath: fileModel.path);
    }
  }

  void dispose() {
    if (_chatModel case final model?) {
      if (!model.isDisposed) {
        model.dispose();
      }
    }
    if (_visionChatModel case final model?) {
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

  void createChat({String? systemPrompt}) {
    if (_chatModel case final model?) {
      _chat = AiChat(
        model: model,
        systemPrompt: systemPrompt,
        // Sampler example
        // sampler: AiSamplerBuilder()
        //     .temperature(temperature: 0.8)
        //     .topK(topK: 5)
        //     .dist(),
      );
    }
  }

  void createToolCallingChat({
    List<AiTool> tools = const [],
    String? systemPrompt,
  }) {
    if (_chatModel case final model?) {
      _chatWithToolCalling = AiChat(
        model: model,
        tools: tools,
        systemPrompt: systemPrompt,
      );
    }
  }

  void createVisionChat({String? systemPrompt}) {
    if (_visionChatModel case final model?) {
      _visionChat = AiChat(model: model, systemPrompt: systemPrompt);
    }
  }
}
