import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/rules.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../games/game_catalog.dart';
import '../games/game_screen.dart';
import '../widgets/common.dart';
import 'quiz_screen.dart';

class SectionScreen extends ConsumerStatefulWidget {
  final List<String> sectionIds;
  final int index;
  const SectionScreen({super.key, required this.sectionIds, required this.index});
  @override
  ConsumerState<SectionScreen> createState() => _SectionScreenState();
}

class _SectionScreenState extends ConsumerState<SectionScreen> {
  late int idx = widget.index;
  final _scroll = ScrollController();

  void _go(int d) {
    setState(() => idx += d);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    final prog = ref.watch(progressProvider);
    final bn = ref.watch(isBanglaProvider);
    final s = S(bn);
    final sec = content.section(widget.sectionIds[idx])!;
    final read = prog.lessonsRead.contains(sec.sectionId);
    final qs = content.questionsForSection(sec.sectionId);
    final saved = prog.bookmarkedSections.contains(sec.sectionId);
    final ch = content.chapter(sec.primaryChapterId)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${s.t('section')} ${sec.sectionNumber}'),
        actions: [
          IconButton(
            tooltip: 'Bookmark',
            icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border, color: AppColors.gold),
            onPressed: () => ref.read(progressProvider.notifier).toggleBookmark(sec.sectionId),
          ),
        ],
      ),
      body: ListView(controller: _scroll, padding: const EdgeInsets.all(14), children: [
        Text(sec.displayTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('${ch.chapterNumber}. ${ch.name(bn)}  ·  ${sec.statutoryChapter}${sec.statutoryChapterTitle.isEmpty ? '' : ' (${sec.statutoryChapterTitle})'}',
            style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        const SizedBox(height: 12),
        // ORIGINAL LAW (visually separate from every study aid)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.ivory,
            borderRadius: BorderRadius.circular(14),
            border: const Border(left: BorderSide(color: AppColors.gold, width: 6)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.gavel, size: 16, color: AppColors.navy),
              const SizedBox(width: 6),
              Text(s.t('originalLaw'), style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1)),
            ]),
            const SizedBox(height: 8),
            SelectableText(sec.originalText, style: const TextStyle(color: AppColors.navy, fontSize: 15, height: 1.5)),
            const SizedBox(height: 8),
            Text(sec.sourceReference, style: const TextStyle(color: AppColors.emerald, fontSize: 10.5)),
          ]),
        ),
        const SizedBox(height: 14),
        _aid(s.t('bnTranslation'), sec.banglaTranslation, s),
        _aid(s.t('enExplain'), sec.englishExplanation, s),
        _aid(s.t('bnExplain'), sec.banglaExplanation, s),
        _aid(s.t('example'), sec.practicalExample, s),
        Text(s.t('notOfficial'), style: const TextStyle(color: AppColors.muted, fontSize: 11)),
        if (sec.reviewFlags.isNotEmpty) ...[
          const SizedBox(height: 8),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Content review notes', style: TextStyle(fontSize: 12, color: AppColors.gold)),
            children: [for (final f in sec.reviewFlags) Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('• $f', style: const TextStyle(fontSize: 11, color: AppColors.muted)))],
          ),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: read ? AppColors.success : AppColors.gold, foregroundColor: read ? Colors.white : AppColors.navy, minimumSize: const Size.fromHeight(50)),
          icon: Icon(read ? Icons.check : Icons.menu_book),
          label: Text(read ? 'Lesson read' : '${s.t('markRead')} (+${Rules.lessonXp} XP)', style: const TextStyle(fontWeight: FontWeight.w800)),
          onPressed: read
              ? null
              : () {
                  final r = ref.read(progressProvider.notifier).markLessonRead(sec.sectionId);
                  toast(context, '+${r.xp} XP');
                },
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          icon: const Icon(Icons.quiz),
          label: Text(qs.isEmpty ? '${s.t('takeQuiz')}: ${s.t('noQuestions')}' : '${s.t('takeQuiz')} (${qs.length})'),
          onPressed: qs.isEmpty
              ? null
              : () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(title: '${s.t('section')} ${sec.sectionNumber}', questions: qs, sectionId: sec.sectionId))),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          icon: const Icon(Icons.sports_esports),
          label: Text(s.t('playGame')),
          onPressed: () {
            final games = gamesFor(content, ch);
            if (games.isEmpty) { toast(context, 'No games for this chapter yet.'); return; }
            showModalBottomSheet(
              context: context,
              backgroundColor: AppColors.navy2,
              builder: (_) => SafeArea(child: ListView(shrinkWrap: true, children: [
                for (final g in games)
                  ListTile(
                    leading: const Icon(Icons.sports_esports, color: AppColors.gold),
                    title: Text(g.title),
                    subtitle: Text(gameTypeLabel(g.gameType)),
                    onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen(game: g))); },
                  ),
              ])),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: idx > 0 ? () => _go(-1) : null, child: Text('← ${s.t('prev')}'))),
          const SizedBox(width: 10),
          Expanded(child: OutlinedButton(onPressed: idx < widget.sectionIds.length - 1 ? () => _go(1) : null, child: Text('${s.t('next')} →'))),
        ]),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _aid(String label, String? text, S s) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Panel(
          color: AppColors.navy2,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800, fontSize: 12)),
            const SizedBox(height: 6),
            Text(text ?? s.t('notAvail'), style: TextStyle(height: 1.45, color: text == null ? AppColors.muted : Colors.white, fontStyle: text == null ? FontStyle.italic : FontStyle.normal)),
          ]),
        ),
      );
}
