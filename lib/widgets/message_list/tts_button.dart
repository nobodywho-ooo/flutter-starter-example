import 'package:flutter/material.dart';
import 'package:flutter_starter_example/repositories/repositories.dart';
import 'package:flutter_starter_example/service_locator.dart';
import 'package:flutter_starter_example/styles/styles.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TtsButton extends StatefulWidget {
  const TtsButton({super.key, required this.text});

  final String text;

  @override
  State<TtsButton> createState() => _TtsButtonState();
}

class _TtsButtonState extends State<TtsButton> {
  final _aiRepository = getIt<AiRepository>();
  final _player = AudioPlayer();

  bool _loading = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  bool _isPlaying(PlayerState? state) =>
      state != null &&
      state.playing &&
      state.processingState != ProcessingState.completed;

  Future<void> _onPressed() async {
    if (_isPlaying(_player.playerState)) {
      await _player.stop();
      return;
    }

    setState(() => _loading = true);

    try {
      final file = await _aiRepository.synthesizeToFile(widget.text);
      if (!mounted) {
        return;
      }

      await _player.setFilePath(file.path);

      if (!mounted) {
        return;
      }

      setState(() => _loading = false);

      await _player.play();

      if (mounted && _player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero);
        await _player.pause();
      }
    } catch (err) {
      if (!mounted) {
        return;
      }

      setState(() => _loading = false);
      debugPrint("Text-to-speech failed: $err");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _onPressed,
      child: SizedBox(
        width: Spacings.xl.value,
        height: Spacings.xl.value,
        child: _loading
            ? const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blueGrey,
              )
            : StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  return Icon(
                    _isPlaying(snapshot.data)
                        ? LucideIcons.circleStop
                        : LucideIcons.volume2,
                    color: _isPlaying(snapshot.data)
                        ? Colors.red
                        : Colors.blueGrey,
                    size: Spacings.xl.value,
                  );
                },
              ),
      ),
    );
  }
}
