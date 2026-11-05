import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/rules.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../providers/providers.dart';
import '../widgets/common.dart';
import 'bookmarks_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final prog = ref.watch(progressProvider);
    final n = ref.read(progressProvider.notifier);
    final bn = ref.watch(isBanglaProvider);
    final s = S(bn);
    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(14), children: [
        Text(s.t('profile'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Panel(child: Column(children: [
          Row(children: [
            const CircleAvatar(radius: 30, backgroundColor: AppColors.gold, child: Icon(Icons.person, color: AppColors.navy, size: 36)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${s.t('level')} ${n.level}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              Text('${prog.totalXP} XP', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
            ])),
          ]),
          const SizedBox(height: 10),
          Bar(value: Rules.xpIntoLevel(prog.totalXP) / Rules.xpPerLevel),
          const SizedBox(height: 4),
          Text('${Rules.xpPerLevel - Rules.xpIntoLevel(prog.totalXP)} XP to next level', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        ])),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _stat(Icons.local_fire_department, '${prog.currentStreak}', s.t('streak'))),
          const SizedBox(width: 8),
          Expanded(child: _stat(Icons.verified, '${prog.completedChapters.length}/${content.chapters.length}', s.t('chapters'))),
          const SizedBox(width: 8),
          Expanded(child: _stat(Icons.emoji_events, '${prog.earnedBadges.length + prog.completedChapters.length}', 'Badges')),
        ]),
        const SizedBox(height: 14),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.t('language'), style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [ButtonSegment(value: 'en', label: Text('English')), ButtonSegment(value: 'bn', label: Text('বাংলা'))],
            selected: {prog.language},
            onSelectionChanged: (v) => n.setLanguage(v.first),
          ),
        ])),
        const SizedBox(height: 10),
        Panel(child: ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.bookmark, color: AppColors.gold), title: Text('${s.t('bookmarks')} (${prog.bookmarkedSections.length})'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksScreen())))),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), minimumSize: const Size.fromHeight(48)),
          icon: const Icon(Icons.restart_alt),
          label: Text(s.t('reset')),
          onPressed: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                title: Text(s.t('reset')),
                content: const Text('This erases all XP, streaks, badges, bookmarks and chapter progress on this device. This cannot be undone.'),
                actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Reset', style: TextStyle(color: AppColors.error)))],
              ),
            );
            if (ok == true) { n.resetAll(); if (context.mounted) toast(context, 'Progress reset'); }
          },
        ),
      ]),
    );
  }

  Widget _stat(IconData i, String v, String l) => Panel(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        child: Column(children: [Icon(i, color: AppColors.gold), const SizedBox(height: 4), Text(v, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), Text(l, style: const TextStyle(fontSize: 11, color: AppColors.muted), textAlign: TextAlign.center)]),
      );
}
