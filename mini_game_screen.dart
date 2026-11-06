import 'package:flutter/material.dart';
import '../models/legal_section.dart';
import '../models/flashcard.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../services/progress_service.dart';
import '../data/evidence_act_data.dart';

class MiniGameScreen extends StatefulWidget {
  final LegalSection section;

  const MiniGameScreen({super.key, required this.section});

  @override
  State<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends State<MiniGameScreen> with SingleTickerProviderStateMixin {
  final LocalizationService _loc = LocalizationService();
  final ProgressService _progress = ProgressService();

  late TabController _tabController;
  bool _cardFlipped = false;
  int _flashcardIndex = 0;

  // True/False state
  int? _tfSelected; // 0 for True, 1 for False
  bool _tfAnswered = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isBN = _loc.isBengali;

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: Text(
          _loc.translate('Legal Mini-Games', 'আইনি মিনি-গেম'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.gold,
          labelColor: AppTheme.gold,
          unselectedLabelColor: AppTheme.mutedGrey,
          tabs: [
            Tab(icon: const Icon(Icons.style_rounded), text: _loc.translate('Flashcards', 'ফ্ল্যাশকার্ড')),
            Tab(icon: const Icon(Icons.fact_check_rounded), text: _loc.translate('True / False', 'সত্য / মিথ্যা')),
            Tab(icon: const Icon(Icons.compare_arrows_rounded), text: _loc.translate('Term Match', 'শব্দ মেলানো')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFlashcardGame(isBN),
          _buildTrueFalseGame(isBN),
          _buildTermMatchGame(isBN),
        ],
      ),
    );
  }

  // GAME 1: Spaced Repetition Flashcards
  Widget _buildFlashcardGame(bool isBN) {
    final cards = EvidenceActData.flashcards;
    final currentCard = cards[_flashcardIndex % cards.length];

    final frontText = isBN ? currentCard.frontTextBn : currentCard.frontTextEn;
    final backText = isBN ? currentCard.backTextBn : currentCard.backTextEn;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '${_loc.translate('Card', 'কার্ড')} ${_flashcardIndex + 1} / ${cards.length}',
            style: const TextStyle(color: AppTheme.goldLight, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            _loc.translate('Tap card to flip between Question and Statutory Principle', 'প্রশ্ন ও মূল নীতি দেখতে কার্ডে ট্যাপ করুন'),
            style: const TextStyle(color: AppTheme.mutedGrey, fontSize: 12),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _cardFlipped = !_cardFlipped;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _cardFlipped ? const Color(0xFF1B4D43) : AppTheme.secondaryNavy,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _cardFlipped ? AppTheme.emeraldGreen : AppTheme.gold.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _cardFlipped ? Icons.lightbulb_rounded : Icons.help_outline_rounded,
                      color: _cardFlipped ? AppTheme.gold : AppTheme.goldLight,
                      size: 40,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _cardFlipped ? _loc.translate('STATUTORY PRINCIPLE', 'আইনগত মূলনীতি') : _loc.translate('LEGAL QUESTION', 'আইনি প্রশ্ন'),
                      style: TextStyle(
                        color: _cardFlipped ? AppTheme.gold : AppTheme.goldLight,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _cardFlipped ? backText : frontText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _flashcardIndex = (_flashcardIndex + 1) % cards.length;
                      _cardFlipped = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.gold),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_loc.translate('Next Card', 'পরবর্তী কার্ড'), style: const TextStyle(color: AppTheme.gold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _progress.addXP(10);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_loc.translate('Mastered Card! +10 XP', 'কার্ডটি আয়ত্ত করেছেন! +১০ এক্সপি')),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                    setState(() {
                      _flashcardIndex = (_flashcardIndex + 1) % cards.length;
                      _cardFlipped = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emeraldGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_loc.translate('Mastered (+10 XP)', 'আয়ত্ত করেছি (+১০)')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // GAME 2: True or False Challenge
  Widget _buildTrueFalseGame(bool isBN) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.secondaryNavy,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                const Icon(Icons.balance_rounded, color: AppTheme.gold, size: 36),
                const SizedBox(height: 12),
                Text(
                  _loc.translate(
                    'True or False: Under the 2022 Amendment, a digital CCTV recording is recognized as a "Document" under Section 3.',
                    'সত্য না মিথ্যা: ২০২২ সালের সংশোধনীর পর ধারা ৩ অনুযায়ী ডিজিটাল সিসিটিভি ফুটেজ একটি "দলিল" হিসেবে গণ্য হয়।',
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _tfSelected = 0; // True selected
                      _tfAnswered = true;
                    });
                    _progress.addXP(15);
                  },
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text(_loc.translate('TRUE', 'সত্য')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _tfAnswered && _tfSelected == 0 ? AppTheme.successGreen : AppTheme.cardNavy,
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppTheme.successGreen, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _tfSelected = 1; // False selected
                      _tfAnswered = true;
                    });
                  },
                  icon: const Icon(Icons.cancel_outlined),
                  label: Text(_loc.translate('FALSE', 'মিথ্যা')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _tfAnswered && _tfSelected == 1 ? AppTheme.errorRed : AppTheme.cardNavy,
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppTheme.errorRed, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
          if (_tfAnswered) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF17374D),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.gold),
              ),
              child: Text(
                _loc.translate(
                  'Correct! Section 3 was explicitly amended by the Evidence (Amendment) Act 2022 to insert "and includes any digital record".',
                  'সঠিক! সাক্ষ্য (সংশোধন) আইন ২০২২ এর মাধ্যমে ধারা ৩-এ "যেকোনো ডিজিটাল রেকর্ড অন্তর্ভুক্ত" কথাটি স্পষ্টভাবে যুক্ত করা হয়েছে।',
                ),
                style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // GAME 3: Match the Legal Term
  Widget _buildTermMatchGame(bool isBN) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          Text(
            _loc.translate('Match Legal Concepts with their Definitions', 'আইনি ধারণার সাথে তাদের সঠিক ব্যাখ্যা মেলান'),
            style: const TextStyle(color: AppTheme.goldLight, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 16),
          _buildMatchPair('Res Gestae (Sec 6)', 'Same Transaction Connected Facts'),
          _buildMatchPair('Section 25 Bar', 'Confession to Police Inadmissible'),
          _buildMatchPair('Section 65B', 'Electronic / Digital Record Certificate'),
          _buildMatchPair('Section 73B', 'Forensic Comparison of DNA & Blood'),
          _buildMatchPair('Section 146 Proviso', 'Protection of Rape Survivors in Cross'),
        ],
      ),
    );
  }

  Widget _buildMatchPair(String term, String definition) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.secondaryNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.gold.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.link_rounded, color: AppTheme.gold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(term, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(definition, style: const TextStyle(color: AppTheme.mutedGrey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 20),
        ],
      ),
    );
  }
}
