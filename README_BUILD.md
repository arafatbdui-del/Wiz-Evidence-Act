# Evidence Act BD - integration & build guide

## What this package is
`lib/`, `assets/`, `test/`, `pubspec.yaml`, `codemagic.yaml` for the Flutter app. It does **not** include `android/`
(your existing project has it). Nothing here has been compiled or run yet - see "Not yet verified".

## Merge into your existing project (package `com.example.evidence_act_bd`, v0.1.0, minSdk 24)
1. Back up your project. Replace its `lib/`, `assets/`, `test/` and `pubspec.yaml` with these (keep your `android/`, `ios/`).
   Your old `assets/data/legal_content.json` is superseded; its 7 sections / 5 questions were migrated into the new files.
2. `flutter pub get` -> `dart format .` -> `flutter analyze` -> `flutter test`.
3. Set the launcher label in `android/app/src/main/AndroidManifest.xml`: `android:label="Evidence Act BD"`
   (the current APK shows `evidence_act_bd`).
4. Before any Play Store release change the `com.example.*` application id and add a real signing key.
5. Fonts (offline Bangla): add Manrope and Noto Sans Bengali `.ttf` files in `assets/fonts/`, declare them under `flutter: fonts:` in
   `pubspec.yaml`, and set `fontFamily` in `lib/core/theme.dart`. Until then the app relies on the device's fonts.
6. Launcher icon / splash: add `flutter_launcher_icons` and `flutter_native_splash` (not added to avoid unverified config).
7. Build: `flutter build apk --release` -> `build/app/outputs/flutter-apk/app-release.apk`, or push to Git and run Codemagic (`codemagic.yaml`).

## Regenerating content from the PDFs
```
python3 tools/parse_act.py Evidence_Act_Bangladesh.pdf /tmp/act_sections.json
python3 tools/build_content.py /tmp/act_sections.json <old legal_content.json> assets/data docs
```
Chapter mapping lives in `primary()` / `RELATED` in `tools/build_content.py`; coverage output: `docs/COVERAGE_REPORT.md`.

## Data schema (assets/data)
* `chapters.json`: chapterId, chapterNumber, chapterName, chapterNameBangla, description, icon, displayOrder, bonusXP, prerequisiteChapterId, sectionIds (primary), relatedSectionIds (cross-refs).
* `sections.json`: sectionId, sectionNumber, primaryChapterId, relatedChapterIds, statutoryPart/Chapter/ChapterTitle, sectionTitle (null until verified),
  originalText (from PDF), banglaTranslation, englishExplanation, banglaExplanation, practicalExample (null until written), sourceReference, contentStatus, reviewFlags.
* `questions.json`: questionId, sectionId, chapterId, questionTextEnglish/Bangla, optionsEnglish/Bangla, correctAnswer (index), explanationEnglish/Bangla, difficulty, xpReward.
* `games.json`: gameId, chapterId, sectionId, gameType (true_false|match|fill_blank|identify_section|case|flashcard|quick_mcq), title, instructions, content, xpReward.
* `bosses.json`: map chapterId -> {title, scenario, passPercent, xpReward, questions[{sectionRef, question, options, answer, explanation}]}.
Add a Bangla field and the app uses it automatically; missing Bangla falls back to English with an "EN" tag.

## XP / progression rules (lib/core/rules.dart, lib/providers/progress_notifier.dart)
Lesson +10 once; each question pays its XP once (first correct answer); games +XP once (>=60%); daily challenge +25 once per date; chapter bonus on completion.
Section complete = lesson read AND (if it has questions) quiz passed (>=60%). Chapter complete = all sections complete AND boss passed
(boss = authored, else built from >=3 chapter questions, else none -> completes with its sections). Next chapter unlocks when the previous is complete.

## Not yet verified (be honest with yourself before shipping)
* No Flutter/Android SDK was available where this was written: **no `pub get`, format, analyze, test, screenshot or APK build was run.** Expect a few compile fixes.
* Home screen is built to match the reference but has not been visually compared; the courthouse background photo is not included (gradient instead).
* Read-aloud/audio is not implemented. Local leaderboard is a labelled demo.
* Bangla translations/explanations exist only for the 7 migrated starter sections; Bangla UI labels and chapter names are my drafts for you to review.
* 175 of 182 sections have original text only (no explanations/questions). Section titles are unverified (see reviewFlags).
