import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_starter_example/styles/styles.dart';
import 'package:nobodywho/nobodywho.dart' as nobodywho;
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_starter_example/service_locator.dart';
import 'package:flutter_starter_example/repositories/repositories.dart';
import 'package:flutter_starter_example/widgets/widgets.dart';

final _query = "What language should I use for database queries?";
// Your knowledge base
final _documents = [
  "Python supports multiple programming paradigms including object-oriented and functional",
  "JavaScript is primarily used for web development and runs in browsers",
  "SQL is a domain-specific language for managing relational databases",
  "Git is a version control system for tracking changes in source code",
];

class EmbeddingsScreen extends StatefulWidget {
  const EmbeddingsScreen({super.key});

  @override
  State<EmbeddingsScreen> createState() => _EmbeddingsScreenState();
}

class _EmbeddingsScreenState extends State<EmbeddingsScreen> {
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
      await aiRepository.loadEmbeddingModel();

      setState(() {
        _runningInit = false;
      });
    } catch (err) {
      debugPrint("Error loadEmbeddingModel $err");
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
      final encoder = aiRepository.encoder;

      if (encoder case final encoder?) {
        // Pre-compute document embeddings
        final docEmbeddings = <Float32List>[];
        for (final doc in _documents) {
          docEmbeddings.add(await encoder.encode(text: doc));
        }

        // Search query
        final queryEmbedding = await encoder.encode(text: _query);

        // Find the most relevant document
        double maxSimilarity = -1;
        int bestIdx = 0;
        for (int i = 0; i < docEmbeddings.length; i++) {
          final similarity = nobodywho.cosineSimilarity(
            a: queryEmbedding.toList(),
            b: docEmbeddings[i].toList(),
          );
          if (similarity > maxSimilarity) {
            maxSimilarity = similarity;
            bestIdx = i;
          }
        }

        setState(() {
          _result = "Result: ${_documents[bestIdx]}";
        });
      } else {
        debugPrint("Error _embeddingDemo encoder not available");
        setState(() {
          _errorDemo = true;
        });
      }
    } catch (err) {
      debugPrint("Error _embeddingDemo $err");
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
            for (var doc in _documents)
              Padding(
                padding: Spacings.lg.top,
                child: Text(doc, style: textTheme.p),
              ),
            Padding(
              padding: Spacings.xl.top,
              child: Text(_query, style: textTheme.p),
            ),
            Padding(
              padding: Spacings.xl.top,
              child: ShadButton(onPressed: _runDemo, child: Text("Analyse")),
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
                  child: Text(
                    _result,
                    style: textTheme.p.copyWith(fontStyle: FontStyle.italic),
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
