import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_starter_example/service_locator.dart';
import 'package:flutter_starter_example/repositories/repositories.dart';
import 'package:flutter_starter_example/models/models.dart';
import 'package:nobodywho/nobodywho.dart' as nobodywho;
import 'package:shadcn_ui/shadcn_ui.dart';

final _systemPrompt =
    "You are a technical documentation assistant. Always use the search tool to find relevant information before answering programming questions.";

class RagIcon extends StatefulWidget {
  const RagIcon({super.key});

  @override
  State<RagIcon> createState() => _RagIconState();
}

class _RagIconState extends State<RagIcon> {
  bool _loading = false;

  // Large knowledge base
  final _knowledgeBase = [
    "Python 3.11 introduced performance improvements through faster CPython",
    "The Django framework is used for building web applications",
    "NumPy provides support for large multi-dimensional arrays",
    "Pandas is the standard library for data manipulation and analysis",
    // ... 100+ more documents
  ];
  final _docEmbeddings = <Float32List>[];

  Future<void> _ragDemo(BuildContext context) async {
    final aiRepository = getIt<AiRepository>();

    try {
      setState(() {
        _loading = true;
      });
      if (aiRepository.encoder == null) {
        await aiRepository.loadEmbeddingModel();
      }
      final encoder = aiRepository.encoder;

      if (aiRepository.crossEncoder == null) {
        await aiRepository.loadReRankerModel();
      }
      final crossEncoder = aiRepository.crossEncoder;

      if ((encoder, crossEncoder, aiRepository.chat) case (
        final encoder?,
        final crossEncoder?,
        final chat?,
      )) {
        // Precompute embeddings for all documents
        for (final doc in _knowledgeBase) {
          _docEmbeddings.add(await encoder.encode(text: doc));
        }

        Future<String> search({required String query}) async {
          // Stage 1: Fast filtering with embeddings
          final queryEmbedding = await encoder.encode(text: query);
          final similarities = <(String, double)>[];
          for (int i = 0; i < _knowledgeBase.length; i++) {
            final similarity = nobodywho.cosineSimilarity(
              a: queryEmbedding.toList(),
              b: _docEmbeddings[i].toList(),
            );
            similarities.add((_knowledgeBase[i], similarity));
          }
          // Get top 20 candidates
          similarities.sort((a, b) => b.$2.compareTo(a.$2));
          final candidateDocs = similarities.take(20).map((e) => e.$1).toList();

          // Stage 2: Precise ranking with cross-encoder
          final ranked = await crossEncoder.rankAndSort(
            query: query,
            documents: candidateDocs,
          );

          // Return top 3 most relevant
          final topResults = ranked.take(3).map((e) => e.$1).toList();
          return topResults.join("\n---\n");
        }

        final searchTool = AiTool(
          function: search,
          name: "search",
          description:
              "Search the knowledge base for information relevant to the query",
        );

        aiRepository.createChat(
          tools: [searchTool],
          systemPrompt: _systemPrompt,
        );

        final question = "What Python libraries are best for data analysis?";
        final response = await chat.ask(question).completed();

        if (context.mounted) {
          _showDialog(
            context: context,
            title: question,
            body: response
                .replaceAll(RegExp(r'<think>[\s\S]*?</think>\s*'), '')
                .trimLeft(),
          );
        }
      }
    } catch (err) {
      debugPrint("Error _ragDemo $err");
    } finally {
      setState(() {
        _loading = false;
      });
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
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: SizedBox(
          height: 30,
          width: 30,
          child: CircularProgressIndicator(),
        ),
      );
    }

    return IconButton(
      onPressed: () => _ragDemo(context),
      icon: const Icon(LucideIcons.fileStack),
    );
  }
}
