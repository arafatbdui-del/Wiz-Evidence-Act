import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/progress_notifier.dart';
import '../../providers/providers.dart';
import '../widgets/common.dart';
import '../widgets/quiz_runner.dart';
import 'game_catalog.dart';

class GameScreen extends ConsumerStatefulWidget {
  final GameDef game;
  const GameScreen({super.key, required this.game});
  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  Reward? custom;
  int customCorrect = 0, customTotal = 0;
  int run = 0;

  List<Widget> _actions(BuildContext c, Reward r, List<bool> res) => [
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.navy, minimumSize: const Size.fromHeight(50)),
          onPressed: () => Navigator.pop(c),
          child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          onPressed: () => setState(() { custom = null; run++; }),
          child: const Text('Play again'),
        ),
      ];

  Future<Reward> _finish(List<bool> res) async =>
      ref.read(progressProvider.notifier).recordGame(widget.game, res.where((e) => e).length, res.length);

  @override
  Widget build(BuildContext context) {
    final g = widget.game;
    final content = ref.watch(contentProvider);
    final items = <QuizItem>[];
    final c = g.content;
    switch (g.gameType) {
      case 'true_false':
        for (final e in (c['items'] as List)) {
          final m = Map<String, dynamic>.from(e as Map);
          items.add(QuizItem(id: m['statement'], text: m['statement'], options: const ['True', 'False'], answer: (m['answer'] as bool) ? 0 : 1, explanation: m['explanation']));
        }
        break;
      case 'fill_blank':
        for (final e in (c['items'] as List)) {
          final m = Map<String, dynamic>.from(e as Map);
          items.add(QuizItem(id: m['prompt'], text: m['prompt'], options: List<String>.from(m['options']), answer: m['answer'], ref: m['ref']));
        }
        break;
      case 'identify_section':
        for (final e in (c['items'] as List)) {
          final m = Map<String, dynamic>.from(e as Map);
          items.add(QuizItem(id: m['scenario'], text: m['scenario'], options: List<String>.from(m['options']), answer: m['answer'], explanation: m['explanation']));
        }
        break;
      case 'case':
        for (final e in (c['items'] as List)) {
          final m = Map<String, dynamic>.from(e as Map);
          items.add(QuizItem(id: m['scenario'], text: '${m['scenario']}\n\n${m['question']}', options: List<String>.from(m['options']), answer: m['answer'], explanation: m['explanation']));
        }
        break;
      case 'quick_mcq':
        final ids = List<String>.from(c['questionIds']);
        for (final q in content.questions.where((q) => ids.contains(q.questionId))) {
          items.add(QuizItem(id: q.questionId, text: q.questionTextEnglish, options: q.optionsEnglish, answer: q.correctAnswer, explanation: q.explanationEnglish));
        }
        break;
    }
    Widget body;
    if (g.gameType == 'match') {
      body = custom != null ? _customResult(custom!) : _Match(key: ValueKey(run), pairs: (c['pairs'] as List).map((e) => Map<String, String>.from(e as Map)).toList(), onDone: _customDone);
    } else if (g.gameType == 'flashcard') {
      body = custom != null ? _customResult(custom!) : _Flash(key: ValueKey(run), items: (c['items'] as List).map((e) => Map<String, String>.from(e as Map)).toList(), onDone: _customDone);
    } else {
      body = QuizRunner(key: ValueKey(run), items: items, onFinish: _finish, resultActions: _actions,
          header: Text(g.instructions, style: const TextStyle(color: AppColors.muted)));
    }
    return Scaffold(appBar: AppBar(title: Text(g.title)), body: SafeArea(child: body));
  }

  Future<void> _customDone(int correct, int total) async {
    final r = ref.read(progressProvider.notifier).recordGame(widget.game, correct, total);
    setState(() { custom = r; customCorrect = correct; customTotal = total; });
  }

  Widget _customResult(Reward r) => ListView(padding: const EdgeInsets.all(20), children: [
        const SizedBox(height: 12),
        Icon(r.passed ? Icons.emoji_events : Icons.refresh, size: 72, color: r.passed ? AppColors.gold : AppColors.muted),
        const SizedBox(height: 8),
        Center(child: Text(r.passed ? 'Well done!' : 'Keep practising', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800))),
        const SizedBox(height: 8),
        Center(child: Text('Score: $customCorrect / $customTotal', style: const TextStyle(fontSize: 18))),
        const SizedBox(height: 6),
        Center(child: XpChip(r.xp)),
        const SizedBox(height: 20),
        ..._actions(context, r, const []),
      ]);
}

