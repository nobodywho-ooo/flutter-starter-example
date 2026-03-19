import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_starter_example/service_locator.dart';
import 'package:flutter_starter_example/repositories/repositories.dart';
import 'package:flutter_starter_example/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_starter_example/styles/styles.dart';
import 'package:nobodywho/nobodywho.dart' as nobodywho;
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

final _systemPrompt =
    "You are a technical documentation assistant. Always use the search tool to find relevant information before answering programming questions.";
final _featureNotAvailable =
    "Not available - make sure you have the downloaded the model(s)";

class ChatOptionsIconButton extends StatelessWidget {
  const ChatOptionsIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashColor: Colors.transparent,
      onPressed: () => showModalBottomSheet(
        context: context,
        builder: (_) => _BottomSheet(),
      ),
      icon: const Icon(LucideIcons.ellipsis),
    );
  }
}

class _BottomSheet extends StatefulWidget {
  const _BottomSheet();

  @override
  State<_BottomSheet> createState() => _BottomSheetState();
}

class _BottomSheetState extends State<_BottomSheet> {
  final aiRepository = getIt<AiRepository>();
  final _knowledgeBase = [
    "Python 3.11 introduced performance improvements through faster CPython",
    "The Django framework is used for building web applications",
    "NumPy provides support for large multi-dimensional arrays",
    "Pandas is the standard library for data manipulation and analysis",
  ];
  final _docEmbeddings = <Float32List>[];
  bool _loading = false;
  bool _embeddingsAvailable = false;
  bool _ragAvailable = false;
  bool _visionAvailable = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
    });

    try {
      await aiRepository.loadReRankerModel();

      setState(() {
        _ragAvailable = true;
      });
    } catch (e) {
      setState(() {
        _ragAvailable = false;
      });
    }

    try {
      await aiRepository.loadEmbeddingModel();
      setState(() {
        _embeddingsAvailable = true;
      });
    } catch (e) {
      setState(() {
        _embeddingsAvailable = false;
        _ragAvailable = false;
      });
    }

    try {
      await aiRepository.loadChatVisionModel();
      aiRepository.createVisionChat();
      setState(() {
        _visionAvailable = true;
      });
    } catch (e) {
      setState(() {
        _visionAvailable = false;
      });
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _ragDemo(BuildContext context) async {
    try {
      setState(() {
        _loading = true;
      });
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

        final question = "What Python libraries are best for data analysis?";

        final chat = aiRepository.chatWithToolCalling;

        if (chat case final chat?) {
          final response = await chat.ask(question).completed();

          if (context.mounted) {
            Navigator.of(context).pop();
            _showDialog(
              context: context,
              title: question,
              body: response
                  .replaceAll(RegExp(r'<think>[\s\S]*?</think>\s*'), '')
                  .trimLeft(),
            );
          }
        } else {
          debugPrint("Error _ragDemo chatWithToolCalling not available");
        }
      } else {
        debugPrint("Error _ragDemo encoder or crossEncoder not available");
      }
    } catch (err) {
      debugPrint("Error _ragDemo $err");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _embeddingDemo(BuildContext context) async {
    try {
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
          Navigator.of(context).pop();
          _showDialog(context: context, title: query, body: documents[bestIdx]);
        }
      } else {
        debugPrint("Error _embeddingDemo encoder not available");
      }
    } catch (err) {
      debugPrint("Error _embeddingDemo $err");
    }
  }

  Future<void> _imageIngestionDemo(BuildContext context) async {
    try {
      setState(() {
        _loading = true;
      });
      final visionChat = aiRepository.visionChat;

      if (visionChat case final visionChat?) {
        final dir = await getApplicationDocumentsDirectory();
        final imageFile = File('${dir.path}/image-1.png');

        if (!await imageFile.exists()) {
          final data = await rootBundle.load('assets/image-1.png');
          await imageFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
        }

        final prompt = AiPrompt([
          AiTextPart("Describe what you see in the image"),
          AiImagePart(imageFile.path),
        ]);

        final response = await visionChat.askWithPrompt(prompt).completed();

        if (context.mounted) {
          Navigator.of(context).pop();
          _showDialog(
            context: context,
            title: "Image description",
            body: response,
          );
        }
      } else {
        debugPrint("Error _imageIngestion visionChat not available");
      }
    } catch (err) {
      debugPrint("Error _imageIngestion $err");
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
    final theme = ShadTheme.of(context);
    final textTheme = theme.textTheme;

    return SizedBox(
      width: double.infinity,
      height: 400,
      child: Padding(
        padding: Spacings.xl.horizontal,
        child: _loading
            ? Center(
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: CircularProgressIndicator(color: Colors.blueGrey),
                ),
              )
            : Column(
                mainAxisAlignment: .start,
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                children: [
                  Spacings.xxl.verticalSpace,
                  Text('Examples', style: textTheme.h3),
                  Spacings.md.verticalSpace,
                  ListTile(
                    splashColor: Colors.transparent,
                    leading: const Icon(
                      LucideIcons.search,
                      color: Colors.blueGrey,
                    ),
                    contentPadding: Spacings.zero.all,
                    title: Text('Embeddings', style: textTheme.large),
                    subtitle: Text(
                      _embeddingsAvailable
                          ? 'Use embeddings to find the relevant document'
                          : _featureNotAvailable,
                      style: textTheme.p.copyWith(
                        color: _embeddingsAvailable
                            ? theme.colorScheme.mutedForeground
                            : theme.colorScheme.destructive,
                      ),
                    ),
                    onTap: () => _embeddingDemo(context),
                  ),
                  Spacings.xs.verticalSpace,
                  ListTile(
                    splashColor: Colors.transparent,
                    leading: const Icon(
                      LucideIcons.file,
                      color: Colors.blueGrey,
                    ),
                    contentPadding: Spacings.zero.all,
                    title: Text('RAG', style: textTheme.large),
                    subtitle: Text(
                      _ragAvailable
                          ? 'Demonstrate a two-stage retrieval system using RAG'
                          : _featureNotAvailable,
                      style: textTheme.p.copyWith(
                        color: _ragAvailable
                            ? theme.colorScheme.mutedForeground
                            : theme.colorScheme.destructive,
                      ),
                    ),
                    onTap: () => _ragDemo(context),
                  ),
                  Spacings.xs.verticalSpace,
                  ListTile(
                    splashColor: Colors.transparent,
                    leading: const Icon(
                      LucideIcons.image,
                      color: Colors.blueGrey,
                    ),
                    contentPadding: Spacings.zero.all,
                    title: Text('Vision', style: textTheme.large),
                    subtitle: Text(
                      _visionAvailable
                          ? 'Demonstrate image ingestion'
                          : _featureNotAvailable,
                      style: textTheme.p.copyWith(
                        color: _visionAvailable
                            ? theme.colorScheme.mutedForeground
                            : theme.colorScheme.destructive,
                      ),
                    ),
                    onTap: () => _imageIngestionDemo(context),
                  ),
                ],
              ),
      ),
    );
  }
}
