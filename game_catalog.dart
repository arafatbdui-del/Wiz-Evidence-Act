import '../../data/content_repository.dart';
import '../../models/models.dart';

/// Authored games for a chapter plus auto-generated ones built from real content
/// (flashcards from the statutory text, quick MCQ from the question pool).
List<GameDef> gamesFor(Content c, GamingChapter ch) {
  final list = [...c.gamesForChapter(ch.chapterId)];
  final secs = c.sectionsOf(ch).where((s) => s.originalText.length > 20).take(8).toList();
  if (secs.length >= 2) {
    list.add(GameDef.fromJson({
      'gameId': 'auto_flash_${ch.chapterId}', 'chapterId': ch.chapterId, 'sectionId': secs.first.sectionId,
      'gameType': 'flashcard', 'title': 'Flashcard Challenge',
      'instructions': 'Flip each card. Try to recall the provision, then check the Act\'s own text.', 'xpReward': 10,
      'content': {'items': [for (final s in secs) {'front': 'Section ${s.sectionNumber}', 'back': _snip(s.originalText)}]},
    }));
  }
  final qs = c.questionsForChapter(ch.chapterId);
  if (qs.length >= 2) {
    list.add(GameDef.fromJson({
      'gameId': 'auto_quick_${ch.chapterId}', 'chapterId': ch.chapterId, 'sectionId': qs.first.sectionId,
      'gameType': 'quick_mcq', 'title': 'Quick MCQ Challenge', 'instructions': 'Answer fast. Questions come from this chapter.',
      'xpReward': 10, 'content': {'questionIds': [for (final q in qs) q.questionId]},
    }));
  }
  return list;
}

String _snip(String t) => t.length <= 260 ? t : '${t.substring(0, 260).trim()}…';

String gameTypeLabel(String t) => const {
      'true_false': 'True or False', 'match': 'Match the Legal Term', 'flashcard': 'Flashcard Challenge',
      'fill_blank': 'Fill in the Missing Word', 'identify_section': 'Identify the Relevant Section',
      'case': 'Case Scenario Challenge', 'quick_mcq': 'Quick MCQ Challenge',
    }[t] ?? t;
