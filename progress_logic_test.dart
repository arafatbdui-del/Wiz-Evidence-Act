import 'package:flutter_test/flutter_test.dart';
import 'package:evidence_act_bd/data/content_repository.dart';
import 'package:evidence_act_bd/data/progress_store.dart';
import 'package:evidence_act_bd/providers/progress_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Content content;
  setUpAll(() async => content = await Content.load());

  ProgressNotifier make({DateTime Function()? clock}) =>
      ProgressNotifier(content, MemoryProgressStore(), clock: clock);

  test('content loads: 11 chapters, every section assigned exactly once', () {
    expect(content.chapters.length, 11);
    final ids = content.chapters.expand((c) => c.sectionIds).toList();
    expect(ids.length, content.sections.length);
    expect(ids.toSet().length, ids.length);
  });

  test('chapter 1 unlocked, chapter 2 locked at start', () {
    final n = make();
    expect(n.isUnlocked(content.chapters[0]), true);
    expect(n.isUnlocked(content.chapters[1]), false);
  });

  test('lesson XP is paid once only', () {
    final n = make();
    final sid = content.chapters[0].sectionIds.first;
    expect(n.markLessonRead(sid).xp, 10);
    expect(n.markLessonRead(sid).xp, 0);
    expect(n.state.totalXP, 10);
  });

  test('question XP is paid once per question; mistakes are tracked and cleared', () {
    final n = make();
    final q = content.questions.first;
    n.recordQuiz([AnswerResult(q.questionId, false)]);
    expect(n.state.incorrectQuestions.contains(q.questionId), true);
    final r1 = n.recordQuiz([AnswerResult(q.questionId, true)]);
    expect(r1.xp, q.xpReward);
    expect(n.state.incorrectQuestions.contains(q.questionId), false);
    final r2 = n.recordQuiz([AnswerResult(q.questionId, true)]);
    expect(r2.xp, 0);
  });

  test('finishing every section of chapter 1 completes it and unlocks chapter 2', () {
    final n = make();
    final ch1 = content.chapters[0];
    for (final sid in ch1.sectionIds) {
      n.markLessonRead(sid);
      final qs = content.questionsForSection(sid);
      if (qs.isNotEmpty) {
        n.recordQuiz([for (final q in qs) AnswerResult(q.questionId, true)], sectionId: sid);
      }
    }
    // chapter 1 has no boss pool (<3 questions), so it completes with its sections
    expect(content.bossFor(ch1), isNull);
    expect(n.isChapterCompleted(ch1.chapterId), true);
    expect(n.isUnlocked(content.chapters[1]), true);
    expect(n.state.totalXP >= ch1.bonusXP, true);
  });

  test('boss battle: pass pays once; fail does not complete', () {
    final n = make();
    final ch2 = content.chapters[1];
    for (final sid in ch2.sectionIds) {
      n.markLessonRead(sid);
      final qs = content.questionsForSection(sid);
      if (qs.isNotEmpty) n.recordQuiz([for (final q in qs) AnswerResult(q.questionId, true)], sectionId: sid);
    }
    expect(n.bossAvailable(ch2), true);
    expect(n.recordBoss(ch2.chapterId, 0, 3).passed, false);
    expect(n.isChapterCompleted(ch2.chapterId), false);
    final win = n.recordBoss(ch2.chapterId, 3, 3);
    expect(win.passed, true);
    expect(n.isChapterCompleted(ch2.chapterId), true);
    expect(n.recordBoss(ch2.chapterId, 3, 3).xp, 0);
  });

  test('streak increments on consecutive days and resets after a gap', () {
    var now = DateTime(2026, 11, 5, 10);
    final n = make(clock: () => now);
    final sid = content.sections.first.sectionId;
    n.markLessonRead(sid);
    expect(n.state.currentStreak, 1);
    now = DateTime(2026, 11, 6, 10);
    n.markLessonRead(content.sections[1].sectionId);
    expect(n.state.currentStreak, 2);
    now = DateTime(2026, 11, 9, 10);
    n.markLessonRead(content.sections[2].sectionId);
    expect(n.state.currentStreak, 1);
  });

  test('daily challenge pays once per local date', () {
    var now = DateTime(2026, 11, 5, 10);
    final n = make(clock: () => now);
    expect(n.completeDaily(3, 3).xp, 25);
    expect(n.completeDaily(3, 3).xp, 0);
    expect(n.dailyDone, true);
    now = DateTime(2026, 11, 6, 9);
    expect(n.dailyDone, false);
  });

  test('reset clears progress but keeps language', () {
    final n = make();
    n.setLanguage('bn');
    n.markLessonRead(content.sections.first.sectionId);
    n.resetAll();
    expect(n.state.totalXP, 0);
    expect(n.state.language, 'bn');
  });
}
