import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/rules.dart';
import '../data/content_repository.dart';
import '../data/progress_store.dart';
import '../models/models.dart';

class Reward {
  final int xp, correct, total;
  final bool passed;
  final List<String> messages;
  const Reward({this.xp = 0, this.correct = 0, this.total = 0, this.passed = false, this.messages = const []});
}

class AnswerResult {
  final String questionId;
  final bool correct;
  const AnswerResult(this.questionId, this.correct);
}

const badgeTitles = <String, String>{
  'first_quiz': 'First Quiz Completed',
  'streak_3': '3-Day Streak',
  'streak_7': '7-Day Streak',
  'xp_500': '500 XP Club',
  'evidence_master': 'The Evidence Master',
};

/// All gamification + progression rules live here (pure Dart, unit-testable).
class ProgressNotifier extends StateNotifier<UserProgress> {
  final Content content;
  final ProgressStore store;
  final DateTime Function() _now;

  ProgressNotifier(this.content, this.store, {DateTime Function()? clock})
      : _now = clock ?? DateTime.now,
        super(store.load());

  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String get today => dateKey(_now());

  // ---------- queries ----------
  bool isChapterCompleted(String id) => state.completedChapters.contains(id);
  bool isUnlocked(GamingChapter c) =>
      c.prerequisiteChapterId == null || state.completedChapters.contains(c.prerequisiteChapterId);
  bool isSectionDone(String sid) => state.completedSections.contains(sid);
  ({int done, int total}) chapterProgress(GamingChapter c) =>
      (done: c.sectionIds.where(state.completedSections.contains).length, total: c.sectionIds.length);
  bool allSectionsDone(GamingChapter c) => c.sectionIds.every(state.completedSections.contains);
  bool bossAvailable(GamingChapter c) =>
      allSectionsDone(c) && content.bossFor(c) != null && !state.bossesPassed.contains(c.chapterId);
  GamingChapter? get currentChapter {
    for (final c in content.chapters) {
      if (isUnlocked(c) && !isChapterCompleted(c.chapterId)) return c;
    }
    return content.chapters.isEmpty ? null : content.chapters.last;
  }

  int get level => Rules.levelFor(state.totalXP);
  double get courseFraction =>
      content.chapters.isEmpty ? 0 : state.completedChapters.length / content.chapters.length;

  // ---------- internal helpers ----------
  void _commit(UserProgress p) {
    state = p;
    store.save(p);
  }

  void _note(UserProgress p, String m) {
    p.notifications.insert(0, m);
    if (p.notifications.length > 50) p.notifications.removeLast();
  }

  void _touchStreak(UserProgress p) {
    final t = today;
    if (p.lastActiveDate == t) return;
    final y = dateKey(_now().subtract(const Duration(days: 1)));
    p.currentStreak = p.lastActiveDate == y ? p.currentStreak + 1 : 1;
    p.lastActiveDate = t;
    if (p.currentStreak >= 3) _badge(p, 'streak_3');
    if (p.currentStreak >= 7) _badge(p, 'streak_7');
  }

  void _badge(UserProgress p, String id) {
    if (p.earnedBadges.add(id)) _note(p, 'Badge earned: ${badgeTitles[id] ?? id}');
  }

  int _xp(UserProgress p, int n) {
    if (n <= 0) return 0;
    final before = Rules.levelFor(p.totalXP);
    p.totalXP += n;
    final after = Rules.levelFor(p.totalXP);
    if (after > before) _note(p, 'Level up! You reached level $after');
    if (p.totalXP >= 500) _badge(p, 'xp_500');
    return n;
  }

  void _refreshSection(UserProgress p, String sid) {
    final hasQ = content.questionsForSection(sid).isNotEmpty;
    if (p.lessonsRead.contains(sid) && (!hasQ || p.quizzesPassed.contains(sid))) p.completedSections.add(sid);
    final sec = content.section(sid);
    final ch = sec == null ? null : content.chapter(sec.primaryChapterId);
    if (ch != null) _refreshChapter(p, ch);
  }

  int _refreshChapter(UserProgress p, GamingChapter c) {
    if (p.completedChapters.contains(c.chapterId)) return 0;
    if (!c.sectionIds.every(p.completedSections.contains)) return 0;
    if (content.bossFor(c) != null && !p.bossesPassed.contains(c.chapterId)) return 0;
    p.completedChapters.add(c.chapterId);
    _note(p, 'Chapter completed: ${c.chapterName}');
    final n = _xp(p, c.bonusXP);
    if (p.completedChapters.length == content.chapters.length) _badge(p, 'evidence_master');
    return n;
  }

