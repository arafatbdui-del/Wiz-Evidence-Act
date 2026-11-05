import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/progress_notifier.dart';
import '../../providers/providers.dart';
import '../widgets/quiz_runner.dart';

/// MCQ practice for a list of questions (section quiz, chapter practice, random, mistakes, daily).
class QuizScreen extends ConsumerStatefulWidget {
  final String title;
  final List<Question> questions;
  final String? sectionId;
  final bool daily;
  const QuizScreen({super.key, required this.title, required this.questions, this.sectionId, this.daily = false});
  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late List<Question> qs = widget.questions;
  int run = 0;

  @override
  Widget build(BuildContext context) {
    final bn = ref.watch(isBanglaProvider);
    final items = [
      for (final q in qs)
        QuizItem(
          id: q.questionId, text: q.text(bn), options: q.options(bn), answer: q.correctAnswer,
          explanation: q.explanation(bn), englishFallback: bn && !q.hasBangla(bn),
          ref: 's.${ref.read(contentProvider).section(q.sectionId)?.sectionNumber ?? ''}',
        )
    ];
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: QuizRunner(
          key: ValueKey(run),
          items: items,
          onFinish: (res) async {
            final n = ref.read(progressProvider.notifier);
            final r = n.recordQuiz([for (var i = 0; i < qs.length; i++) AnswerResult(qs[i].questionId, res[i])], sectionId: widget.sectionId);
            if (widget.daily) {
              final d = n.completeDaily(r.correct, r.total);
              return Reward(xp: r.xp + d.xp, correct: r.correct, total: r.total, passed: r.passed, messages: d.xp > 0 ? ['Daily challenge bonus +${d.xp} XP'] : const []);
            }
            return r;
          },
          resultActions: (c, r, res) {
            final wrong = [for (var i = 0; i < qs.length; i++) if (!res[i]) qs[i]];
            return [
              if (wrong.isNotEmpty && !widget.daily)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    onPressed: () => setState(() { qs = wrong; run++; }),
                    child: Text('Retry incorrect (${wrong.length})'),
                  ),
                ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.navy, minimumSize: const Size.fromHeight(50)),
                onPressed: () => Navigator.pop(c),
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ];
          },
        ),
      ),
    );
  }
}
