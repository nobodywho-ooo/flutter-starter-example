import 'dart:io';

import 'package:flutter/services.dart';
import 'package:nobodywho/nobodywho.dart' as nobodywho;
import 'package:path_provider/path_provider.dart';

class AiRepository {
  nobodywho.Model? _model;
  nobodywho.Chat? _chat;

  nobodywho.Model? get model => _model;
  nobodywho.Chat? get chat => _chat;

  AiRepository();

  Future<void> loadModel() async {
    final dir = await getApplicationDocumentsDirectory();
    final fileModel = File('${dir.path}/model.gguf');

    if (!await fileModel.exists()) {
      final data = await rootBundle.load('assets/model.gguf');
      await fileModel.writeAsBytes(data.buffer.asUint8List(), flush: true);
    }

    _model = await nobodywho.Model.load(modelPath: fileModel.path);
  }

  void createChat() {
    if (_model case final model?) {
      _chat = nobodywho.Chat(model: model);
    }
  }
}
