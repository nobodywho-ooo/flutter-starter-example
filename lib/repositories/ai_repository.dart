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
  AiChatModel? _visionHearingChatModel;
  AiEncoder? _encoder;
  AiCrossEncoder? _crossEncoder;
  AiChat? _chat;
  AiChat? _chatWithToolCalling;
  AiChat? _visionHearingChat;

  AiChatModel? get chatModel => _chatModel;
  AiChatModel? get visionHearingChatModel => _visionHearingChatModel;
  AiEncoder? get encoder => _encoder;
  AiCrossEncoder? get crossEncoder => _crossEncoder;
  AiChat? get chat => _chat;
  AiChat? get chatWithToolCalling => _chatWithToolCalling;
  AiChat? get visionHearingChat => _visionHearingChat;

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

  Future<void> loadChatVisionHearingModel() async {
    if (Platform.isAndroid) {
      final chatModelPath = await copyAssetToDocuments(
        'assets/chat-model.gguf',
      );
      final projectionModelPath = await copyAssetToDocuments(
        'assets/projection-model.gguf',
      );

      _visionHearingChatModel = await AiChatModel.load(
        modelPath: chatModelPath,
        imageIngestion: projectionModelPath,
      );
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final chatModelFile = File('${dir.path}/chat-model.gguf');
      final projectionModelFile = File('${dir.path}/projection-model.gguf');

      final chatData = await rootBundle.load('assets/chat-model.gguf');
      await chatModelFile.writeAsBytes(
        chatData.buffer.asUint8List(),
        flush: true,
      );

      final projectionData = await rootBundle.load(
        'assets/projection-model.gguf',
      );
      await projectionModelFile.writeAsBytes(
        projectionData.buffer.asUint8List(),
        flush: true,
      );

      _visionHearingChatModel = await AiChatModel.load(
        modelPath: chatModelFile.path,
        imageIngestion: projectionModelFile.path,
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
    if (_visionHearingChatModel case final model?) {
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

  void createVisionHearingChat({String? systemPrompt}) {
    if (_visionHearingChatModel case final model?) {
      _visionHearingChat = AiChat(model: model, systemPrompt: systemPrompt);
    }
  }
}
