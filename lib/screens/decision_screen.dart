import 'package:material_ui/material_ui.dart';
import 'package:flutter_starter_example/styles/styles.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_starter_example/service_locator.dart';
import 'package:flutter_starter_example/repositories/repositories.dart';
import 'package:flutter_starter_example/widgets/widgets.dart';

final _defaultDiaryEntry =
    "What a lovely Saturday! Went for a long bike ride along the river with "
    "Sam, then we had a picnic in the park and the sun came out just in time. "
    "Finished the evening baking a lemon cake with mum.";

final _topicCriteria = {
  "work": "job, colleagues, deadlines, career",
  "relationships": "family, friends, partner",
  "health": "sleep, exercise, food, illness",
  "leisure": "hobbies, travel, going out",
};

final _moodCriteria = ["bad", "okay", "great"];

typedef _DecisionResult = ({
  Map<String, double> topics,
  double stressed,
  double moodScore,
  Duration duration,
});

class DecisionScreen extends StatefulWidget {
  const DecisionScreen({super.key});

  @override
  State<DecisionScreen> createState() => _DecisionScreenState();
}

class _DecisionScreenState extends State<DecisionScreen> {
  final aiRepository = getIt<AiRepository>();
  final _controller = TextEditingController(text: _defaultDiaryEntry);

  bool _errorInit = false;
  bool _errorDemo = false;
  bool _runningClassify = false;
  bool _runningInit = false;
  bool _hasResults = false;
  _DecisionResult? _result;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() {
      _errorInit = false;
      _runningInit = true;
    });

    try {
      await aiRepository.loadDecisionModel();

      // The screen may have been left while the model was loading
      if (!mounted) return;
      setState(() {
        _runningInit = false;
      });
    } catch (err) {
      debugPrint("Error loadDecisionModel $err");
      if (!mounted) return;
      setState(() {
        _errorInit = true;
        _runningInit = false;
      });
    }
  }

  Future<void> _classify() async {
    setState(() {
      _errorDemo = false;
      _runningClassify = true;
      _result = null;
    });
    try {
      final decision = aiRepository.decision;

      if (decision case final decision?) {
        final stopwatch = Stopwatch()..start();
        final result = await decision.decide(
          state: "Diary entry: ${_controller.text}",
          questions: {
            "topics": {
              "type": "choice",
              "instructions": "Choose the main topic of this diary entry",
              "criteria": _topicCriteria,
            },
            "stressed": {
              "type": "noul",
              "instructions": "Does the writer sound stressed?",
            },
            "mood": {
              "type": "score",
              "instructions": "How is the writer's overall mood?",
              "criteria": _moodCriteria,
            },
          },
        );
        stopwatch.stop();

        if (!mounted) {
          return;
        }

        final answers = (result as Map)["answers"] as Map;

        final topics = answers["topics"] as Map;
        final stressed = answers["stressed"] as Map;
        final mood = answers["mood"] as Map;

        setState(() {
          _result = (
            topics: {
              for (final MapEntry(:key, :value)
                  in (topics["probabilities"] as Map).entries)
                key as String: (value as num).toDouble(),
            },
            stressed: (stressed["noul"] as num).toDouble(),
            moodScore: (mood["score"] as num).toDouble(),
            duration: stopwatch.elapsed,
          );
          _hasResults = true;
        });
      } else {
        debugPrint("Error _classify decision not available");
        setState(() {
          _errorDemo = true;
        });
      }
    } catch (err) {
      debugPrint("Error _classify $err");
      if (!mounted) return;
      setState(() {
        _errorDemo = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _runningClassify = false;
        });
      }
    }
  }

  Widget _buildSectionTitle(String title, ShadTextTheme textTheme) {
    return Padding(
      padding: Spacings.xl.top + Spacings.sm.bottom,
      child: Text(title, style: textTheme.h4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final textTheme = theme.textTheme;
    final result = _result;

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
        padding: Spacings.lg.horizontal + Spacings.xl.bottom,
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Padding(
              padding: Spacings.lg.top,
              child: Text(
                "This example simulates a diary app. We use the decision model "
                "to pick the main topic of a user’s entry, detect stress and rate the mood.",
                style: textTheme.muted,
              ),
            ),
            _buildSectionTitle("Diary entry", textTheme),
            ShadTextarea(
              controller: _controller,
              enabled: !_runningClassify,
              placeholder: Text("Write an entry..."),
            ),
            Padding(
              padding: Spacings.xl.top,
              child: _runningClassify
                  ? CircularProgressIndicator(color: Colors.blueGrey)
                  : ShadButton(
                      onPressed: _controller.text.trim().isEmpty
                          ? null
                          : _classify,
                      child: Text(
                        _hasResults ? "Get insights again" : "Get insights",
                      ),
                    ),
            ),
            if (_errorDemo)
              Padding(padding: Spacings.xl.vertical, child: ErrorIndicator()),
            _buildSectionTitle("What is the entry about?", textTheme),
            PillGroup(
              options: [
                for (final topic in _topicCriteria.keys)
                  (label: topic, probability: result?.topics[topic]),
              ],
            ),
            _buildSectionTitle("Is the user stressed?", textTheme),
            PillGroup(
              options: [
                (label: "yes", probability: result?.stressed),
                (
                  label: "no",
                  probability: result == null ? null : 1 - result.stressed,
                ),
              ],
            ),
            _buildSectionTitle("Mood", textTheme),
            ScoreAxis(levels: _moodCriteria, score: result?.moodScore),
            if (result != null)
              Padding(
                padding: Spacings.xl.top,
                child: Text(
                  "Decided in ${(result.duration.inMilliseconds / 1000).toStringAsFixed(2)} s",
                  style: textTheme.muted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
