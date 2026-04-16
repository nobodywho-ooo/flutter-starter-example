import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_starter_example/models/models.dart';
import 'package:flutter_starter_example/styles/styles.dart';
import 'package:nobodywho/nobodywho.dart' as nobodywho;
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:flutter_starter_example/service_locator.dart';
import 'package:flutter_starter_example/repositories/repositories.dart';
import 'package:flutter_starter_example/widgets/widgets.dart';

final _systemPrompt =
    "You are a technical documentation assistant. Always use the search tool to find relevant information before answering programming questions.";
final _knowledgeBase = [
  "Python 3.11 introduced performance improvements through faster CPython",
  "The Django framework is used for building web applications",
  "NumPy provides support for large multi-dimensional arrays",
  "Pandas is the standard library for data manipulation and analysis",
];
final _question = "What Python libraries are best for data analysis?";

class RagScreen extends StatefulWidget {
  const RagScreen({super.key});

  @override
  State<RagScreen> createState() => _RagScreenState();
}

class _RagScreenState extends State<RagScreen> {
  final aiRepository = getIt<AiRepository>();
  final _docEmbeddings = <Float32List>[];

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
      await aiRepository.loadReRankerModel();

      setState(() {
        _runningInit = false;
      });
    } catch (err) {
      debugPrint("Error loadEmbeddingModel/loadReRankerModel $err");
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
      final crossEncoder = aiRepository.crossEncoder;

      if ((encoder, crossEncoder) case (final encoder?, final crossEncoder?)) {
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

        aiRepository.createToolCallingChat(
          tools: [searchTool],
          systemPrompt: _systemPrompt,
        );

        final chat = aiRepository.chatWithToolCalling;

        if (chat case final chat?) {
          final response = await chat.ask(_question).completed();
          final answer = response
              .replaceAll(RegExp(r'<think>[\s\S]*?</think>\s*'), '')
              .trimLeft();

          setState(() {
            _result = answer;
          });
        } else {
          debugPrint("Error _ragDemo chatWithToolCalling not available");
          setState(() {
            _errorDemo = true;
          });
        }
      } else {
        debugPrint("Error _ragDemo encoder or crossEncoder not available");
        setState(() {
          _errorDemo = true;
        });
      }
    } catch (err) {
      debugPrint("Error _ragDemo $err");
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
            for (var item in _knowledgeBase)
              Padding(
                padding: Spacings.lg.top,
                child: Text(item, style: textTheme.p),
              ),
            Padding(
              padding: Spacings.xl.top,
              child: Text(_question, style: textTheme.p),
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
