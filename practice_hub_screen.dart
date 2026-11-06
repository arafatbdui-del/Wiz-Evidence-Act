import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../services/progress_service.dart';
import '../data/evidence_act_data.dart';
import 'mcq_practice_screen.dart';
import 'mini_game_screen.dart';

class PracticeHubScreen extends StatefulWidget {
  const PracticeHubScreen({super.key});

  @override
  State<PracticeHubScreen> createState() => _PracticeHubScreenState();
}

class _PracticeHubScreenState extends State<PracticeHubScreen> {
  final LocalizationService _loc = LocalizationService();
  final ProgressService _progress = ProgressService();

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

  void _startRandomQuiz() {
    final list = List.of(EvidenceActData.questions)..shuffle();
    final quizQuestions = list.take(5).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MCQPracticeScreen(
          title: _loc.translate('Rapid MCQ Sprint', 'দ্রুত MCQ পরীক্ষা'),
          questions: quizQuestions,
        ),
      ),
    );
  }

  void _openMistakeNotebook() {
    final mistakes = EvidenceActData.questions.where(
      (q) => _progress.progress.mistakeQuestionIds.contains(q.questionId),
    ).toList();

    if (mistakes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_loc.translate('No mistakes logged! Excellent work.', 'কোনো ভুলের তালিকা নেই! চমৎকার প্রস্তুতি।')),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MCQPracticeScreen(
          title: _loc.translate('Mistake Notebook Review', 'ভুল নোটবুক সংশোধন'),
          questions: mistakes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mistakeCount = _progress.progress.mistakeQuestionIds.length;

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: Text(
          _loc.translate('Practice & Test Arena', 'অনুশীলন ও পরীক্ষা অঙ্গন'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Mistake Notebook Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: mistakeCount > 0 ? const Color(0xFF381F25) : AppTheme.secondaryNavy,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: mistakeCount > 0 ? AppTheme.errorRed : Colors.white12,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: mistakeCount > 0 ? AppTheme.errorRed.withOpacity(0.2) : AppTheme.cardNavy,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: mistakeCount > 0 ? AppTheme.errorRed : AppTheme.gold,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _loc.translate('Mistake Notebook', 'ভুল খাতা (Mistake Notebook)'),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mistakeCount > 0
                              ? '$mistakeCount ${_loc.translate('questions to master again', 'টি প্রশ্ন পুনরায় ঝালাই করার বাকি')}'
                              : _loc.translate('Zero errors recorded. Perfect streak!', 'কোনো ভুল সংরক্ষিত নেই। নিখুঁত প্রস্তুতি!'),
                          style: const TextStyle(color: AppTheme.mutedGrey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _openMistakeNotebook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mistakeCount > 0 ? AppTheme.errorRed : AppTheme.cardNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(_loc.translate('Review', 'রিভিউ')),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Rapid MCQ Sprint
            _buildPracticeCard(
              title: _loc.translate('Rapid MCQ Sprint', 'র‌্যাপিড MCQ স্প্রিন্ট'),
              subtitle: _loc.translate('Quick 5-question speed test to earn fast XP', 'দ্রুত ৫টি প্রশ্নের কুইজ এবং দ্রুত এক্সপি অর্জন'),
              icon: Icons.flash_on_rounded,
              iconColor: AppTheme.gold,
              onTap: _startRandomQuiz,
            ),

            const SizedBox(height: 12),

            // Flashcards Spaced Repetition
            _buildPracticeCard(
              title: _loc.translate('Spaced Repetition Flashcards', 'ফ্ল্যাশকার্ড অনুশীলন'),
              subtitle: _loc.translate('Memorize key sections, definitions & amendments', 'গুরুত্বপূর্ণ ধারা, সংজ্ঞা ও সংশোধনী মুখস্থ করুন'),
              icon: Icons.style_rounded,
              iconColor: AppTheme.emeraldGreen,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MiniGameScreen(section: EvidenceActData.sections.first),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Practice by Chapter
            Text(
              _loc.translate('Practice by Thematic Chapter', 'অধ্যায়ভিত্তিক টেস্ট'),
              style: const TextStyle(color: AppTheme.goldLight, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            ...EvidenceActData.chapters.map((ch) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: AppTheme.secondaryNavy,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      final chapterQuestions = EvidenceActData.questions.where(
                        (q) => q.chapterId == ch.id,
                      ).toList();
                      final questions = chapterQuestions.isNotEmpty
                          ? chapterQuestions
                          : EvidenceActData.questions.take(3).toList();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MCQPracticeScreen(
                            title: ch.titleEn,
                            questions: questions,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.cardNavy,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${ch.chapterNumber}',
                              style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _loc.isBengali ? ch.titleBn : ch.titleEn,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5),
                            ),
                          ),
                          const Icon(Icons.play_circle_outline_rounded, color: AppTheme.gold, size: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppTheme.secondaryNavy,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: AppTheme.mutedGrey, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.gold, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
