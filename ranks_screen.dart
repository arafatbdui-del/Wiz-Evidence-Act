import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../services/progress_service.dart';
import '../data/evidence_act_data.dart';

class RanksScreen extends StatelessWidget {
  const RanksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();
    final progress = ProgressService();

    final userXP = progress.totalXP;

    // Realistic offline peer candidates for Bangladesh Bar Council / Judicial Service aspirants
    final leaderboard = [
      {'rank': 1, 'name': 'Tanvir Ahmed (Judicial Aspirant)', 'xp': 1420, 'badge': '🥇'},
      {'rank': 2, 'name': 'Nusrat Jahan (Bar Candidate)', 'xp': 1180, 'badge': '🥈'},
      {'rank': 3, 'name': 'You (Current Learner)', 'xp': userXP, 'badge': '🥉', 'isUser': true},
      {'rank': 4, 'name': 'Sabbir Hossain (DU Law)', 'xp': 720, 'badge': '⚖️'},
      {'rank': 5, 'name': 'Fahmida Akter (Chittagong Univ)', 'xp': 640, 'badge': '📚'},
      {'rank': 6, 'name': 'Mehedi Hasan (BJU)', 'xp': 510, 'badge': '⭐'},
    ];

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: Text(
          loc.translate('National Law Leaderboard', 'জাতীয় লিডারবোর্ড ও র্যাঙ্ক'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Top Podium Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF234466), Color(0xFF152A3F)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.gold, width: 1.5),
              ),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events_rounded, color: AppTheme.gold, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    loc.translate('Legal Scholar Tier: Senior Advocate', 'আইনি পদমর্যাদা: সিনিয়র অ্যাডভোকেট'),
                    style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${loc.translate('Your Total Score', 'আপনার মোট পয়েন্ট')}: $userXP XP',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              loc.translate('Weekly Study Group Ranking', 'সাপ্তাহিক র্যাঙ্কিং'),
              style: const TextStyle(color: AppTheme.goldLight, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),

            ...leaderboard.map((item) {
              final isUser = item['isUser'] == true;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isUser ? AppTheme.emeraldGreen : AppTheme.secondaryNavy,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUser ? AppTheme.gold : Colors.white10,
                    width: isUser ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '${item['badge']}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] as String,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: isUser ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13.5,
                            ),
                          ),
                          if (isUser)
                            Text(
                              loc.translate('Rank #3 in Bangladesh', 'বাংলাদেশে ৩য় স্থান'),
                              style: const TextStyle(color: AppTheme.goldLight, fontSize: 11),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '${item['xp']} XP',
                      style: TextStyle(
                        color: isUser ? AppTheme.goldLight : AppTheme.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // Badges Showcase
            Text(
              loc.translate('Achievement Badges', 'অর্জিত সম্মাননা ব্যাজ'),
              style: const TextStyle(color: AppTheme.goldLight, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.4,
              ),
              itemCount: EvidenceActData.availableBadges.length,
              itemBuilder: (context, idx) {
                final badge = EvidenceActData.availableBadges[idx];
                final isEarned = progress.progress.earnedBadgeIds.contains(badge.id);

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isEarned ? AppTheme.secondaryNavy : const Color(0xFF17283A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isEarned ? AppTheme.gold.withOpacity(0.6) : Colors.white10,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isEarned ? Icons.workspace_premium_rounded : Icons.lock_outline_rounded,
                        color: isEarned ? AppTheme.gold : AppTheme.mutedGrey,
                        size: 30,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        loc.isBengali ? badge.titleBn : badge.titleEn,
                        style: TextStyle(
                          color: isEarned ? Colors.white : AppTheme.mutedGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isEarned ? loc.translate('UNLOCKED', 'উন্মুক্ত') : loc.translate('LOCKED', 'লক করা'),
                        style: TextStyle(
                          color: isEarned ? AppTheme.successGreen : AppTheme.mutedGrey,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
