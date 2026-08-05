import 'package:flutter/material.dart';
import 'package:flutter_starter_example/repositories/repositories.dart';
import 'package:flutter_starter_example/service_locator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

enum _SttStatus { idle, recording, processing }

class SttButton extends StatefulWidget {
  const SttButton({
    super.key,
    required this.controller,
    this.size = 26.0,
    this.enabled = true,
  });

  final TextEditingController controller;
  final double size;
  final bool enabled;

  @override
  State<SttButton> createState() => _SttButtonState();
}

class _SttButtonState extends State<SttButton> {
  final _aiRepository = getIt<AiRepository>();
  final _recorder = AudioRecorder();

  _SttStatus _status = _SttStatus.idle;

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _onPressed() async {
    switch (_status) {
      case _SttStatus.processing:
        return;
      case _SttStatus.idle:
        await _startRecording();
      case _SttStatus.recording:
        await _stopAndTranscribe();
    }
  }

  Future<void> _startRecording() async {
    try {
      if (!await _recorder.hasPermission()) return;

      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/stt_recording.wav';

      // Mono 16 kHz WAV — the format Whisper works best with.
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: path,
      );

      if (!mounted) {
        return;
      }

      setState(() => _status = _SttStatus.recording);
    } catch (err) {
      debugPrint('Speech-to-text recording failed: $err');

      if (mounted) {
        setState(() => _status = _SttStatus.idle);
      }
    }
  }

  Future<void> _stopAndTranscribe() async {
    setState(() => _status = _SttStatus.processing);

    try {
      final path = await _recorder.stop();

      if (path == null) {
        if (mounted) {
          setState(() => _status = _SttStatus.idle);
        }
        return;
      }

      final transcript = (await _aiRepository.transcribe(path)).trim();

      if (mounted && transcript.isNotEmpty) {
        _appendToController(transcript);
      }
    } catch (err) {
      debugPrint('Speech-to-text transcription failed: $err');
    } finally {
      if (mounted) {
        setState(() => _status = _SttStatus.idle);
      }
    }
  }

  void _appendToController(String text) {
    final existing = widget.controller.text;
    final needsSpace = existing.isNotEmpty && !existing.endsWith(' ');
    final combined = existing.isEmpty
        ? text
        : '$existing${needsSpace ? ' ' : ''}$text';

    widget.controller.value = TextEditingValue(
      text: combined,
      selection: TextSelection.collapsed(offset: combined.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    if (_status == _SttStatus.processing) {
      return SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.blueGrey,
        ),
      );
    }

    final recording = _status == _SttStatus.recording;
    final enabled = widget.enabled || recording;

    return GestureDetector(
      onTap: enabled ? _onPressed : null,
      child: Icon(
        recording ? LucideIcons.circleStop : LucideIcons.mic,
        size: size,
        color: recording
            ? Colors.red
            : (enabled ? Colors.blueGrey : Colors.grey),
      ),
    );
  }
}
