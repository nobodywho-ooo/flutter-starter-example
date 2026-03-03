import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_starter_example/service_locator.dart';
import 'package:flutter_starter_example/repositories/repositories.dart';
import 'package:nobodywho/nobodywho.dart' as nobodywho;
import 'package:shadcn_ui/shadcn_ui.dart';

class EmbeddingIcon extends StatelessWidget {
  const EmbeddingIcon({super.key});

  Future<void> _embeddingDemo(BuildContext context) async {
    final aiRepository = getIt<AiRepository>();

    try {
      if (aiRepository.encoder == null) {
        await aiRepository.loadEmbeddingModel();
      }

      final encoder = aiRepository.encoder;

      if (encoder case final encoder?) {
        // Your knowledge base
        final documents = [
          "Python supports multiple programming paradigms including object-oriented and functional",
          "JavaScript is primarily used for web development and runs in browsers",
          "SQL is a domain-specific language for managing relational databases",
          "Git is a version control system for tracking changes in source code",
        ];

        // Pre-compute document embeddings
        final docEmbeddings = <Float32List>[];
        for (final doc in documents) {
          docEmbeddings.add(await encoder.encode(text: doc));
        }

        // Search query
        final query = "What language should I use for database queries?";
        final queryEmbedding = await encoder.encode(text: query);

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

        if (context.mounted) {
          _showDialog(context: context, title: query, body: documents[bestIdx]);
        }
      }
    } catch (err) {
      debugPrint("Error _embeddingDemo $err");
    }
  }

  Future<void> _showDialog({
    required BuildContext context,
    required String title,
    required String body,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _embeddingDemo(context),
      child: const Icon(LucideIcons.book),
    );
  }
}