  // ---------- actions ----------
  void setLanguage(String lang) {
    final p = state.clone()..language = lang;
    _commit(p);
  }

  void toggleBookmark(String sid) {
    final p = state.clone();
    if (!p.bookmarkedSections.remove(sid)) p.bookmarkedSections.add(sid);
    _commit(p);
  }

  /// Marks a lesson as read. XP only on first read.
  Reward markLessonRead(String sid) {
    final p = state.clone();
    _touchStreak(p);
    var xp = 0;
    if (p.lessonsRead.add(sid)) xp += _xp(p, Rules.lessonXp);
    _refreshSection(p, sid);
    _commit(p);
    return Reward(xp: xp);
  }

  /// Records MCQ results. XP is paid once per question (first correct answer only).
  /// If [sectionId] is given and the score is >= pass mark, the section quiz counts as passed.
  Reward recordQuiz(List<AnswerResult> answers, {String? sectionId}) {
    final p = state.clone();
    _touchStreak(p);
    var xp = 0, correct = 0;
    for (final a in answers) {
      final q = content.questions.firstWhere((q) => q.questionId == a.questionId);
      if (a.correct) {
        correct++;
        p.incorrectQuestions.remove(a.questionId);
        if (p.awardedQuestions.add(a.questionId)) xp += _xp(p, q.xpReward);
      } else {
        p.incorrectQuestions.add(a.questionId);
      }
    }
    final pct = answers.isEmpty ? 0 : (correct * 100 / answers.length).round();
    final passed = pct >= Rules.quizPassPercent;
    if (answers.isNotEmpty) _badge(p, 'first_quiz');
    if (sectionId != null && passed) {
      p.quizzesPassed.add(sectionId);
      _refreshSection(p, sectionId);
    }
    _commit(p);
    return Reward(xp: xp, correct: correct, total: answers.length, passed: passed);
  }

  /// Boss battle result. First pass pays the boss XP + chapter bonus; replays pay nothing.
  Reward recordBoss(String chapterId, int correct, int total) {
    final c = content.chapter(chapterId)!;
    final boss = content.bossFor(c);
    final pass = boss?.passPercent ?? Rules.quizPassPercent;
    final pct = total == 0 ? 0 : (correct * 100 / total).round();
    final passed = pct >= pass;
    final p = state.clone();
    _touchStreak(p);
    var xp = 0;
    final msgs = <String>[];
    if (passed && p.bossesPassed.add(chapterId)) {
      xp += _xp(p, boss?.xpReward ?? 0);
      final bonus = _refreshChapter(p, c);
      xp += bonus;
      if (bonus > 0) msgs.add('Chapter complete! +$bonus bonus XP');
    }
    _commit(p);
    return Reward(xp: xp, correct: correct, total: total, passed: passed, messages: msgs);
  }

  Reward recordGame(GameDef g, int correct, int total) {
    final p = state.clone();
    _touchStreak(p);
    var xp = 0;
    final pct = total == 0 ? 0 : (correct * 100 / total).round();
    final passed = pct >= Rules.quizPassPercent;
    if (passed && p.gamesDone.add(g.gameId)) xp += _xp(p, g.xpReward);
    _commit(p);
    return Reward(xp: xp, correct: correct, total: total, passed: passed);
  }

  bool get dailyDone => state.dailyChallengeDate == today;

  /// Deterministic daily challenge: 3 questions chosen by calendar day (same all day, offline).
  List<Question> dailyQuestions() {
    final qs = [...content.questions]..sort((a, b) => a.questionId.compareTo(b.questionId));
    if (qs.isEmpty) return [];
    final d = _now();
    final dayNum = DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/ 86400000;
    return [for (var i = 0; i < 3 && i < qs.length; i++) qs[(dayNum * 3 + i) % qs.length]];
  }

  Reward completeDaily(int correct, int total) {
    final p = state.clone();
    _touchStreak(p);
    var xp = 0;
    if (p.dailyChallengeDate != today) {
      p.dailyChallengeDate = today;
      xp += _xp(p, Rules.dailyChallengeXp);
      _note(p, 'Daily challenge complete (+${Rules.dailyChallengeXp} XP)');
    }
    _commit(p);
    return Reward(xp: xp, correct: correct, total: total, passed: true);
  }

  void resetAll() {
    final lang = state.language;
    _commit(UserProgress()..language = lang);
  }
}
