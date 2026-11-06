import 'package:flutter/material.dart';
import '../models/question.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../services/progress_service.dart';

class MCQPracticeScreen extends StatefulWidget {
  final String title;
  final List<Question> questions;
  final VoidCallback? onComplete;

  const MCQPracticeScreen({
    super.key,
    required this.title,
    required this.questions,
    this.onComplete,
  });

  @override
  State<MCQPracticeScreen> createState() => _MCQPracticeScreenState();
}

class _MCQPracticeScreenState extends State<MCQPracticeScreen> {
  final LocalizationService _loc = LocalizationService();
  final ProgressService _progress = ProgressService();

  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;
  int _score = 0;
  int _earnedXP = 0;
  bool _quizFinished = false;

  void _handleOptionSelect(int index) {
    if (_isAnswered) return;

    setState(() {
      _selectedOptionIndex = index;
      _isAnswered = true;

      final currentQuestion = widget.questions[_currentIndex];
      final isCorrect = index == currentQuestion.correctIndex;

      if (isCorrect) {
        _score++;
        _earnedXP += currentQuestion.xpReward;
        _progress.removeMistake(currentQuestion.questionId);
      } else {
        _progress.recordMistake(currentQuestion.questionId);
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _isAnswered = false;
      });
    } else {
      setState(() {
        _quizFinished = true;
      });
      _progress.addXP(_earnedXP);
      widget.onComplete?.call();
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _selectedOptionIndex = null;
      _isAnswered = false;
      _score = 0;
      _earnedXP = 0;
      _quizFinished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isBN = _loc.isBengali;

    if (_quizFinished) {
      return _buildScoreScreen(isBN);
    }

    final currentQuestion = widget.questions[_currentIndex];
    final questionText = isBN ? currentQuestion.questionTextBn : currentQuestion.questionTextEn;
    final options = isBN ? currentQuestion.optionsBn : currentQuestion.optionsEn;
    final explanation = isBN ? currentQuestion.explanationBn : currentQuestion.explanationEn;

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar & Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_loc.translate('Question', 'প্রশ্ন')} ${_currentIndex + 1} / ${widget.questions.length}',
                    style: const TextStyle(color: AppTheme.goldLight, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_score * 15} XP',
                    style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / widget.questions.length,
                  minHeight: 6,
                  backgroundColor: AppTheme.secondaryNavy,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.gold),
                ),
              ),

              const SizedBox(height: 20),

              // Question Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryNavy,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  questionText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 4 Options
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, idx) {
                    final isSelected = _selectedOptionIndex == idx;
                    final isCorrect = idx == currentQuestion.correctIndex;

                    Color optionBg = AppTheme.cardNavy;
                    Color borderColor = Colors.white12;
                    Color textColor = Colors.white;

                    if (_isAnswered) {
                      if (isCorrect) {
                        optionBg = AppTheme.emeraldGreen.withOpacity(0.3);
                        borderColor = AppTheme.successGreen;
                        textColor = Colors.white;
                      } else if (isSelected) {
                        optionBg = AppTheme.errorRed.withOpacity(0.3);
                        borderColor = AppTheme.errorRed;
                        textColor = Colors.white;
                      }
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: optionBg,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _handleOptionSelect(idx),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? AppTheme.gold : Colors.white10,
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + idx), // A, B, C, D
                                      style: TextStyle(
                                        color: isSelected ? AppTheme.primaryNavy : Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    options[idx],
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (_isAnswered && isCorrect)
                                  const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 22)
                                else if (_isAnswered && isSelected && !isCorrect)
                                  const Icon(Icons.cancel_rounded, color: AppTheme.errorRed, size: 22),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Statutory Explanation Panel (Shown when answered)
              if (_isAnswered) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF142E47),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.gold.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppTheme.gold, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            _loc.translate('Legal Explanation', 'আইনি ব্যাখ্যা'),
                            style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold, fontSize: 12.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        explanation,
                        style: const TextStyle(color: Color(0xFFE2EAF2), fontSize: 12, height: 1.35),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      foregroundColor: AppTheme.primaryNavy,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _currentIndex < widget.questions.length - 1
                          ? _loc.translate('Next Question', 'পরবর্তী প্রশ্ন')
                          : _loc.translate('View Results', 'ফলাফল দেখুন'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreScreen(bool isBN) {
    final bool passed = _score >= (widget.questions.length / 2);

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                passed ? Icons.emoji_events_rounded : Icons.replay_circle_filled_rounded,
                color: passed ? AppTheme.gold : AppTheme.errorRed,
                size: 80,
              ),
              const SizedBox(height: 16),
              Text(
                passed
                    ? _loc.translate('Quiz Completed!', 'কুইজ সম্পন্ন হয়েছে!')
                    : _loc.translate('Keep Practicing!', 'অনুশীলন চালিয়ে যান!'),
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${_loc.translate('You scored', 'আপনার স্কোর')}: $_score / ${widget.questions.length}',
                style: const TextStyle(color: AppTheme.goldLight, fontSize: 18),
              ),
              const SizedBox(height: 6),
              Text(
                '+$_earnedXP XP ${_loc.translate('Earned', 'অর্জিত')}',
                style: const TextStyle(color: AppTheme.successGreen, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(_loc.translate('Return to Chapter', 'অধ্যায়ে ফিরে যান')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emeraldGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _restartQuiz,
                icon: const Icon(Icons.refresh_rounded, color: AppTheme.gold),
                label: Text(_loc.translate('Retry Quiz', 'পুনরায় চেষ্টা করুন'), style: const TextStyle(color: AppTheme.gold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.gold),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
