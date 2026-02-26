import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_starter_example/models/ai_model.dart';
import 'package:path_provider/path_provider.dart';

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

  void createChat() {
    if (_model case final model?) {
      _chat = AiChat(model: model);
    }
  }
}
