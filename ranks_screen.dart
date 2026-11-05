import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../providers/progress_notifier.dart';
import '../../providers/providers.dart';
import '../widgets/common.dart';

class RanksScreen extends ConsumerWidget {
  const RanksScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final prog = ref.watch(progressProvider);
    final bn = ref.watch(isBanglaProvider);
    final s = S(bn);
    // Offline DEMO board: fixed sample names/scores, clearly labelled. Your own XP is real.
    final rows = <(String, int, bool)>[
      ('Demo: Nusrat', 1850, false), ('Demo: Rahim', 1320, false), ('Demo: Tania', 940, false),
      ('Demo: Imran', 610, false), ('Demo: Sumaiya', 300, false),
      (s.t('you'), prog.totalXP, true),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    final badges = <(String, String, bool)>[
      for (final c in content.chapters) ('Ch ${c.chapterNumber}', c.name(bn), prog.completedChapters.contains(c.chapterId)),
      for (final e in badgeTitles.entries) ('★', e.value, prog.earnedBadges.contains(e.key)),
    ];
    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(14), children: [
        Text(s.t('ranks'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        Text(s.t('demoBoard'), style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        const SizedBox(height: 10),
        for (var i = 0; i < rows.length; i++)
          Panel(
            color: rows[i].$3 ? AppColors.emerald : AppColors.navy2,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundColor: i == 0 ? AppColors.gold : Colors.white12, foregroundColor: i == 0 ? AppColors.navy : Colors.white, child: Text('${i + 1}')),
              title: Text(rows[i].$1, style: TextStyle(fontWeight: rows[i].$3 ? FontWeight.w800 : FontWeight.w500)),
              trailing: XpChip(rows[i].$2),
            ),
          ),
        const SizedBox(height: 18),
        const Text('Achievement badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final b in badges)
            Container(
              width: 104,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: b.$3 ? AppColors.navy2 : Colors.black26, borderRadius: BorderRadius.circular(14), border: Border.all(color: b.$3 ? AppColors.gold : Colors.white12)),
              child: Column(children: [
                Icon(b.$3 ? Icons.emoji_events : Icons.lock_outline, color: b.$3 ? AppColors.gold : AppColors.muted, size: 28),
                const SizedBox(height: 4),
                Text(b.$1, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                Text(b.$2, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
              ]),
            ),
        ]),
      ]),
    );
  }
}
