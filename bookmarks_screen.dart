import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../providers/providers.dart';
import 'section_screen.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final prog = ref.watch(progressProvider);
    final s = S(ref.watch(isBanglaProvider));
    final secs = content.sections.where((x) => prog.bookmarkedSections.contains(x.sectionId)).toList();
    return Scaffold(
      appBar: AppBar(title: Text(s.t('bookmarks'))),
      body: secs.isEmpty
          ? const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No bookmarks yet. Tap the bookmark icon on any section.', textAlign: TextAlign.center)))
          : ListView(padding: const EdgeInsets.all(12), children: [
              for (var i = 0; i < secs.length; i++)
                Card(
                  color: AppColors.navy2,
                  child: ListTile(
                    title: Text('${s.t('section')} ${secs[i].sectionNumber}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(secs[i].englishExplanation ?? secs[i].displayTitle, maxLines: 3, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(icon: const Icon(Icons.bookmark, color: AppColors.gold), onPressed: () => ref.read(progressProvider.notifier).toggleBookmark(secs[i].sectionId)),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SectionScreen(sectionIds: secs.map((e) => e.sectionId).toList(), index: i))),
                  ),
                ),
            ]),
    );
  }
}
