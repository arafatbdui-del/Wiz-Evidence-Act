import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../providers/progress_notifier.dart';
import 'common.dart';

class QuizItem {
  final String id, text;
  final List<String> options;
  final int answer;
  final String? explanation, ref;
  final bool englishFallback;
  const QuizItem({required this.id, required this.text, required this.options, required this.answer,
      this.explanation, this.ref, this.englishFallback = false});
}

/// Reusable one-question-at-a-time runner with instant feedback and a result screen.
/// Used by section quizzes, practice, daily challenge, boss battles and 5 of the mini-game types.
class QuizRunner extends StatefulWidget {
  final List<QuizItem> items;
  final Widget? header;
  final Future<Reward> Function(List<bool> results) onFinish;
  final List<Widget> Function(BuildContext, Reward, List<bool>) resultActions;
  final String? resultHeadline;
  const QuizRunner({super.key, required this.items, required this.onFinish, required this.resultActions, this.header, this.resultHeadline});
  @override
  State<QuizRunner> createState() => _QuizRunnerState();
}

class _QuizRunnerState extends State<QuizRunner> {
  int i = 0;
  int? picked;
  final results = <bool>[];
  Reward? reward;
  bool saving = false;

  Future<void> _next() async {
    final it = widget.items[i];
    results.add(picked == it.answer);
    if (i + 1 < widget.items.length) {
      setState(() { i++; picked = null; });
    } else {
      setState(() => saving = true);
      final r = await widget.onFinish(List.of(results));
      if (mounted) setState(() { reward = r; saving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const Center(child: Text('No questions available yet.'));
    if (reward != null) return _result(context, reward!);
    final it = widget.items[i];
    final answered = picked != null;
    return ListView(padding: const EdgeInsets.all(16), children: [
      if (widget.header != null && i == 0) ...[widget.header!, const SizedBox(height: 12)],
      Row(children: [
        Text('${i + 1} / ${widget.items.length}', style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
        const SizedBox(width: 12),
        Expanded(child: Bar(value: (i + (answered ? 1 : 0)) / widget.items.length)),
      ]),
      const SizedBox(height: 16),
      Panel(
        color: AppColors.ivory,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (it.englishFallback)
            const Padding(padding: EdgeInsets.only(bottom: 6), child: Text('EN (Bangla version not available yet)', style: TextStyle(color: AppColors.emerald, fontSize: 11, fontWeight: FontWeight.w700))),
          Text(it.text, style: const TextStyle(color: AppColors.navy, fontSize: 17, fontWeight: FontWeight.w700, height: 1.35)),
        ]),
      ),
      const SizedBox(height: 12),
      for (var k = 0; k < it.options.length; k++) _option(it, k, answered),
      if (answered) ...[
        const SizedBox(height: 8),
        Panel(
          border: picked == it.answer ? AppColors.success : AppColors.error,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(picked == it.answer ? 'Correct!' : 'Not quite', style: TextStyle(fontWeight: FontWeight.w800, color: picked == it.answer ? AppColors.success : AppColors.error)),
            if (it.explanation != null && it.explanation!.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(it.explanation!)),
            if (it.ref != null && it.ref!.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text('Relevant: ${it.ref}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700))),
          ]),
        ),
        const SizedBox(height: 12),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.navy, minimumSize: const Size.fromHeight(50)),
          onPressed: saving ? null : _next,
          child: Text(i + 1 < widget.items.length ? 'Next' : 'Finish', style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    ]);
  }

  Widget _option(QuizItem it, int k, bool answered) {
    Color bg = AppColors.navy2, bd = Colors.white24;
    IconData? ic;
    if (answered) {
      if (k == it.answer) { bg = AppColors.success.withOpacity(0.25); bd = AppColors.success; ic = Icons.check_circle; }
      else if (k == picked) { bg = AppColors.error.withOpacity(0.25); bd = AppColors.error; ic = Icons.cancel; }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: answered ? null : () => setState(() => picked = k),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: bd, width: 1.5)),
          child: Row(children: [
            CircleAvatar(radius: 13, backgroundColor: Colors.white12, child: Text(String.fromCharCode(65 + k), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
            const SizedBox(width: 12),
            Expanded(child: Text(it.options[k], style: const TextStyle(fontSize: 15))),
            if (ic != null) Icon(ic, color: bd),
          ]),
        ),
      ),
    );
  }

  Widget _result(BuildContext context, Reward r) {
    final pct = results.isEmpty ? 0 : (results.where((e) => e).length * 100 / results.length).round();
    return ListView(padding: const EdgeInsets.all(20), children: [
      const SizedBox(height: 12),
      Icon(r.passed ? Icons.emoji_events : Icons.refresh, size: 72, color: r.passed ? AppColors.gold : AppColors.muted),
      const SizedBox(height: 8),
      Center(child: Text(widget.resultHeadline ?? (r.passed ? 'Well done!' : 'Keep practising'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800))),
      const SizedBox(height: 8),
      Center(child: Text('Score: ${results.where((e) => e).length} / ${results.length}  ($pct%)', style: const TextStyle(fontSize: 18))),
      const SizedBox(height: 6),
      Center(child: XpChip(r.xp)),
      if (r.xp == 0) const Padding(padding: EdgeInsets.only(top: 6), child: Center(child: Text('No new XP: rewards are paid once per question/activity.', style: TextStyle(color: AppColors.muted, fontSize: 12)))),
      for (final m in r.messages) Padding(padding: const EdgeInsets.only(top: 8), child: Center(child: Text(m, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800)))),
      const SizedBox(height: 20),
      ...widget.resultActions(context, r, results),
    ]);
  }
}
