import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../data/evidence_act_data.dart';
import '../models/legal_section.dart';
import '../models/gaming_chapter.dart';
import 'section_detail_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final LocalizationService _loc = LocalizationService();
  String _searchQuery = '';
  String? _selectedChapterId;

  @override
  void initState() {
    super.initState();
    _loc.addListener(_update);
  }

  @override
  void dispose() {
    _loc.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isBN = _loc.isBengali;

    // Filter sections based on search query and chapter filter
    final filteredSections = EvidenceActData.sections.where((s) {
      final matchesQuery = _searchQuery.isEmpty ||
          s.sectionNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.sectionTitleEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.sectionTitleBn.contains(_searchQuery) ||
          s.keywords.any((k) => k.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesChapter = _selectedChapterId == null ||
          s.relatedChapterIds.contains(_selectedChapterId);

      return matchesQuery && matchesChapter;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: Text(
          _loc.translate('Statutory Law Directory', 'আইন পাঠ ও অনুসন্ধান'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: _loc.translate('Search section, keyword (e.g. 65B, DNA, Confession)...', 'ধারা বা বিষয় খুঁজুন (যেমন- ৬৫খ, ডিএনএ, জবানবন্দি)...'),
                  hintStyle: const TextStyle(color: AppTheme.mutedGrey, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.gold),
                  filled: true,
                  fillColor: AppTheme.secondaryNavy,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Chapter Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  FilterChip(
                    label: Text(_loc.translate('All Chapters', 'সকল অধ্যায়')),
                    selected: _selectedChapterId == null,
                    onSelected: (sel) => setState(() => _selectedChapterId = null),
                    selectedColor: AppTheme.gold,
                    checkmarkColor: AppTheme.primaryNavy,
                    labelStyle: TextStyle(
                      color: _selectedChapterId == null ? AppTheme.primaryNavy : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    backgroundColor: AppTheme.cardNavy,
                  ),
                  const SizedBox(width: 8),
                  ...EvidenceActData.chapters.map((ch) {
                    final isSel = _selectedChapterId == ch.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text('Ch ${ch.chapterNumber}'),
                        selected: isSel,
                        onSelected: (sel) => setState(() => _selectedChapterId = sel ? ch.id : null),
                        selectedColor: AppTheme.gold,
                        checkmarkColor: AppTheme.primaryNavy,
                        labelStyle: TextStyle(
                          color: isSel ? AppTheme.primaryNavy : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        backgroundColor: AppTheme.cardNavy,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Section List
            Expanded(
              child: filteredSections.isEmpty
                  ? Center(
                      child: Text(
                        _loc.translate('No legal sections found.', 'কোনো ধারা খুঁজে পাওয়া যায়নি।'),
                        style: const TextStyle(color: AppTheme.mutedGrey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredSections.length,
                      itemBuilder: (context, index) {
                        final section = filteredSections[index];
                        final title = isBN ? section.sectionTitleBn : section.sectionTitleEn;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: AppTheme.secondaryNavy,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                final parentChapter = EvidenceActData.chapters.firstWhere(
                                  (c) => section.relatedChapterIds.contains(c.id),
                                  orElse: () => EvidenceActData.chapters.first,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SectionDetailScreen(section: section, chapter: parentChapter),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryNavy,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppTheme.gold.withOpacity(0.5)),
                                      ),
                                      child: Text(
                                        section.sectionNumber,
                                        style: const TextStyle(
                                          color: AppTheme.gold,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            section.statutoryChapter,
                                            style: const TextStyle(
                                              color: AppTheme.mutedGrey,
                                              fontSize: 11.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (section.is2022Amendment) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.errorRed.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          '2022',
                                          style: TextStyle(color: AppTheme.errorRed, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.gold, size: 14),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
