import 'package:flutter/material.dart';
import '../models/gaming_chapter.dart';
import '../models/case_challenge.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../services/progress_service.dart';

class BossBattleScreen extends StatefulWidget {
  final GamingChapter chapter;
  final CaseChallenge challenge;

  const BossBattleScreen({
    super.key,
    required this.chapter,
    required this.challenge,
  });

  @override
  State<BossBattleScreen> createState() => _BossBattleScreenState();
}

class _BossBattleScreenState extends State<BossBattleScreen> {
  final LocalizationService _loc = LocalizationService();
  final ProgressService _progress = ProgressService();

  int? _selectedOption;
  bool _isAnswered = false;
  bool _isVictory = false;

  void _submitAnswer(int optionIndex) {
    if (_isAnswered) return;

    setState(() {
      _selectedOption = optionIndex;
      _isAnswered = true;
      _isVictory = optionIndex == widget.challenge.correctOptionIndex;

      if (_isVictory) {
        _progress.completeChapter(widget.chapter.chapterNumber, xpReward: widget.chapter.totalXP);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isBN = _loc.isBengali;
    final scenario = isBN ? widget.challenge.scenarioBn : widget.challenge.scenarioEn;
    final question = isBN ? widget.challenge.questionBn : widget.challenge.questionEn;
    final options = isBN ? widget.challenge.optionsBn : widget.challenge.optionsEn;
    final explanation = isBN ? widget.challenge.explanationBn : widget.challenge.explanationEn;

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.shield_rounded, color: AppTheme.gold),
            const SizedBox(width: 8),
            Text(
              '${_loc.translate('Chapter', 'অধ্যায়')} ${widget.chapter.chapterNumber} ${_loc.translate('Boss Battle', 'বস ব্যাটেল')}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Boss Courtroom Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF224363), Color(0xFF132A40)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.gold, width: 1.5),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.gavel_rounded, color: AppTheme.gold, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      _loc.translate('COURTROOM CASE SCENARIO', 'আদালতের বাস্তব মোকাদ্দমা'),
                      style: const TextStyle(
                        color: AppTheme.gold,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      scenario,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // The Challenge Question
              Text(
                question,
                style: const TextStyle(
                  color: AppTheme.goldLight,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Options
              ...options.asMap().entries.map((entry) {
                final idx = entry.key;
                final text = entry.value;
                final isSelected = _selectedOption == idx;
                final isCorrect = idx == widget.challenge.correctOptionIndex;

                Color bg = AppTheme.secondaryNavy;
                Color border = Colors.white12;

                if (_isAnswered) {
                  if (isCorrect) {
                    bg = AppTheme.emeraldGreen.withOpacity(0.4);
                    border = AppTheme.successGreen;
                  } else if (isSelected) {
                    bg = AppTheme.errorRed.withOpacity(0.4);
                    border = AppTheme.errorRed;
                  }
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _submitAnswer(idx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? AppTheme.gold : Colors.white12,
                              ),
                              child: Center(
                                child: Text(
                                  '${idx + 1}',
                                  style: TextStyle(
                                    color: isSelected ? AppTheme.primaryNavy : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                text,
                                style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w500),
                              ),
                            ),
                            if (_isAnswered && isCorrect)
                              const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen)
                            else if (_isAnswered && isSelected && !isCorrect)
                              const Icon(Icons.cancel_rounded, color: AppTheme.errorRed),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),

              // Explanation & Victory Panel
              if (_isAnswered) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isVictory ? const Color(0xFF194038) : const Color(0xFF452220),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _isVictory ? AppTheme.successGreen : AppTheme.errorRed),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isVictory ? Icons.emoji_events_rounded : Icons.info_outline_rounded,
                            color: _isVictory ? AppTheme.gold : Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isVictory
                                ? _loc.translate('VICTORY! CHAPTER COMPLETED!', 'অভিনন্দন! অধ্যায় সফলভাবে সম্পন্ন!')
                                : _loc.translate('INCORRECT LEGAL RULING', 'ভুল আইনি সিদ্ধান্ত'),
                            style: TextStyle(
                              color: _isVictory ? AppTheme.gold : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        explanation,
                        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                      ),
                      if (_isVictory) ...[
                        const SizedBox(height: 10),
                        Text(
                          '+${widget.chapter.totalXP} XP ${_loc.translate('Added to Profile! Next chapter unlocked.', 'প্রোফাইলে যুক্ত হয়েছে! পরবর্তী অধ্যায় উন্মুক্ত।')}',
                          style: const TextStyle(color: AppTheme.goldLight, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      foregroundColor: AppTheme.primaryNavy,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _loc.translate('Claim Rewards & Return Home', 'পুরস্কার গ্রহণ করে হোমে ফিরুন'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
}
