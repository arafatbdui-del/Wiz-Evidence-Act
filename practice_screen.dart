import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/rules.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../providers/providers.dart';
import '../widgets/common.dart';
import 'quiz_screen.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final prog = ref.watch(progressProvider);
    final n = ref.read(progressProvider.notifier);
    final bn = ref.watch(isBanglaProvider);
    final s = S(bn);
    final daily = n.dailyQuestions();
    final mistakes = content.questions.where((q) => prog.incorrectQuestions.contains(q.questionId)).toList();

    void open(String title, List qs, {bool dailyMode = false}) {
      if (qs.isEmpty) { toast(context, s.t('noQuestions')); return; }
      Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(title: title, questions: List.from(qs), daily: dailyMode)));
    }

    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(14), children: [
        Text(s.t('practice'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Panel(
          color: n.dailyDone ? AppColors.emerald : AppColors.navy2,
          border: AppColors.gold,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(n.dailyDone ? Icons.check_circle : Icons.local_fire_department, color: AppColors.gold, size: 36),
            title: Text(s.t('dailyChallenge'), style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(n.dailyDone ? 'Completed today. Come back tomorrow!' : '3 questions · +${Rules.dailyChallengeXp} XP bonus'),
            trailing: const Icon(Icons.chevron_right),
            onTap: n.dailyDone ? null : () => open(s.t('dailyChallenge'), daily, dailyMode: true),
          ),
        ),
        const SizedBox(height: 10),
        _tile(Icons.shuffle, s.t('randomQuiz'), '10 random questions', () {
          final all = [...content.questions]..shuffle(Random());
          open(s.t('randomQuiz'), all.take(10).toList());
        }),
        _tile(Icons.edit_note, s.t('mistakes'), '${mistakes.length} to review', () => open(s.t('mistakes'), mistakes)),
        const SizedBox(height: 12),
        const Text('Practice by chapter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        for (final c in content.chapters)
          Builder(builder: (_) {
            final qs = content.questionsForChapter(c.chapterId);
            return ListTile(
              leading: Icon(chapterIcon(c.icon), color: qs.isEmpty ? AppColors.muted : AppColors.gold),
              title: Text('${c.chapterNumber}. ${c.name(bn)}'),
              subtitle: Text(qs.isEmpty ? s.t('noQuestions') : '${qs.length} questions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => open(c.name(bn), qs),
            );
          }),
        const SizedBox(height: 12),
        const Text('Practice by section', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        for (final sec in content.sections.where((x) => content.questionsForSection(x.sectionId).isNotEmpty))
          ListTile(
            dense: true,
            leading: CircleAvatar(radius: 16, backgroundColor: AppColors.navy2, child: Text(sec.sectionNumber, style: const TextStyle(fontSize: 11))),
            title: Text('${s.t('section')} ${sec.sectionNumber}'),
            subtitle: Text('${content.questionsForSection(sec.sectionId).length} questions'),
            onTap: () => open('${s.t('section')} ${sec.sectionNumber}', content.questionsForSection(sec.sectionId)),
          ),
      ]),
    );
  }

  Widget _tile(IconData i, String t, String sub, VoidCallback f) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Panel(child: ListTile(contentPadding: EdgeInsets.zero, leading: Icon(i, color: AppColors.gold, size: 30), title: Text(t, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(sub), trailing: const Icon(Icons.chevron_right), onTap: f)),
      );
}
