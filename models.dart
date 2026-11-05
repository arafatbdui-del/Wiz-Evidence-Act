import 'dart:convert';

List<String> _strs(dynamic v) => v == null ? <String>[] : List<String>.from(v as List);

class GamingChapter {
  final String chapterId, chapterName, chapterNameBangla, description, icon;
  final int chapterNumber, displayOrder, bonusXP;
  final String? prerequisiteChapterId;
  final List<String> sectionIds, relatedSectionIds;
  GamingChapter.fromJson(Map<String, dynamic> j)
      : chapterId = j['chapterId'],
        chapterName = j['chapterName'],
        chapterNameBangla = j['chapterNameBangla'] ?? j['chapterName'],
        description = j['description'] ?? '',
        icon = j['icon'] ?? '',
        chapterNumber = j['chapterNumber'],
        displayOrder = j['displayOrder'],
        bonusXP = j['bonusXP'],
        prerequisiteChapterId = j['prerequisiteChapterId'],
        sectionIds = _strs(j['sectionIds']),
        relatedSectionIds = _strs(j['relatedSectionIds']);
  String name(bool bn) => bn ? chapterNameBangla : chapterName;
}

class LegalSection {
  final String sectionId, sectionNumber, primaryChapterId, originalText, contentStatus, sourceReference;
  final String statutoryChapter, statutoryChapterTitle, statutoryPart;
  final String? sectionTitle, banglaTranslation, englishExplanation, banglaExplanation, practicalExample;
  final List<String> relatedChapterIds, reviewFlags;
  final int displayOrder;
  LegalSection.fromJson(Map<String, dynamic> j)
      : sectionId = j['sectionId'],
        sectionNumber = j['sectionNumber'],
        primaryChapterId = j['primaryChapterId'],
        originalText = j['originalText'] ?? '',
        contentStatus = j['contentStatus'] ?? '',
        sourceReference = j['sourceReference'] ?? '',
        statutoryChapter = j['statutoryChapter'] ?? '',
        statutoryChapterTitle = j['statutoryChapterTitle'] ?? '',
        statutoryPart = j['statutoryPart'] ?? '',
        sectionTitle = j['sectionTitle'],
        banglaTranslation = j['banglaTranslation'],
        englishExplanation = j['englishExplanation'],
        banglaExplanation = j['banglaExplanation'],
        practicalExample = j['practicalExample'],
        relatedChapterIds = _strs(j['relatedChapterIds']),
        reviewFlags = _strs(j['reviewFlags']),
        displayOrder = j['displayOrder'];

  /// Title shown in lists. Official marginal headings are not yet verified, so when
  /// no reviewed title exists we show a snippet of the statutory text instead.
  String get displayTitle {
    if (sectionTitle != null && sectionTitle!.isNotEmpty) return sectionTitle!;
    var t = originalText.replaceFirst(RegExp(r'^\[?\s*\d+[A-Z]*\.\s*'), '').replaceAll(RegExp(r'\s+'), ' ');
    if (t.length > 70) t = '${t.substring(0, 70).trim()}…';
    return t;
  }
}

class Question {
  final String questionId, sectionId, chapterId, questionTextEnglish, difficulty;
  final String? questionTextBangla, explanationEnglish, explanationBangla;
  final List<String> optionsEnglish;
  final List<String>? optionsBangla;
  final int correctAnswer, xpReward;
  Question.fromJson(Map<String, dynamic> j)
      : questionId = j['questionId'],
        sectionId = j['sectionId'],
        chapterId = j['chapterId'],
        questionTextEnglish = j['questionTextEnglish'],
        questionTextBangla = j['questionTextBangla'],
        optionsEnglish = _strs(j['optionsEnglish']),
        optionsBangla = j['optionsBangla'] == null ? null : _strs(j['optionsBangla']),
        correctAnswer = j['correctAnswer'],
        explanationEnglish = j['explanationEnglish'],
        explanationBangla = j['explanationBangla'],
        difficulty = j['difficulty'] ?? 'easy',
        xpReward = j['xpReward'] ?? 5;
  bool hasBangla(bool bn) => bn && questionTextBangla != null && optionsBangla != null;
  String text(bool bn) => hasBangla(bn) ? questionTextBangla! : questionTextEnglish;
  List<String> options(bool bn) => hasBangla(bn) ? optionsBangla! : optionsEnglish;
  String? explanation(bool bn) => (bn && explanationBangla != null) ? explanationBangla : explanationEnglish;
}

