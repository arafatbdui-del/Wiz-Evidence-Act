import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../widgets/common.dart';
import 'chapter_overview_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final prog = ref.watch(progressProvider);
    final n = ref.read(progressProvider.notifier);
    final bn = ref.watch(isBanglaProvider);
    final s = S(bn);
    final current = n.currentChapter;
    final pct = (n.courseFraction * 100).round();

    return Column(children: [
      Expanded(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1B3550), AppColors.navy]),
          ),
          child: SafeArea(
            bottom: false,
            child: ListView(padding: const EdgeInsets.fromLTRB(14, 8, 14, 12), children: [
              _Header(bn: bn, s: s, notifications: prog.notifications),
              const SizedBox(height: 18),
              Text(s.t('journey'), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(s.t('journeySub'), style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 15)),
              Container(margin: const EdgeInsets.only(top: 6, bottom: 14), height: 3, width: 90, decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(2))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: AppColors.navy.withOpacity(0.85), borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.muted.withOpacity(0.4))),
                child: Row(children: [
                  ProgressRing(value: n.courseFraction, label: '$pct%'),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.t('courseCompletion'), style: const TextStyle(fontSize: 15)),
                    const SizedBox(height: 4),
                    Text.rich(TextSpan(children: [
                      TextSpan(text: '${prog.completedChapters.length}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800, fontSize: 18)),
                      TextSpan(text: ' / ${content.chapters.length} ${s.t('chapters')}', style: const TextStyle(fontSize: 16)),
                    ])),
                  ])),
                  Container(width: 1, height: 52, color: Colors.white24),
                  const SizedBox(width: 12),
                  const Icon(Icons.star_rounded, color: AppColors.gold, size: 44),
                  const SizedBox(width: 8),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.t('totalXp'), style: const TextStyle(fontSize: 13)),
                    Text('${prog.totalXP}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  ]),
                ]),
              ),
              const SizedBox(height: 12),
              for (final c in content.chapters) _ChapterCard(chapter: c, isCurrent: current?.chapterId == c.chapterId),
            ]),
          ),
        ),
      ),
      Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gold, width: 1.2)),
        child: Row(children: [
          const Icon(Icons.emoji_events, color: AppColors.gold, size: 40),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.t('banner'), style: const TextStyle(fontSize: 13)),
            Text(s.t('badge'), style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800, fontSize: 14)),
          ])),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.navy, padding: const EdgeInsets.symmetric(horizontal: 14)),
            onPressed: current == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChapterOverviewScreen(chapterId: current.chapterId))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [Text(s.t('start'), style: const TextStyle(fontWeight: FontWeight.w800)), const Icon(Icons.chevron_right)]),
          ),
        ]),
      ),
    ]);
  }
}

class _Header extends ConsumerWidget {
  final bool bn;
  final S s;
  final List<String> notifications;
  const _Header({required this.bn, required this.s, required this.notifications});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(progressProvider.notifier);
    return Row(children: [
      const Icon(Icons.balance, color: AppColors.gold, size: 46),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Evidence Act BD', style: TextStyle(color: AppColors.gold, fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'serif')),
        Text(s.t('tagline'), maxLines: 2, style: const TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic)),
      ])),
      Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
        child: Row(children: [
          _lang('বাংলা', bn, () => n.setLanguage('bn')),
          _lang('English', !bn, () => n.setLanguage('en')),
        ]),
      ),
      const SizedBox(width: 6),
      Stack(clipBehavior: Clip.none, children: [
        IconButton(
          icon: const Icon(Icons.notifications_none, size: 28),
          onPressed: () => showModalBottomSheet(
            context: context,
            backgroundColor: AppColors.navy2,
            builder: (_) => SafeArea(
              child: ListView(padding: const EdgeInsets.all(16), children: [
                Text(s.t('notifications'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                if (notifications.isEmpty) const Text('Nothing yet. Finish a lesson or quiz to earn achievements.'),
                for (final m in notifications) ListTile(dense: true, leading: const Icon(Icons.emoji_events, color: AppColors.gold), title: Text(m)),
              ]),
            ),
          ),
        ),
        if (notifications.isNotEmpty)
          Positioned(right: 4, top: 4, child: CircleAvatar(radius: 9, backgroundColor: AppColors.error, child: Text('${notifications.length > 9 ? 9 : notifications.length}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)))),
      ]),
    ]);
  }

  Widget _lang(String t, bool on, VoidCallback f) => GestureDetector(
        onTap: f,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: on ? AppColors.gold : Colors.transparent, borderRadius: BorderRadius.circular(16)),
          child: Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: on ? AppColors.navy : Colors.white)),
        ),
      );
}

