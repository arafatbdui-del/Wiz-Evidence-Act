import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../games/game_catalog.dart';
import '../games/game_screen.dart';
import '../widgets/common.dart';
import 'boss_screen.dart';
import 'section_screen.dart';

class ChapterOverviewScreen extends ConsumerWidget {
  final String chapterId;
  const ChapterOverviewScreen({super.key, required this.chapterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final prog = ref.watch(progressProvider);
    final n = ref.read(progressProvider.notifier);
    final bn = ref.watch(isBanglaProvider);
    final s = S(bn);
    final ch = content.chapter(chapterId)!;
    final secs = content.sectionsOf(ch);
    final pr = n.chapterProgress(ch);
    final boss = content.bossFor(ch);
    final games = gamesFor(content, ch);
    final firstTodo = secs.where((e) => !n.isSectionDone(e.sectionId)).map((e) => e.sectionId).firstOrNull;
    final related = content.relatedSectionsOf(ch);
    final totalXp = ch.bonusXP + (boss?.xpReward ?? 0) + secs.length * 10 + content.questionsForChapter(ch.chapterId).fold<int>(0, (a, q) => a + q.xpReward);

    return Scaffold(
      appBar: AppBar(title: Text('${ch.chapterNumber}. ${ch.name(bn)}')),
      body: ListView(padding: const EdgeInsets.all(14), children: [
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(chapterIcon(ch.icon), color: AppColors.gold, size: 36),
            const SizedBox(width: 10),
            Expanded(child: Text(ch.name(bn), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
          ]),
          const SizedBox(height: 8),
          Text(ch.description, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 12),
          Row(children: [
            Text('${secs.length} ${s.t('sections')}'),
            const Spacer(),
            Text('up to $totalXp XP', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Bar(value: pr.total == 0 ? 0 : pr.done / pr.total)),
            const SizedBox(width: 8),
            Text('${pr.done} / ${pr.total}'),
          ]),
          const SizedBox(height: 8),
          const Text('To complete: finish each section (read the lesson and pass its MCQs where available), then win the boss battle.', style: TextStyle(fontSize: 12, color: AppColors.muted)),
        ])),
        const SizedBox(height: 14),
        // Duolingo-style vertical path
        for (var i = 0; i < secs.length; i++)
          _Node(
            sec: secs[i],
            done: prog.completedSections.contains(secs[i].sectionId),
            isNext: secs[i].sectionId == firstTodo,
            hasQuiz: content.questionsForSection(secs[i].sectionId).isNotEmpty,
            last: false,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SectionScreen(sectionIds: secs.map((e) => e.sectionId).toList(), index: i))),
          ),
        _BossNode(chapter: ch, hasBoss: boss != null),
        if (games.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Mini-games', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          for (final g in games)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Panel(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(prog.gamesDone.contains(g.gameId) ? Icons.check_circle : Icons.sports_esports, color: prog.gamesDone.contains(g.gameId) ? AppColors.success : AppColors.gold),
                  title: Text(g.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(gameTypeLabel(g.gameType)),
                  trailing: XpChip(g.xpReward),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen(game: g))),
                ),
              ),
            ),
        ],
        if (related.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Also relevant (cross-referenced)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('These sections are taught in another chapter but matter here too.', style: TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 8),
          for (final r in related)
            ListTile(
              dense: true,
              leading: const Icon(Icons.link, color: AppColors.gold),
              title: Text('${s.t('section')} ${r.sectionNumber}'),
              subtitle: Text(r.displayTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SectionScreen(sectionIds: [r.sectionId], index: 0))),
            ),
        ],
      ]),
    );
  }
}

class _Node extends StatelessWidget {
  final LegalSection sec;
  final bool done, isNext, hasQuiz, last;
  final VoidCallback onTap;
  const _Node({required this.sec, required this.done, required this.isNext, required this.hasQuiz, required this.last, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.success : (isNext ? AppColors.gold : AppColors.navy2);
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(width: 44, child: Column(children: [
          Container(width: 3, height: 8, color: Colors.white24),
          CircleAvatar(radius: 17, backgroundColor: color, child: Icon(done ? Icons.check : (isNext ? Icons.play_arrow : Icons.circle_outlined), size: 18, color: isNext ? AppColors.navy : Colors.white)),
          Expanded(child: Container(width: 3, color: Colors.white24)),
        ])),
        Expanded(child: Padding(
          padding: const EdgeInsets.only(bottom: 6, top: 6),
          child: Panel(
            color: isNext ? AppColors.ivory : AppColors.navy2,
            border: isNext ? AppColors.gold : null,
            padding: EdgeInsets.zero,
            child: ListTile(
              onTap: onTap,
              title: Text('Section ${sec.sectionNumber}', style: TextStyle(fontWeight: FontWeight.w800, color: isNext ? AppColors.navy : Colors.white)),
              subtitle: Text(sec.displayTitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: isNext ? AppColors.navy2 : AppColors.muted, fontSize: 12)),
              trailing: Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                XpChip(10 + (hasQuiz ? 5 : 0), color: isNext ? AppColors.emerald : AppColors.gold),
                if (hasQuiz) Text('MCQ', style: TextStyle(fontSize: 10, color: isNext ? AppColors.navy : AppColors.muted)),
              ]),
            ),
          ),
        )),
      ]),
    );
  }
}

class _BossNode extends ConsumerWidget {
  final GamingChapter chapter;
  final bool hasBoss;
  const _BossNode({required this.chapter, required this.hasBoss});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(progressProvider);
    final n = ref.read(progressProvider.notifier);
    final passed = ref.read(progressProvider).bossesPassed.contains(chapter.chapterId);
    final ready = n.allSectionsDone(chapter) && hasBoss;
    return Panel(
      border: ready ? AppColors.gold : null,
      color: passed ? AppColors.emerald : AppColors.navy2,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(passed ? Icons.verified : (ready ? Icons.whatshot : Icons.lock), color: ready || passed ? AppColors.gold : AppColors.muted, size: 34),
        title: Text(S(false).t('boss'), style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(!hasBoss
            ? 'No boss battle content yet for this chapter: it completes when all sections are done.'
            : (passed ? 'Defeated. Replay any time (no extra XP).' : (ready ? 'Ready! Case-based challenge.' : 'Locked: complete all sections first.'))),
        onTap: (ready || passed) && hasBoss ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => BossScreen(chapterId: chapter.chapterId))) : null,
      ),
    );
  }
}
