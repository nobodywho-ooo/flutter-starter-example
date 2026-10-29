import 'package:material_ui/material_ui.dart';
import 'package:flutter_starter_example/styles/styles.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_starter_example/service_locator.dart';
import 'package:flutter_starter_example/repositories/repositories.dart';
import 'package:flutter_starter_example/widgets/widgets.dart';

final _defaultCustomerMessage =
    "I was charged twice for my order last week and nobody has replied.";

final _routeCriteria = {
  "billing": "payments, charges, refunds, invoices",
  "shipping": "delivery, tracking, lost or late parcels",
  "technical": "bugs, errors, login problems",
};

final _urgencyCriteria = ["can wait", "this week", "today", "right now"];

typedef _DecisionResult = ({
  Map<String, double> route,
  double angry,
  double urgencyScore,
  Map<String, double> urgencyProbabilities,
});

class DecisionScreen extends StatefulWidget {
  const DecisionScreen({super.key});

  @override
  State<DecisionScreen> createState() => _DecisionScreenState();
}

class _DecisionScreenState extends State<DecisionScreen> {
  final aiRepository = getIt<AiRepository>();
  final _controller = TextEditingController(text: _defaultCustomerMessage);

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

      setState(() {
        _runningInit = false;
      });
    } catch (err) {
      debugPrint("Error loadDecisionModel $err");
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
        final response = await decision.decide(
          state: "Customer message: ${_controller.text}",
          questions: {
            "route": {
              "type": "choice",
              "instructions": "Choose the best team for this customer message.",
              "criteria": _routeCriteria,
            },
            "angry": {"type": "noul", "instructions": "Is the customer angry?"},
            "urgency": {
              "type": "score",
              "instructions": "How urgent is this?",
              "criteria": _urgencyCriteria,
            },
          },
        );

        final answers = (response as Map)["answers"] as Map;
        final route = answers["route"] as Map;
        final angry = answers["angry"] as Map;
        final urgency = answers["urgency"] as Map;
        final legend = urgency["legend"] as Map;

        setState(() {
          _result = (
            route: {
              for (final MapEntry(:key, :value)
                  in (route["probabilities"] as Map).entries)
                key as String: (value as num).toDouble(),
            },
            angry: (angry["noul"] as num).toDouble(),
            urgencyScore: (urgency["score"] as num).toDouble(),
            urgencyProbabilities: {
              for (final MapEntry(:key, :value)
                  in (urgency["probabilities"] as Map).entries)
                legend[key] as String: (value as num).toDouble(),
            },
          );
        });
      } else {
        debugPrint("Error _classify decision not available");
        setState(() {
          _errorDemo = true;
        });
      }
    } catch (err) {
      debugPrint("Error _classify $err");
      setState(() {
        _errorDemo = true;
      });
    } finally {
      setState(() {
        _runningClassify = false;
        _hasResults = true;
      });
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
            _buildSectionTitle("Customer message", textTheme),
            ShadTextarea(
              controller: _controller,
              enabled: !_runningClassify,
              placeholder: Text("Type a customer message..."),
            ),
            Padding(
              padding: Spacings.xl.top,
              child: _runningClassify
                  ? CircularProgressIndicator(color: Colors.blueGrey)
                  : ShadButton(
                      onPressed: _controller.text.trim().isEmpty
                          ? null
                          : _classify,
                      child: Text(_hasResults ? "Classify again" : "Classify"),
                    ),
            ),
            if (_errorDemo)
              Padding(padding: Spacings.xl.vertical, child: ErrorIndicator()),
            _buildSectionTitle(
              "Which team should receive the message?",
              textTheme,
            ),
            PillGroup(
              options: [
                for (final team in _routeCriteria.keys)
                  (label: team, probability: result?.route[team]),
              ],
            ),
            _buildSectionTitle("Is the customer angry?", textTheme),
            PillGroup(
              options: [
                (label: "yes", probability: result?.angry),
                (
                  label: "no",
                  probability: result == null ? null : 1 - result.angry,
                ),
              ],
            ),
            _buildSectionTitle("Urgency", textTheme),
            PillGroup(
              options: [
                for (final level in _urgencyCriteria)
                  (
                    label: level,
                    probability: result?.urgencyProbabilities[level],
                  ),
              ],
            ),
            if (result != null)
              Padding(
                padding: Spacings.sm.top,
                child: Text(
                  "Score: ${result.urgencyScore.toStringAsFixed(2)} "
                  "(0 = ${_urgencyCriteria.first}, "
                  "${_urgencyCriteria.length - 1} = ${_urgencyCriteria.last})",
                  style: textTheme.muted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
