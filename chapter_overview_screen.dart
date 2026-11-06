import 'package:flutter/material.dart';
import '../models/gaming_chapter.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../services/progress_service.dart';
import '../data/evidence_act_data.dart';
import '../widgets/duo_learning_node.dart';
import 'section_detail_screen.dart';
import 'boss_battle_screen.dart';

class ChapterOverviewScreen extends StatefulWidget {
  final GamingChapter chapter;

  const ChapterOverviewScreen({super.key, required this.chapter});

  @override
  State<ChapterOverviewScreen> createState() => _ChapterOverviewScreenState();
}

class _ChapterOverviewScreenState extends State<ChapterOverviewScreen> {
  final ProgressService _progress = ProgressService();
  final LocalizationService _loc = LocalizationService();

  @override
  void initState() {
    super.initState();
    _progress.addListener(_update);
    _loc.addListener(_update);
  }

  @override
  void dispose() {
    _progress.removeListener(_update);
    _loc.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isBN = _loc.isBengali;
    final title = isBN ? widget.chapter.titleBn : widget.chapter.titleEn;
    final description = isBN ? widget.chapter.descriptionBn : widget.chapter.descriptionEn;

    // Get all sections for this chapter
    final chapterSections = EvidenceActData.sections.where(
      (s) => widget.chapter.sectionIds.contains(s.sectionId) || s.relatedChapterIds.contains(widget.chapter.id),
    ).toList();

    final completedCount = _progress.getCompletedSectionsForChapter(widget.chapter);
    final totalCount = chapterSections.length;
    final bool allSectionsCompleted = completedCount >= totalCount && totalCount > 0;
    final bool isBossCompleted = _progress.isChapterCompleted(widget.chapter.chapterNumber);

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.cardNavy,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.goldLight.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: AppTheme.gold, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${_progress.totalXP} XP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Chapter Summary Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondaryNavy,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.emeraldGreen.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.emeraldGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_loc.translate('Chapter', 'অধ্যায়')} ${widget.chapter.chapterNumber}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.emoji_events_rounded, color: AppTheme.gold, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.chapter.totalXP} XP',
                            style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: const TextStyle(color: Color(0xFFD3DDE8), fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  // Progress indicator
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: totalCount > 0 ? (completedCount / totalCount) : 0,
                            minHeight: 8,
                            backgroundColor: const Color(0xFF162B3F),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.gold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$completedCount / $totalCount ${_loc.translate('Sections', 'ধারা')}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Duolingo-style vertical path
            ...chapterSections.asMap().entries.map((entry) {
              final index = entry.key;
              final section = entry.value;
              final isCompleted = _progress.isSectionCompleted(section.sectionId);
              // Unlock first section, or if previous section is completed
              final bool isUnlocked = index == 0 || _progress.isSectionCompleted(chapterSections[index - 1].sectionId);

              NodeState nodeState;
              if (isCompleted) {
                nodeState = NodeState.completed;
              } else if (isUnlocked) {
                nodeState = NodeState.current;
              } else {
                nodeState = NodeState.locked;
              }

              return Column(
                children: [
                  DuoLearningNode(
                    title: section.sectionNumber,
                    subtitle: isBN ? section.sectionTitleBn : section.sectionTitleEn,
                    xp: 15,
                    state: nodeState,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SectionDetailScreen(section: section, chapter: widget.chapter),
                        ),
                      );
                    },
                  ),
                  // Connecting path line
                  Container(
                    width: 3,
                    height: 32,
                    color: isCompleted ? AppTheme.successGreen : Colors.white24,
                  ),
                ],
              );
            }).toList(),

            // Chapter Boss Battle Node
            DuoLearningNode(
              title: _loc.translate('Courtroom Boss Battle', 'আদালতের বস ব্যাটেল'),
              subtitle: _loc.translate('Case Scenario Test', 'বাস্তব মামলার চ্যালেঞ্জ'),
              xp: 50,
              isBossBattle: true,
              state: isBossCompleted
                  ? NodeState.completed
                  : (allSectionsCompleted ? NodeState.current : NodeState.locked),
              onTap: () {
                final challenge = EvidenceActData.caseChallenges.firstWhere(
                  (c) => c.chapterId == widget.chapter.id,
                  orElse: () => EvidenceActData.caseChallenges.first,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BossBattleScreen(
                      chapter: widget.chapter,
                      challenge: challenge,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
