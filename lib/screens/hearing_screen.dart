import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_starter_example/service_locator.dart';
import 'package:flutter_starter_example/repositories/repositories.dart';
import 'package:flutter_starter_example/widgets/widgets.dart';
import 'package:flutter_starter_example/models/models.dart';
import 'package:flutter_starter_example/styles/styles.dart';

class HearingScreen extends StatefulWidget {
  const HearingScreen({super.key});

  @override
  State<HearingScreen> createState() => _HearingScreenState();
}

class _HearingScreenState extends State<HearingScreen> {
  final aiRepository = getIt<AiRepository>();

  bool _errorInit = false;
  bool _errorDemo = false;
  bool _runningDemo = false;
  bool _runningInit = false;
  String _result = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      _errorInit = false;
      _runningInit = true;
    });

    // Avoid blocking drawer animation if your model is big
    await Future.delayed(const Duration(seconds: 1));

    try {
      await aiRepository.loadChatVisionHearingModel();
      aiRepository.createVisionHearingChat();

      setState(() {
        _runningInit = false;
      });
    } catch (err) {
      debugPrint("Error loadChatVisionHearingModel $err");
      setState(() {
        _errorInit = true;
        _runningInit = false;
      });
    }
  }

  Future<void> _runDemo() async {
    setState(() {
      _errorDemo = false;
      _runningDemo = true;
      _result = '';
    });
    try {
      final visionHearingChat = aiRepository.visionHearingChat;

      if (visionHearingChat case final visionHearingChat?) {
        final dir = await getApplicationDocumentsDirectory();
        final audioFile = File('${dir.path}/audio.mp3');

        if (!await audioFile.exists()) {
          final data = await rootBundle.load('assets/audio.mp3');
          await audioFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
        }

        final prompt = AiPrompt([
          AiTextPart("Tell me what you hear in the audio."),
          AiAudioPart(audioFile.path),
        ]);

        final response = await visionHearingChat
            .askWithPrompt(prompt)
            .completed();

        setState(() {
          _result = "Result: $response}";
        });
      } else {
        debugPrint("Error _audioIngestion visionHearingChat not available");
        setState(() {
          _errorDemo = true;
        });
      }
    } catch (err) {
      debugPrint("Error _hearingDemo $err");
      setState(() {
        _errorDemo = true;
      });
    } finally {
      setState(() {
        _runningDemo = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final textTheme = theme.textTheme;

    if (_errorInit) {
      return ErrorIndicator(
        retry: _init,
        message: 'Error during initialization',
      );
    }

    if (_runningInit) {
      return LoadingIndicator();
    }

    return SingleChildScrollView(
      child: Padding(
        padding: Spacings.lg.horizontal,
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Padding(
              padding: Spacings.xl.top,
              child: Text("Transcribe audio.mp3", style: textTheme.h3),
            ),
            Padding(
              padding: Spacings.xl.top,
              child: ShadButton(onPressed: _runDemo, child: Text("Get speech")),
            ),
            if (_runningDemo) ...[
              Padding(
                padding: Spacings.xl.vertical,
                child: CircularProgressIndicator(color: Colors.blueGrey),
              ),
            ] else ...[
              if (_result.isNotEmpty)
                Padding(
                  padding: Spacings.xl.vertical,
                  child: GptMarkdown(
                    _result,
                    style: textTheme.p,
                    highlightBuilder: (context, text, style) =>
                        HighlightText(text: text, style: style),
                  ),
                ),
              if (_errorDemo)
                Padding(padding: Spacings.xl.vertical, child: ErrorIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
