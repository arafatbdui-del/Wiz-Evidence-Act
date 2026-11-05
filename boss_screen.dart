import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../providers/providers.dart';
import '../widgets/common.dart';
import '../widgets/quiz_runner.dart';

class BossScreen extends ConsumerStatefulWidget {
  final String chapterId;
  const BossScreen({super.key, required this.chapterId});
  @override
  ConsumerState<BossScreen> createState() => _BossScreenState();
}

class _BossScreenState extends ConsumerState<BossScreen> {
  int run = 0;
  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    final bn = ref.watch(isBanglaProvider);
    final s = S(bn);
    final ch = content.chapter(widget.chapterId)!;
    final boss = content.bossFor(ch)!;
    final items = [
      for (final q in boss.questions)
        QuizItem(id: q.question, text: q.question, options: q.options, answer: q.answer, explanation: q.explanation, ref: q.sectionRef.isEmpty ? null : q.sectionRef)
    ];
    return Scaffold(
      appBar: AppBar(title: Text(boss.title)),
      body: SafeArea(
        child: QuizRunner(
          key: ValueKey(run),
          items: items,
          header: Panel(
            border: AppColors.gold,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [Icon(Icons.whatshot, color: AppColors.gold), SizedBox(width: 6), Text('SCENARIO', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800, letterSpacing: 1))]),
              const SizedBox(height: 8),
              Text(boss.scenario, style: const TextStyle(height: 1.45)),
              const SizedBox(height: 6),
              Text('Pass mark: ${boss.passPercent}%  ·  Reward: ${boss.xpReward} XP + ${ch.bonusXP} chapter XP', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ]),
          ),
          onFinish: (res) async => ref.read(progressProvider.notifier).recordBoss(ch.chapterId, res.where((e) => e).length, res.length),
          resultHeadline: null,
          resultActions: (c, r, res) => [
            if (r.passed) ...[
              const Center(child: Text('Chapter completed! 🏆', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.gold))),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.navy, minimumSize: const Size.fromHeight(52)),
                onPressed: () {
                  ref.read(tabProvider.notifier).state = 0;
                  Navigator.of(c).popUntil((r) => r.isFirst);
                },
                child: Text(s.t('claim'), style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ] else ...[
              const Center(child: Text('Not quite. Review the sections and try again.', style: TextStyle(color: AppColors.muted))),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.navy, minimumSize: const Size.fromHeight(50)),
                onPressed: () => setState(() => run++),
                child: const Text('Try again', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 10),
              OutlinedButton(onPressed: () => Navigator.pop(c), child: const Text('Back to chapter')),
            ],
          ],
        ),
      ),
    );
  }
}