class _Match extends StatefulWidget {
  final List<Map<String, String>> pairs;
  final Future<void> Function(int, int) onDone;
  const _Match({super.key, required this.pairs, required this.onDone});
  @override
  State<_Match> createState() => _MatchState();
}

class _MatchState extends State<_Match> {
  late final List<int> rightOrder;
  int? left;
  final done = <int>{};
  int mistakes = 0;
  int? flashRight;

  @override
  void initState() {
    super.initState();
    final n = widget.pairs.length;
    rightOrder = [for (var i = 0; i < n; i++) (i + 1) % n]; // fixed rotation = deterministic shuffle
  }

  void _tapRight(int r) {
    if (left == null || done.contains(r)) return;
    if (r == left) {
      setState(() { done.add(r); left = null; });
      if (done.length == widget.pairs.length) {
        widget.onDone((widget.pairs.length - mistakes).clamp(0, widget.pairs.length), widget.pairs.length);
      }
    } else {
      setState(() { mistakes++; flashRight = r; });
      Future.delayed(const Duration(milliseconds: 400), () { if (mounted) setState(() => flashRight = null); });
    }
  }

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Tap a provision, then tap its matching effect.', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 12),
        Text('Mistakes: $mistakes', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        for (var i = 0; i < widget.pairs.length; i++) ...[
          Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: _tile(widget.pairs[i]['left']!, done.contains(i), left == i, () => setState(() { if (!done.contains(i)) left = i; }))),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: _tile(widget.pairs[rightOrder[i]]['right']!, done.contains(rightOrder[i]), flashRight == rightOrder[i], () => _tapRight(rightOrder[i]), bad: flashRight == rightOrder[i])),
          ]),
          const SizedBox(height: 10),
        ],
      ]);

  Widget _tile(String t, bool ok, bool sel, VoidCallback tap, {bool bad = false}) => InkWell(
        onTap: tap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ok ? AppColors.success.withOpacity(0.25) : (bad ? AppColors.error.withOpacity(0.3) : AppColors.navy2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ok ? AppColors.success : (sel ? AppColors.gold : Colors.white24), width: 1.5),
          ),
          child: Text(t, style: const TextStyle(fontSize: 14)),
        ),
      );
}

class _Flash extends StatefulWidget {
  final List<Map<String, String>> items;
  final Future<void> Function(int, int) onDone;
  const _Flash({super.key, required this.items, required this.onDone});
  @override
  State<_Flash> createState() => _FlashState();
}

class _FlashState extends State<_Flash> {
  int i = 0, known = 0;
  bool flipped = false;
  void _next(bool k) {
    if (k) known++;
    if (i + 1 >= widget.items.length) {
      widget.onDone(known, widget.items.length);
    } else {
      setState(() { i++; flipped = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final it = widget.items[i];
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('${i + 1} / ${widget.items.length}', style: const TextStyle(color: AppColors.muted)),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: () => setState(() => flipped = !flipped),
        child: Panel(
          color: flipped ? AppColors.ivory : AppColors.emerald,
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 200),
            child: Center(child: Text(flipped ? it['back']! : it['front']!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: flipped ? 15 : 28, fontWeight: flipped ? FontWeight.w500 : FontWeight.w800, height: 1.4, color: flipped ? AppColors.navy : Colors.white))),
          ),
        ),
      ),
      const SizedBox(height: 8),
      const Center(child: Text('Tap the card to flip', style: TextStyle(color: AppColors.muted, fontSize: 12))),
      const SizedBox(height: 16),
      if (flipped) Row(children: [
        Expanded(child: OutlinedButton(onPressed: () => _next(false), child: const Text('Review again'))),
        const SizedBox(width: 12),
        Expanded(child: FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.success), onPressed: () => _next(true), child: const Text('I knew it'))),
      ]),
    ]);
  }
}
