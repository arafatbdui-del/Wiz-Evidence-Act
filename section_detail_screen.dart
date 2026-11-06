import 'package:flutter/material.dart';
import '../models/legal_section.dart';
import '../models/gaming_chapter.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../services/progress_service.dart';
import '../data/evidence_act_data.dart';
import 'mcq_practice_screen.dart';
import 'mini_game_screen.dart';

class SectionDetailScreen extends StatefulWidget {
  final LegalSection section;
  final GamingChapter chapter;

  const SectionDetailScreen({
    super.key,
    required this.section,
    required this.chapter,
  });

  @override
  State<SectionDetailScreen> createState() => _SectionDetailScreenState();
}

class _SectionDetailScreenState extends State<SectionDetailScreen> {
  final LocalizationService _loc = LocalizationService();
  final ProgressService _progress = ProgressService();
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _loc.addListener(_update);
    _progress.addListener(_update);
  }

  @override
  void dispose() {
    _loc.removeListener(_update);
    _progress.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (mounted) setState(() {});
  }

  void _toggleAudio() {
    setState(() {
      _isPlayingAudio = !_isPlayingAudio;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isPlayingAudio
              ? _loc.translate('Reading Section aloud...', 'ধারাটি পাঠ করে শোনানো হচ্ছে...')
              : _loc.translate('Audio paused', 'অডিও বিরতি দেওয়া হয়েছে'),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.secondaryNavy,
      ),
    );
  }

  void _openMCQPractice() {
    // Filter questions for this section
    final sectionQuestions = EvidenceActData.questions.where((q) => q.sectionId == widget.section.sectionId).toList();
    final questions = sectionQuestions.isNotEmpty
        ? sectionQuestions
        : EvidenceActData.questions.take(3).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MCQPracticeScreen(
          title: '${widget.section.sectionNumber} Quiz',
          questions: questions,
          onComplete: () {
            _progress.completeSection(widget.section.sectionId, xp: 15);
          },
        ),
      ),
    );
  }

  void _openMiniGames() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MiniGameScreen(section: widget.section),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isBN = _loc.isBengali;
    final isBookmarked = _progress.isSectionBookmarked(widget.section.sectionId);
    final isCompleted = _progress.isSectionCompleted(widget.section.sectionId);

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: Text(
          widget.section.sectionNumber,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Audio Read-aloud button
          IconButton(
            icon: Icon(
              _isPlayingAudio ? Icons.volume_up_rounded : Icons.volume_up_outlined,
              color: _isPlayingAudio ? AppTheme.gold : Colors.white,
            ),
            tooltip: _loc.translate('Listen', 'শুনুন'),
            onPressed: _toggleAudio,
          ),
          // Bookmark button
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: isBookmarked ? AppTheme.gold : Colors.white,
            ),
            onPressed: () => _progress.toggleBookmark(widget.section.sectionId),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statutory Chapter & 2022 Amendment tag
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.section.statutoryChapter,
                    style: const TextStyle(
                      color: AppTheme.goldLight,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (widget.section.is2022Amendment)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withOpacity(0.2),
                      border: Border.all(color: AppTheme.errorRed),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _loc.amendmentBadge,
                      style: const TextStyle(color: AppTheme.errorRed, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Section Title
            Text(
              isBN ? widget.section.sectionTitleBn : widget.section.sectionTitleEn,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // BLOCK 1: Authentic Statutory Law
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2F44),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.gold.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.menu_book_rounded, color: AppTheme.gold, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _loc.originalStatute,
                        style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _loc.statutoryNotice,
                    style: const TextStyle(color: AppTheme.mutedGrey, fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                  const Divider(color: Colors.white24, height: 16),
                  Text(
                    widget.section.originalTextEn,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      height: 1.5,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  if (widget.section.banglaTranslation.isNotEmpty) ...[
                    const Divider(color: Colors.white24, height: 18),
                    Row(
                      children: [
                        const Icon(Icons.translate_rounded, color: AppTheme.emeraldGreen, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          _loc.banglaTranslation,
                          style: const TextStyle(color: AppTheme.emeraldGreen, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.section.banglaTranslation,
                      style: const TextStyle(
                        color: Color(0xFFE6EEF5),
                        fontSize: 13.5,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 18),

            // BLOCK 2: Educational Explanation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondaryNavy,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.goldLight, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _loc.simplifiedExplanation,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isBN ? widget.section.banglaExplanation : widget.section.englishExplanation,
                    style: const TextStyle(color: Color(0xFFD4DEE8), fontSize: 13.5, height: 1.45),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // BLOCK 3: Practical Legal Example
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A3833),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.emeraldGreen),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.gavel_rounded, color: AppTheme.gold, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _loc.practicalExample,
                        style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isBN ? widget.section.practicalExampleBn : widget.section.practicalExampleEn,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.45),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons: Practice MCQs & Mini-games
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openMCQPractice,
                    icon: const Icon(Icons.quiz_rounded),
                    label: Text(_loc.translate('Practice MCQs', 'MCQ অনুশীলন')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.emeraldGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openMiniGames,
                    icon: const Icon(Icons.sports_esports_rounded),
                    label: Text(_loc.translate('Play Mini-Game', 'মিনি গেম খেলুন')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cardNavy,
                      foregroundColor: AppTheme.gold,
                      side: const BorderSide(color: AppTheme.gold),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Mark Complete Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _progress.completeSection(widget.section.sectionId, xp: 15);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_loc.translate('Section completed! +15 XP', 'ধারা সম্পন্ন হয়েছে! +১৫ এক্সপি')),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                },
                icon: Icon(
                  isCompleted ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                  color: isCompleted ? AppTheme.successGreen : Colors.white70,
                ),
                label: Text(
                  isCompleted
                      ? _loc.translate('Completed (+15 XP Earned)', 'সম্পন্ন হয়েছে (+১৫ এক্সপি অর্জিত)')
                      : _loc.translate('Mark Section as Completed (+15 XP)', 'ধারাটি সম্পন্ন চিহ্নিত করুন (+১৫ এক্সপি)'),
                  style: TextStyle(
                    color: isCompleted ? AppTheme.successGreen : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: isCompleted ? AppTheme.successGreen : Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
