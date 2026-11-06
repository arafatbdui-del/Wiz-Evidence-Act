import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../services/progress_service.dart';
import '../data/evidence_act_data.dart';
import '../models/gaming_chapter.dart';
import '../widgets/circular_progress_card.dart';
import '../widgets/chapter_card.dart';
import '../widgets/achievement_banner.dart';
import 'chapter_overview_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onSwitchTab;

  const HomeScreen({super.key, this.onSwitchTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalizationService _loc = LocalizationService();
  final ProgressService _progress = ProgressService();

  @override
  void initState() {
    super.initState();
    _loc.addListener(_onServiceUpdate);
    _progress.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _loc.removeListener(_onServiceUpdate);
    _progress.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  void _openChapter(GamingChapter chapter) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChapterOverviewScreen(chapter: chapter),
      ),
    );
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.secondaryNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.notifications_active_rounded, color: AppTheme.gold),
            const SizedBox(width: 8),
            Text(
              _loc.translate('Legal Notifications', 'আইনি নোটিফিকেশন'),
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationItem(
              '⚖️ Evidence (Amendment) Act 2022',
              _loc.translate(
                'Digital records (65B) & Forensic DNA (73B) modules are live!',
                'ডিজিটাল রেকর্ড (৬৫খ) ও ফরেনসিক ডিএনএ (৭৩খ) মডিউল উন্মুক্ত হয়েছে!',
              ),
            ),
            const Divider(color: Colors.white24, height: 16),
            _buildNotificationItem(
              '🔥 4-Day Daily Streak!',
              _loc.translate(
                'Keep up your daily practice to earn the Streak Master Badge.',
                'প্রতিদিনের অনুশীলন অব্যাহত রেখে স্ট্রিক মাস্টার ব্যাজ অর্জন করুন।',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              _loc.translate('Close', 'বন্ধ করুন'),
              style: const TextStyle(color: AppTheme.gold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AppTheme.goldLight, fontWeight: FontWeight.bold, fontSize: 13.5)),
        const SizedBox(height: 3),
        Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isBN = _loc.isBengali;

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar / Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Logo & Title
                    Row(
                      children: [
                        const Icon(
                          Icons.balance_rounded,
                          color: AppTheme.gold,
                          size: 34,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _loc.appName,
                              style: const TextStyle(
                                color: AppTheme.gold,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              _loc.appTagline,
                              style: const TextStyle(
                                color: AppTheme.goldLight,
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Language Toggle & Notification Bell
                    Row(
                      children: [
                        // Language Pill Switcher
                        GestureDetector(
                          onTap: () => _loc.toggleLanguage(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B3247),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.gold.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isBN ? AppTheme.gold : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'বাংলা',
                                    style: TextStyle(
                                      color: isBN ? AppTheme.primaryNavy : Colors.white70,
                                      fontSize: 11,
                                      fontWeight: isBN ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: !isBN ? AppTheme.gold : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'English',
                                    style: TextStyle(
                                      color: !isBN ? AppTheme.primaryNavy : Colors.white70,
                                      fontSize: 11,
                                      fontWeight: !isBN ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Notification Icon with Badge "2"
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              onPressed: _showNotificationDialog,
                              icon: const Icon(
                                Icons.notifications_none_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Positioned(
                              top: -2,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppTheme.errorRed,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: const Center(
                                  child: Text(
                                    '2',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Main Heading: "Your Legal Journey"
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  // Subtle court building silhouette illustration background
                  Positioned(
                    right: 8,
                    top: -10,
                    child: Opacity(
                      opacity: 0.14,
                      child: Icon(
                        Icons.account_balance_rounded,
                        size: 115,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _loc.yourLegalJourney,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _loc.legalJourneySubtitle,
                          style: const TextStyle(
                            color: Color(0xFFBAC7D5),
                            fontSize: 12.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Golden decorative curve swoosh
                        Container(
                          width: 42,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppTheme.gold,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Progress Summary Card (27% Completion, 3/11 Chapters, Total XP 850)
            SliverToBoxAdapter(
              child: CircularProgressCard(
                completedChapters: _progress.completedChaptersCount,
                totalChapters: _progress.totalChaptersCount,
                totalXP: _progress.totalXP,
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 6),
            ),

            // The 11 Thematic Gaming Chapters List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final chapter = EvidenceActData.chapters[index];
                  final status = _progress.getChapterStatus(chapter);
                  final completedSecs = _progress.getCompletedSectionsForChapter(chapter);
                  final totalSecs = chapter.sectionIds.length;

                  return ChapterCard(
                    chapter: chapter,
                    status: status,
                    completedSections: completedSecs,
                    totalSections: totalSecs,
                    onTap: () => _openChapter(chapter),
                  );
                },
                childCount: EvidenceActData.chapters.length,
              ),
            ),

            // Bottom Achievement Banner
            SliverToBoxAdapter(
              child: AchievementBanner(
                onStartLearning: () {
                  // Open first unlocked in-progress or available chapter
                  final activeChapter = EvidenceActData.chapters.firstWhere(
                    (c) => _progress.getChapterStatus(c) != ChapterStatus.locked,
                    orElse: () => EvidenceActData.chapters.first,
                  );
                  _openChapter(activeChapter);
                },
              ),
            ),

            // Bottom padding for scroll view
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      ),
    );
  }
}
