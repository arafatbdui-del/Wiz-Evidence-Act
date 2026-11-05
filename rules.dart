/// Tunable gamification rules (single place to configure XP).
class Rules {
  static const lessonXp = 10;
  static const gameXp = 15;
  static const dailyChallengeXp = 25;
  static const quizPassPercent = 60;
  static const xpPerLevel = 250;
  static int levelFor(int xp) => xp ~/ xpPerLevel + 1;
  static int xpIntoLevel(int xp) => xp % xpPerLevel;
}
