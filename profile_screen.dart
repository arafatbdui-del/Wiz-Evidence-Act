import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../services/progress_service.dart';
import '../data/evidence_act_data.dart';
import 'section_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  void _showResetConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.secondaryNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          _loc.translate('Reset Learning Progress?', 'অগ্রগতি রিসেট করবেন?'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          _loc.translate(
            'This will clear your completed chapters, earned XP, and saved bookmarks. This action cannot be undone.',
            'এটি আপনার সমস্ত সম্পন্ন অধ্যায়, অর্জিত এক্সপি এবং সংরক্ষিত বুকমার্ক মুছে ফেলবে। এটি পুনর্বহাল করা যাবে না।',
          ),
          style: const TextStyle(color: AppTheme.mutedGrey, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_loc.translate('Cancel', 'বাতিল'), style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              _progress.resetProgress();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_loc.translate('Progress reset successfully.', 'অগ্রগতি সফলভাবে রিসেট করা হয়েছে।')),
                  backgroundColor: AppTheme.errorRed,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: Text(_loc.translate('Reset All', 'সব রিসেট করুন'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isBN = _loc.isBengali;
    final bookmarks = EvidenceActData.sections.where(
      (s) => _progress.progress.bookmarkedSections.contains(s.sectionId),
    ).toList();

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: Text(
          _loc.translate('User Profile & Settings', 'প্রোফাইল ও সেটিংস'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // User Avatar & Rank Tier
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.secondaryNavy,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.gold.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.gold.withOpacity(0.2),
                      border: Border.all(color: AppTheme.gold, width: 2),
                    ),
                    child: const Icon(Icons.person_rounded, color: AppTheme.gold, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Advocate Candidate',
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _progress.level,
                          style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${_progress.streak} ${_loc.translate('Day Streak', 'দিনের স্ট্রিক')}',
                              style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4 Quick Stats Grid
            Row(
              children: [
                _buildStatTile(
                  title: _loc.totalXP,
                  value: '${_progress.totalXP}',
                  icon: Icons.star_rounded,
                  color: AppTheme.gold,
                ),
                const SizedBox(width: 10),
                _buildStatTile(
                  title: _loc.translate('Chapters', 'অধ্যায়'),
                  value: '${_progress.completedChaptersCount} / 11',
                  icon: Icons.check_circle_rounded,
                  color: AppTheme.emeraldGreen,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildStatTile(
                  title: _loc.translate('Bookmarks', 'বুকমার্ক'),
                  value: '${bookmarks.length}',
                  icon: Icons.bookmark_rounded,
                  color: AppTheme.goldLight,
                ),
                const SizedBox(width: 10),
                _buildStatTile(
                  title: _loc.translate('Badges', 'ব্যাজ'),
                  value: '${_progress.progress.earnedBadgeIds.length}',
                  icon: Icons.emoji_events_rounded,
                  color: Colors.amber,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Language Switcher Setting
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.secondaryNavy,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language_rounded, color: AppTheme.gold),
                      const SizedBox(width: 12),
                      Text(
                        _loc.translate('Application Language', 'অ্যাপ্লিকেশনের ভাষা'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ],
                  ),
                  DropdownButton<AppLanguage>(
                    value: _loc.currentLanguage,
                    dropdownColor: AppTheme.secondaryNavy,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: AppLanguage.en, child: Text('English', style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(value: AppLanguage.bn, child: Text('বাংলা', style: TextStyle(color: Colors.white))),
                    ],
                    onChanged: (lang) {
                      if (lang != null) _loc.setLanguage(lang);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Bookmarked Sections
            Text(
              _loc.translate('Bookmarked Legal Sections', 'সংরক্ষিত আইনি ধারা'),
              style: const TextStyle(color: AppTheme.goldLight, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),

            if (bookmarks.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryNavy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _loc.translate('No bookmarked sections yet. Tap bookmark on any section to save it here.', 'কোনো সংরক্ষিত ধারা নেই। যেকোনো ধারায় বুকমার্ক ট্যাপ করে সংরক্ষণ করুন।'),
                  style: const TextStyle(color: AppTheme.mutedGrey, fontSize: 12),
                ),
              )
            else
              ...bookmarks.map((sec) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: AppTheme.secondaryNavy,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        final parent = EvidenceActData.chapters.firstWhere(
                          (c) => sec.relatedChapterIds.contains(c.id),
                          orElse: () => EvidenceActData.chapters.first,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SectionDetailScreen(section: sec, chapter: parent),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            const Icon(Icons.bookmark_added_rounded, color: AppTheme.gold, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${sec.sectionNumber}: ${isBN ? sec.sectionTitleBn : sec.sectionTitleEn}',
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.gold, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),

            const SizedBox(height: 24),

            // Reset Learning Progress
            OutlinedButton.icon(
              onPressed: _showResetConfirmDialog,
              icon: const Icon(Icons.delete_sweep_rounded, color: AppTheme.errorRed),
              label: Text(
                _loc.translate('Reset Learning Progress', 'অগ্রগতি রিসেট করুন'),
                style: const TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.errorRed),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.secondaryNavy,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppTheme.mutedGrey, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
