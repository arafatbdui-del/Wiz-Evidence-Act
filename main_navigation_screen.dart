import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import 'home_screen.dart';
import 'learn_screen.dart';
import 'practice_hub_screen.dart';
import 'ranks_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final LocalizationService _loc = LocalizationService();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loc.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    _loc.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(onSwitchTab: _switchTab),
      const LearnScreen(),
      const PracticeHubScreen(),
      const RanksScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1E2E),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (idx) => setState(() => _currentIndex = idx),
          backgroundColor: const Color(0xFF0F1E2E),
          selectedItemColor: AppTheme.gold,
          unselectedItemColor: AppTheme.mutedGrey,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: [
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.home_rounded),
                  if (_currentIndex == 0)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 18,
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: AppTheme.gold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
              label: _loc.tabHome,
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.menu_book_rounded),
                  if (_currentIndex == 1)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 18,
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: AppTheme.gold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
              label: _loc.tabLearn,
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sports_esports_rounded),
                  if (_currentIndex == 2)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 18,
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: AppTheme.gold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
              label: _loc.tabPractice,
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events_rounded),
                  if (_currentIndex == 3)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 18,
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: AppTheme.gold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
              label: _loc.tabRanks,
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_rounded),
                  if (_currentIndex == 4)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 18,
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: AppTheme.gold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
              label: _loc.tabProfile,
            ),
          ],
        ),
      ),
    );
  }
}