class _ChapterCard extends ConsumerWidget {
  final GamingChapter chapter;
  final bool isCurrent;
  const _ChapterCard({required this.chapter, required this.isCurrent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(progressProvider);
    final n = ref.read(progressProvider.notifier);
    final content = ref.watch(contentProvider);
    final bn = ref.watch(isBanglaProvider);
    final s = S(bn);
    final unlocked = n.isUnlocked(chapter);
    final done = n.isChapterCompleted(chapter.chapterId);
    final pr = n.chapterProgress(chapter);
    final nums = content.sectionsOf(chapter).map((e) => e.sectionNumber).toList();

    Color bg, fg;
    if (!unlocked) { bg = const Color(0xFFD5D8DD); fg = const Color(0xFF5E6B78); }
    else if (isCurrent) { bg = AppColors.emerald; fg = Colors.white; }
    else { bg = AppColors.ivory; fg = AppColors.navy; }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (!unlocked) {
            toast(context, '${s.t('unlocksAfter')} ${chapter.chapterNumber - 1}');
            return;
          }
          Navigator.push(context, MaterialPageRoute(builder: (_) => ChapterOverviewScreen(chapterId: chapter.chapterId)));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: isCurrent ? Border.all(color: AppColors.success, width: 2) : null,
            boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 8, offset: Offset(0, 3))],
          ),
          child: Row(children: [
            CircleAvatar(radius: 14, backgroundColor: !unlocked ? const Color(0xFF6D7A88) : (isCurrent ? AppColors.success : AppColors.navy),
                child: Text('${chapter.chapterNumber}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800))),
            const SizedBox(width: 10),
            Icon(chapterIcon(chapter.icon), size: 34, color: isCurrent ? Colors.white : (unlocked ? AppColors.navy2 : const Color(0xFF7C8793))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${chapter.chapterNumber}. ${chapter.name(bn)}', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg, fontSize: 15.5, fontWeight: FontWeight.w800)),
              Text('${s.t('sections')}: ${sectionRangeLabel(nums)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg.withOpacity(0.9), fontSize: 12)),
              const SizedBox(height: 4),
              if (!unlocked)
                Row(children: [Icon(Icons.lock, size: 12, color: fg), const SizedBox(width: 4), Text('${s.t('unlocksAfter')} ${chapter.chapterNumber - 1}', style: TextStyle(color: fg, fontSize: 11))])
              else
                Row(children: [
                  Expanded(child: Bar(value: pr.total == 0 ? 0 : pr.done / pr.total, color: isCurrent ? Colors.white : AppColors.gold, track: isCurrent ? Colors.white24 : const Color(0x22000000), height: 6)),
                  const SizedBox(width: 8),
                  Text('${pr.done} / ${pr.total}', style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700)),
                ]),
            ])),
            const SizedBox(width: 6),
            Column(mainAxisSize: MainAxisSize.min, children: [
              if (done) const Icon(Icons.verified, color: AppColors.gold, size: 22) else Icon(!unlocked ? Icons.lock : Icons.emoji_events, size: 22, color: !unlocked ? const Color(0xFF7C8793) : AppColors.gold),
              Text('${chapter.bonusXP} XP', style: TextStyle(color: !unlocked ? const Color(0xFF7C8793) : (isCurrent ? Colors.white : AppColors.navy), fontWeight: FontWeight.w800, fontSize: 13)),
            ]),
            Icon(Icons.chevron_right, color: fg),
          ]),
        ),
      ),
    );
  }
}
