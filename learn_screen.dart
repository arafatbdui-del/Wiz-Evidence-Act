import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import 'section_screen.dart';

class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});
  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  String query = '';
  String? chapterFilter;

  List<LegalSection> _results() {
    final c = ref.read(contentProvider);
    final q = query.trim().toLowerCase();
    return c.sections.where((s) {
      if (chapterFilter != null && s.primaryChapterId != chapterFilter && !s.relatedChapterIds.contains(chapterFilter)) return false;
      if (q.isEmpty) return true;
      final num = s.sectionNumber.toLowerCase();
      final qn = q.replaceAll(RegExp(r'^(s\.?|sec\.?|section)\s*'), '');
      if (num == qn || (qn.isNotEmpty && RegExp(r'^\d').hasMatch(qn) && num.startsWith(qn))) return true;
      return s.originalText.toLowerCase().contains(q) ||
          (s.sectionTitle ?? '').toLowerCase().contains(q) ||
          (s.englishExplanation ?? '').toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    final prog = ref.watch(progressProvider);
    final bn = ref.watch(isBanglaProvider);
    final s = S(bn);
    final res = _results();
    return SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
          child: TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: s.t('search'),
              filled: true,
              fillColor: AppColors.navy2,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 10), children: [
            _chip(s.t('allChapters'), chapterFilter == null, () => setState(() => chapterFilter = null)),
            for (final c in content.chapters) _chip('${c.chapterNumber}. ${c.name(bn)}', chapterFilter == c.chapterId, () => setState(() => chapterFilter = c.chapterId)),
          ]),
        ),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Align(alignment: Alignment.centerLeft, child: Text('${res.length} ${s.t('sections')}', style: const TextStyle(color: AppColors.muted, fontSize: 12)))),
        Expanded(
          child: ListView.builder(
            itemCount: res.length,
            itemBuilder: (_, i) {
              final sec = res[i];
              final ch = content.chapter(sec.primaryChapterId)!;
              final done = prog.completedSections.contains(sec.sectionId);
              return ListTile(
                leading: CircleAvatar(backgroundColor: done ? AppColors.success : AppColors.navy2, child: done ? const Icon(Icons.check, size: 18, color: Colors.white) : Text(sec.sectionNumber, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
                title: Text('${s.t('section')} ${sec.sectionNumber}', style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${sec.displayTitle}\n${ch.chapterNumber}. ${ch.name(bn)}', maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                isThreeLine: true,
                trailing: prog.bookmarkedSections.contains(sec.sectionId) ? const Icon(Icons.bookmark, color: AppColors.gold, size: 18) : null,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SectionScreen(sectionIds: res.map((e) => e.sectionId).toList(), index: i))),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _chip(String t, bool on, VoidCallback f) => Padding(
        padding: const EdgeInsets.only(right: 6, top: 4, bottom: 4),
        child: ChoiceChip(label: Text(t, style: TextStyle(fontSize: 12, color: on ? AppColors.navy : Colors.white)), selected: on, selectedColor: AppColors.gold, backgroundColor: AppColors.navy2, onSelected: (_) => f()),
      );
}
