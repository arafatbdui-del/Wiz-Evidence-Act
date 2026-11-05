import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/models.dart';

/// Read-only legal content bundled in assets/data (works fully offline).
class Content {
  final List<GamingChapter> chapters;
  final List<LegalSection> sections;
  final List<Question> questions;
  final List<GameDef> games;
  final Map<String, BossBattle> bosses;
  final Map<String, LegalSection> _sec;
  final Map<String, GamingChapter> _ch;

  Content(this.chapters, this.sections, this.questions, this.games, this.bosses)
      : _sec = {for (final s in sections) s.sectionId: s},
        _ch = {for (final c in chapters) c.chapterId: c};

  LegalSection? section(String id) => _sec[id];
  GamingChapter? chapter(String id) => _ch[id];
  List<LegalSection> sectionsOf(GamingChapter c) => [for (final id in c.sectionIds) if (_sec[id] != null) _sec[id]!];
  List<LegalSection> relatedSectionsOf(GamingChapter c) => [for (final id in c.relatedSectionIds) if (_sec[id] != null) _sec[id]!];
  List<Question> questionsForSection(String sid) => questions.where((q) => q.sectionId == sid).toList();
  List<Question> questionsForChapter(String cid) => questions.where((q) => q.chapterId == cid).toList();
  List<GameDef> gamesForChapter(String cid) => games.where((g) => g.chapterId == cid).toList();
  List<GameDef> gamesForSection(String sid) => games.where((g) => g.sectionId == sid).toList();

  /// Boss battle for a chapter: authored if present, otherwise built from the chapter's
  /// question pool when it has at least 3 questions, otherwise null (chapter then completes
  /// when all its sections are complete).
  BossBattle? bossFor(GamingChapter c) {
    final b = bosses[c.chapterId];
    if (b != null) return b;
    final pool = questionsForChapter(c.chapterId);
    if (pool.length < 3) return null;
    return BossBattle.fromJson({
      'chapterId': c.chapterId,
      'title': 'Boss battle: ${c.chapterName}',
      'scenario': 'Final challenge for this chapter. Answer questions drawn from the sections you studied.',
      'passPercent': 60,
      'xpReward': 30,
      'questions': [
        for (final q in pool.take(5))
          {'sectionRef': 's.${section(q.sectionId)?.sectionNumber ?? ''}', 'question': q.questionTextEnglish,
           'options': q.optionsEnglish, 'answer': q.correctAnswer, 'explanation': q.explanationEnglish ?? ''}
      ],
    });
  }

  static Future<Content> load() async {
    Future<List> list(String f) async => jsonDecode(await rootBundle.loadString('assets/data/$f')) as List;
    final ch = (await list('chapters.json')).map((e) => GamingChapter.fromJson(Map<String, dynamic>.from(e))).toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    final se = (await list('sections.json')).map((e) => LegalSection.fromJson(Map<String, dynamic>.from(e))).toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    final qs = (await list('questions.json')).map((e) => Question.fromJson(Map<String, dynamic>.from(e))).toList();
    final gs = (await list('games.json')).map((e) => GameDef.fromJson(Map<String, dynamic>.from(e))).toList();
    final bj = jsonDecode(await rootBundle.loadString('assets/data/bosses.json')) as Map<String, dynamic>;
    final bs = {for (final e in bj.entries) e.key: BossBattle.fromJson(Map<String, dynamic>.from(e.value as Map))};
    return Content(ch, se, qs, gs, bs);
  }
}