class GameDef {
  final String gameId, chapterId, sectionId, gameType, title, instructions;
  final Map<String, dynamic> content;
  final int xpReward;
  GameDef.fromJson(Map<String, dynamic> j)
      : gameId = j['gameId'],
        chapterId = j['chapterId'],
        sectionId = j['sectionId'],
        gameType = j['gameType'],
        title = j['title'],
        instructions = j['instructions'] ?? '',
        content = Map<String, dynamic>.from(j['content'] as Map),
        xpReward = j['xpReward'] ?? 15;
}

class BossQuestion {
  final String sectionRef, question, explanation;
  final List<String> options;
  final int answer;
  BossQuestion.fromJson(Map<String, dynamic> j)
      : sectionRef = j['sectionRef'] ?? '',
        question = j['question'],
        explanation = j['explanation'] ?? '',
        options = _strs(j['options']),
        answer = j['answer'];
}

class BossBattle {
  final String chapterId, title, scenario;
  final int passPercent, xpReward;
  final List<BossQuestion> questions;
  BossBattle.fromJson(Map<String, dynamic> j)
      : chapterId = j['chapterId'],
        title = j['title'],
        scenario = j['scenario'],
        passPercent = j['passPercent'] ?? 60,
        xpReward = j['xpReward'] ?? 40,
        questions = (j['questions'] as List).map((e) => BossQuestion.fromJson(Map<String, dynamic>.from(e))).toList();
}

class UserProgress {
  int totalXP = 0, currentStreak = 0;
  String? lastActiveDate, dailyChallengeDate;
  String language = 'en';
  Set<String> lessonsRead = {}, quizzesPassed = {}, completedSections = {}, completedChapters = {};
  Set<String> bossesPassed = {}, bookmarkedSections = {}, incorrectQuestions = {};
  Set<String> awardedQuestions = {}, gamesDone = {}, earnedBadges = {};
  List<String> notifications = [];

  UserProgress();
  Map<String, dynamic> toJson() => {
        'totalXP': totalXP, 'currentStreak': currentStreak, 'lastActiveDate': lastActiveDate,
        'dailyChallengeDate': dailyChallengeDate, 'language': language,
        'lessonsRead': lessonsRead.toList(), 'quizzesPassed': quizzesPassed.toList(),
        'completedSections': completedSections.toList(), 'completedChapters': completedChapters.toList(),
        'bossesPassed': bossesPassed.toList(), 'bookmarkedSections': bookmarkedSections.toList(),
        'incorrectQuestions': incorrectQuestions.toList(), 'awardedQuestions': awardedQuestions.toList(),
        'gamesDone': gamesDone.toList(), 'earnedBadges': earnedBadges.toList(), 'notifications': notifications,
      };
  UserProgress.fromJson(Map<String, dynamic> j) {
    Set<String> s(String k) => Set<String>.from((j[k] ?? const []) as List);
    totalXP = j['totalXP'] ?? 0;
    currentStreak = j['currentStreak'] ?? 0;
    lastActiveDate = j['lastActiveDate'];
    dailyChallengeDate = j['dailyChallengeDate'];
    language = j['language'] ?? 'en';
    lessonsRead = s('lessonsRead'); quizzesPassed = s('quizzesPassed');
    completedSections = s('completedSections'); completedChapters = s('completedChapters');
    bossesPassed = s('bossesPassed'); bookmarkedSections = s('bookmarkedSections');
    incorrectQuestions = s('incorrectQuestions'); awardedQuestions = s('awardedQuestions');
    gamesDone = s('gamesDone'); earnedBadges = s('earnedBadges');
    notifications = List<String>.from((j['notifications'] ?? const []) as List);
  }
  UserProgress clone() => UserProgress.fromJson(jsonDecode(jsonEncode(toJson())) as Map<String, dynamic>);
}
