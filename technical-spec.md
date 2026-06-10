# Kids Vocabulary Practice App — Cursor Build Spec

## 1. Product Summary

Create a **simple Flutter mobile app** for kids on **both Android and iOS**. The app will use hardcoded word sets and **on-device storage only**. All profiles, progress, and settings live on the phone or tablet itself — nothing is sent to a server.

There will be no backend, no remote database, no ads, no login, no email verification, and no internet requirement after installation.

The app supports **multiple local user profiles** on the same device so siblings or classmates can each track progress independently. These are device-local profiles only — not accounts, not synced, and not protected by passwords.

The app helps children practice vocabulary through:

1. Local profile selection and creation.
2. Word review with read-aloud support.
3. Definition-to-word multiple choice quiz.
4. Drag-and-drop spelling practice.
5. Typed-answer spelling/recall practice.
6. Word set selection.
7. Local progress tracking per profile and per word set.

The initial version should prioritize simplicity, readability, kid-friendly UI, and easy future editing of hardcoded vocabulary data.

A UI mockup defines the visual direction for practice screens. The spec keeps the full app flow (profiles → word sets → practice). The mockup’s **mode-selection home** maps to the **Set Dashboard** after a word set is chosen.

### Terminology

- **Local profile**: a named learner on this device, such as `Alex` or `Mia`. Stored locally only.
- **Not a user account**: no signup, login, email, password, cloud identity, or sync.
- **Hardcoded vocabulary**: word sets live in Dart source files and ship with the app.
- **Local progress**: practice state saved on the device with `shared_preferences`.
- **On-device storage**: when this spec says "database" or "saved locally," it means data persisted on the device only. v1 does **not** use SQLite, Hive, or any database package — only `shared_preferences`.
- **Words mastered**: kid-facing visual label for words that are complete for this app. In v1, this means the child has reviewed the word, answered it correctly in Quiz once, and spelled it correctly in Spell It once. It is a progress marker, not a formal guarantee of long-term retention.
- **Set Dashboard**: the practice hub for one selected word set — matches the mockup screen with four large mode buttons.

---

## 2. Core Constraints

### Must Have

- Simple Flutter app targeting **Android and iOS** from one codebase.
- Mobile-first UI that works on phones; tablet layouts are a nice-to-have, not required for v1.
- No backend.
- No external or remote database.
- No server-side storage of any kind.
- No ads.
- No login, signup, email verification, or password.
- No cloud accounts or authentication of any kind.
- Multiple **local profiles** on one device, each with independent progress.
- Vocabulary data is hardcoded in the app.
- Progress and profile data are stored **on the device only** using `shared_preferences`.
- Data must survive app restarts on both Android and iOS.
- Uninstalling the app removes all local data — there is no cloud backup in v1.
- App should support multiple word sets.
- User can switch between word sets.
- User can switch between local profiles.
- App tracks completion of each set separately for each profile.
- Text-to-speech/read-aloud is required for:
  - Word pronunciation.
  - Definition reading.
  - Multiple choice answer options.
  - Quiz prompt.
- App should be usable by kids who are still developing reading skills.

### Should Avoid

- Login screens, passwords, PINs, or email flows.
- Remote sync.
- Cloud storage.
- Analytics.
- External CMS.
- Monetization.
- Network dependency.
- Overly gamified mechanics that distract from learning.

---

## 3. Platform and Tech Assumptions

### Flutter — Android and iOS

This is a **simple Flutter app** with a **single shared codebase** for Android and iOS.

Rationale:

- Good fit for simple mobile apps.
- One implementation for both platforms.
- Easy on-device state persistence.
- Text-to-speech packages work on both platforms.
- Drag-and-drop UI is straightforward on touch devices.

### Platform Requirements

- **v1 targets both Android and iOS.**
- Use Flutter SDK widgets and packages that support both platforms.
- Do not write separate Android-only or iOS-only app logic unless a platform API truly requires it.
- Platform-specific code, if any, must be isolated in thin service wrappers — not spread through UI screens.
- Test core flows on both Android and iOS before considering v1 complete.

### On-Device Storage Only

All persisted data stays on the device:

| Data | Storage | Notes |
|------|---------|-------|
| Vocabulary word sets | Hardcoded in Dart | Shipped with the app binary |
| Local profiles | `shared_preferences` | Name, emoji, created date |
| Per-profile progress | `shared_preferences` | JSON blob per profile |
| App settings | `shared_preferences` | TTS speed, auto-read toggles |

There is no database server, no sync service, and no network call to load or save user data.

Suggested Flutter packages:

```yaml
dependencies:
  flutter:
    sdk: flutter

  flutter_tts: ^4.0.0
  shared_preferences: ^2.2.3
  collection: ^1.18.0
```

Optional later:

```yaml
dependencies:
  confetti: ^0.7.0
  google_fonts: ^6.2.1
```

Do not add Firebase, Supabase, SQLite, Hive, Drift, Realm, or any remote service unless explicitly requested later.

Local persistence for v1 is limited to `shared_preferences` for:

- Local user profiles.
- Per-profile progress.
- App settings.

---

## 4. Primary User Types

### Child User

The child uses the app to review, hear, quiz, spell, and type vocabulary words under a local profile.

Needs:

- Big buttons.
- Simple navigation.
- Read-aloud support.
- Immediate feedback.
- Clear progress indicators.
- Low-friction retry.
- Pick or create a profile with a name only — no signup.

### Parent/Teacher User

The parent/teacher manages local profiles on the device and edits hardcoded word sets in the source code.

Needs:

- Create, rename, switch, and delete local profiles.
- Reset progress for one profile, one set, or all data for the active profile.
- Easy-to-edit vocabulary data structure.
- Ability to add new word sets in code.
- Ability to group words by grade, theme, lesson, or difficulty.
- No content management system in v1.
- No login or parent account required.

---

## 5. Data Model

Vocabulary data should be stored in a hardcoded Dart file, for example:

```text
lib/data/vocabulary_sets.dart
```

### Word Set Model

Each word set represents a group of words the child can practice.

```dart
class VocabularySet {
  final String id;
  final String title;
  final String description;
  final String gradeLabel;
  final String theme;
  final List<VocabularyWord> words;

  const VocabularySet({
    required this.id,
    required this.title,
    required this.description,
    required this.gradeLabel,
    required this.theme,
    required this.words,
  });
}
```

Example:

```dart
const VocabularySet(
  id: 'grade2-core-001',
  title: 'Grade 2 Core Words - Set 1',
  description: 'Common words for early vocabulary practice.',
  gradeLabel: 'Grade 2',
  theme: 'Core Vocabulary',
  words: [
    VocabularyWord(
      id: 'brave',
      word: 'brave',
      definition: 'To show courage and face danger or pain without fear.',
      exampleSentence: 'The brave firefighter helped the family.',
      partOfSpeech: 'adjective',
      difficulty: WordDifficulty.easy,
    ),
  ],
)
```

### Vocabulary Word Model

```dart
class VocabularyWord {
  final String id;
  final String word;
  final String definition;
  final String exampleSentence;
  final String partOfSpeech;
  final WordDifficulty difficulty;

  const VocabularyWord({
    required this.id,
    required this.word,
    required this.definition,
    required this.exampleSentence,
    required this.partOfSpeech,
    required this.difficulty,
  });
}
```

### Word Difficulty Enum

```dart
enum WordDifficulty {
  easy,
  medium,
  hard,
}
```

### Local Profile Model

Each person using the app on the device gets a local profile. Profiles are not authenticated and exist only on the device.

```dart
class LocalProfile {
  final String id;
  final String displayName;
  final DateTime createdAt;
  final String? avatarEmoji;

  const LocalProfile({
    required this.id,
    required this.displayName,
    required this.createdAt,
    this.avatarEmoji,
  });
}
```

Profile rules:

- Display name is required.
- Display name can be any short label, such as `Alex`, `Mia`, or `Room 12`.
- No email, password, age gate, or verification.
- Profile IDs must be stable UUIDs or similarly unique strings — not list indexes.
- Deleting a profile deletes that profile's progress.
- Recommended limit: up to 10 profiles in v1 to keep the picker simple.

Suggested profile ID format:

```text
profile-{uuid}
```

Example:

```text
profile-7f3c2a91-4b2e-4d11-9c88-001122334455
```

### Local Progress Model

Progress should be stored locally using `shared_preferences`, scoped to the active profile.

Recommended local progress fields:

```dart
class WordProgress {
  final String wordId;
  final bool reviewed;
  final bool quizCorrect;
  final bool spellingCompleted;
  final bool typedCompleted;
  final int quizAttempts;
  final int quizCorrectCount;
  final int spellingAttempts;
  final int typedAttempts;
  final DateTime? lastPracticedAt;

  const WordProgress({
    required this.wordId,
    required this.reviewed,
    required this.quizCorrect,
    required this.spellingCompleted,
    required this.typedCompleted,
    required this.quizAttempts,
    required this.quizCorrectCount,
    required this.spellingAttempts,
    required this.typedAttempts,
    required this.lastPracticedAt,
  });
}
```

For v1, it is acceptable to store profiles and progress as JSON strings inside `shared_preferences`.

Suggested storage key:

```text
vocab_app_state_v1
```

App state can be represented as:

```json
{
  "activeProfileId": "profile-7f3c2a91-4b2e-4d11-9c88-001122334455",
  "profiles": [
    {
      "id": "profile-7f3c2a91-4b2e-4d11-9c88-001122334455",
      "displayName": "Alex",
      "createdAt": "2026-06-10T09:00:00.000Z",
      "avatarEmoji": "🦊"
    },
    {
      "id": "profile-b12d4e56-8a10-4f22-b7aa-998877665544",
      "displayName": "Mia",
      "createdAt": "2026-06-10T09:05:00.000Z",
      "avatarEmoji": "🐶"
    }
  ],
  "profileProgress": {
    "profile-7f3c2a91-4b2e-4d11-9c88-001122334455": {
      "selectedSetId": "grade2-core-001",
      "lastModeBySet": {
        "grade2-core-001": "quiz"
      },
      "sets": {
        "grade2-core-001": {
          "wordProgress": {
            "grade2-core-001-brave": {
              "reviewed": true,
              "quizCorrect": true,
              "spellingCompleted": false,
              "typedCompleted": false,
              "quizAttempts": 2,
              "quizCorrectCount": 1,
              "spellingAttempts": 0,
              "typedAttempts": 0,
              "lastPracticedAt": "2026-06-10T10:00:00.000Z"
            }
          }
        }
      }
    },
    "profile-b12d4e56-8a10-4f22-b7aa-998877665544": {
      "selectedSetId": "grade2-core-001",
      "sets": {}
    }
  },
  "settings": {
    "speechSpeed": "normal",
    "autoReadLearnWord": false,
    "autoReadQuizDefinition": false,
    "requireTypeItForCompletion": false
  }
}
```

Progress isolation rules:

- Switching profiles must not change another profile's progress.
- Reset actions apply only to the active profile unless explicitly labeled otherwise.
- App settings may be global for the device in v1.

---

## 6. Completion Rules

The app needs a simple and understandable definition of set completion.

### Repeatable Practice vs. Mastery

All practice modes remain repeatable forever. Marking a word as mastered must **not** lock the word, hide it, remove it from future sessions, or prevent the child from practicing it again.

In v1, **mastered** is a kid-facing progress label meaning the child has successfully completed the required activities for that word at least once. It helps the child know which words are done for now and which words need more practice.

Mastery controls:

- Progress visuals.
- Which words are prioritized first in practice sessions.
- Suggested next actions.

Mastery does **not** control:

- Whether a child can practice the word again.
- Whether the word appears in Word List.
- Whether the word can be included in review mode after the set is complete.

v1 does not implement formal spaced repetition, where the app automatically schedules words for review across future days. However, the app stores attempts and `lastPracticedAt` so a future version can add `Needs Review`, `Practice Again`, or spaced review features without changing the core data model.

### Recommended V1 Completion Logic

A word is considered complete when:

- It has been reviewed at least once.
- The child has answered it correctly in quiz mode at least once.
- The child has completed spelling mode at least once.

Typed-answer mode should be treated as optional/harder practice unless enabled for the set.

### Word Completion Formula

```text
wordComplete = reviewed && quizCorrect && spellingCompleted
```

If typed-answer mode is enabled for the set:

```text
wordComplete = reviewed && quizCorrect && spellingCompleted && typedCompleted
```

### Set Completion Formula

```text
setCompletionPercent = completedWords / totalWords
```

Show this as:

```text
12 / 20 words complete
60%
```

### Separate Skill Progress

Even if overall completion uses a simple formula, the UI should also show separate progress for:

- Reviewed
- Quiz
- Spelling
- Typed answer, if enabled

Example:

```text
Set Progress
Reviewed: 16 / 20
Quiz: 14 / 20
Spelling: 10 / 20
Words Mastered: 10 / 20
```

**Words Mastered** is the kid-facing label for overall complete words. This makes it easier for the child or parent to see which type of practice still needs work. The label should be used as a friendly progress marker, not as a formal assessment claim.

---

## 7. Main Screens

## 7.1 Profile Selection Screen

Purpose:

- Let the child or parent choose who is practicing.
- Create a new local profile when needed.

When to show:

- On first launch when no profiles exist, go directly to Create Profile.
- On later launches, show Profile Selection when 2 or more profiles exist.
- If exactly 1 profile exists, skip this screen and enter the app as that profile.
- Profile switching is always available from Set Selection and Settings.

Elements:

- App title: `Who is practicing?`
- Grid or list of profile cards.
- Each profile card shows:
  - Display name.
  - Optional emoji/avatar.
  - Optional short progress summary, such as `2 sets in progress`.
- `Add Profile` button.
- Optional `Edit Profiles` entry for rename/delete.

Create Profile flow:

- Single screen or dialog.
- Required field: display name.
- Optional field: emoji picker with a small preset list.
- No email, password, or verification step.
- On save, set the new profile as active and continue to Set Selection.

Edit Profile flow:

- Rename display name.
- Change emoji.
- Delete profile behind confirmation.

Delete confirmation copy:

```text
Delete Alex's profile?
This will erase Alex's local progress on this device.
```

Actions:

- Tapping a profile sets it active and opens Set Selection.
- Tapping Add Profile opens Create Profile.

---

## 7.2 Home / Set Selection Screen

Purpose:

- Let the active profile pick a word set.
- **Not shown in UI mockup** but required before the Set Dashboard. This is the app home after profile selection.
- Show progress for each set for the active profile only.
- Continue the most recent set for the active profile.
- Switch profiles.
- Reset progress if parent chooses.

Elements:

- App title: `Vocabulary Practice`
- Active profile indicator, such as `Practicing as: Alex 🦊`
- Switch Profile button.
- Continue button for selected/recent set.
- List/grid of word sets.
- Each word set card shows:
  - Set title.
  - Grade label.
  - Theme.
  - Number of words.
  - Completion percent.
  - Progress bar.
  - Status:
    - Not Started
    - In Progress
    - Complete
- Settings button.
- Optional parent reset progress button hidden behind a confirmation dialog.

Example card:

```text
Grade 2 Core Words - Set 1
Core Vocabulary
12 / 20 complete
[==========------] 60%
```

Actions:

- Tapping a set opens the Set Dashboard screen.
- Tapping Continue opens the last active mode for the selected set or the Set Dashboard.
- Tapping Switch Profile opens Profile Selection.

---

## 7.3 Set Dashboard Screen

Purpose:

- Show one selected word set and all practice modes.
- This screen corresponds to the **mockup “Vocabulary Practice” home** with four large mode buttons.

Elements:

- Back button to Set Selection.
- App title: `Vocabulary Practice` with book icon.
- Active profile indicator, such as `Alex 🦊`.
- Set title and grade/theme subtitle.
- Compact progress summary, such as `12 / 20 words mastered`.
- Settings gear icon (top right) → Settings screen.
- Four large, color-coded practice mode buttons (kid-friendly, full-width or 2×2 grid):
  - **Learn Words** — blue
  - **Quiz (Multiple Choice)** — green
  - **Spell It (Drag & Drop)** — purple
  - **Type It (Write Answer)** — orange
- Secondary actions (smaller buttons or list rows):
  - Word List
  - Progress
- Optional playful background: soft sky/hills illustration behind cards (must not reduce text contrast).
- Skill progress summary (compact):
  - Reviewed count.
  - Quiz passed count.
  - Spelling count.
  - Typed count.

Example:

```text
Vocabulary Practice

Alex 🦊 · Grade 2 Core Words - Set 1
12 / 20 words mastered

[ Learn Words (blue)        ]
[ Quiz (green)              ]
[ Spell It (purple)         ]
[ Type It (orange)          ]

Word List · Progress
```

Actions:

- Mode buttons open practice screens scoped to this word set.
- Word List opens review list for this set only.
- Progress opens progress for this set and active profile.
- Settings opens app/profile settings.

---

## 7.4 Learn Words Screen

Purpose:

- Child reviews each word and definition.
- Child can hear the word and definition read aloud.

Elements:

- Back button to Set Dashboard.
- Progress indicator: `3 / 20`
- Word text, large and centered.
- Speaker button below or beside word.
- Definition card with speaker button.
- **Example sentence card** (required in v1 — supports learning word meaning in context).
- Speaker button for example sentence.
- Optional small part-of-speech label (e.g. `adjective`) below the word.
- Previous button.
- Next button.
- Do **not** include favorite/bookmark in v1 (out of scope).

Recommended behavior:

- Mark word as reviewed when:
  - The child lands on the word screen and stays for at least 1 second, or
  - The child taps Next.
- Auto-read should be off by default unless a setting enables it.
- Speaker buttons should stop any current speech and read the selected text.
- Pedagogy: child should encounter **word → definition → example sentence** in that order when using speakers manually. Example sentences help attach meaning to real usage.

---

## 7.5 Quiz Screen — Multiple Choice

Purpose:

- Child hears/sees a definition and chooses the correct word.

Prompt:

```text
What word means:
"to show courage and face danger or pain without fear"
```

Elements:

- Progress indicator: `5 / 20`
- Speaker button for prompt.
- Definition card.
- 3 or 4 answer options.
- Speaker button next to each answer option.
- Feedback after selection (inline or dedicated feedback step — see §7.11).
- Session position indicator (dots or `5 / 20`) at bottom.
- Next button (after feedback).

Recommended answer count:

- Use 4 choices by default.
- If the set has fewer than 4 words, use all available options.

Distractor logic:

- Correct answer is the word matching the definition.
- Incorrect answers are randomly selected from the same word set.
- Avoid duplicate options.
- Shuffle answer order every attempt.
- For small sets, use fewer choices rather than pulling unrelated words from another set.

Correct answer behavior:

- Highlight correct answer.
- Play positive feedback.
- Mark `quizCorrect = true`.
- Increment `quizAttempts`.
- Increment `quizCorrectCount`.

Wrong answer behavior:

- Highlight selected wrong answer.
- Reveal correct answer.
- Increment `quizAttempts`.
- Do not mark quiz complete.
- Allow Next.
- Optionally let child retry immediately.

Feedback copy:

```text
Great job!
The correct answer is: brave
```

Wrong answer copy:

```text
Good try!
The correct answer is: brave
```

---

## 7.6 Spell It Screen — Drag and Drop Letters

Purpose:

- Child spells the word using scrambled letters.

Prompt:

```text
Spell the word that means:
"a large body of water surrounded by land"
```

Elements:

- Progress indicator.
- Speaker button for prompt.
- Definition.
- Empty letter slots.
- Scrambled letter tiles.
- Clear button.
- Check button.

Letter generation:

- Include all letters from the target word.
- Add extra distractor letters.
- For short words, add enough distractors to make the puzzle non-trivial.
- For long words, consider fewer distractors.
- Shuffle all letters.

Recommended distractor count:

```text
word length 1-4: add 3 distractors
word length 5-7: add 2 distractors
word length 8+: add 1 distractor
```

Example:

Target word:

```text
lake
```

Available letters:

```text
n a k e l c e
```

Slots:

```text
_ _ _ _
```

Behavior:

- Child drags or taps letters into slots.
- Child can remove letters from slots.
- Clear resets all letters.
- Check validates spelling.
- Correct marks `spellingCompleted = true`.
- Wrong provides gentle feedback and lets child try again.

Important edge cases:

- Duplicate letters must be handled correctly.
- Letter tiles should have stable unique IDs, not just character values.
- Example: the word `letter` has two `t`s and two `e`s.

Suggested tile model:

```dart
class LetterTile {
  final String id;
  final String letter;
}
```

---

## 7.7 Type It Screen — Written Answer

Purpose:

- More difficult mode where child types the correct word from the definition.

Elements:

- Progress indicator.
- Speaker button for prompt.
- Definition.
- Text input.
- Check button.
- Optional Hint button.
- Optional Show Answer button after failed attempts.

Behavior:

- Child types word.
- App compares normalized answer to correct word.
- Ignore case.
- Trim whitespace.
- Optionally ignore punctuation.
- Do not require capitalization.

Normalization:

```dart
String normalizeAnswer(String input) {
  return input.trim().toLowerCase();
}
```

Correct:

- Mark `typedCompleted = true`.
- Increment typed attempts.
- Show positive feedback.

Wrong:

- Increment typed attempts.
- Show encouraging feedback.
- Optionally after 2 wrong tries:
  - Show first letter.
  - Show number of letters.
  - Enable “Show Answer”.

Typing mode should be optional because it may be too hard for younger children.

---

## 7.8 Word List / Review Screen

Purpose:

- Show all words in the selected set.
- Let child review/read any word.

Elements:

- Search optional, not required for v1.
- List of words.
- Each row shows:
  - Word.
  - Short definition.
  - Speaker button.
  - Completion status icon.
- Tapping a row opens the Learn Words screen at that word.

Example:

```text
brave       to show courage...
gather      to come together...
quiet       making little noise...
```

Status icons:

- Gray circle: not started.
- Half-filled/progress icon: partially practiced.
- Check mark: complete.

---

## 7.9 Progress Screen

Purpose:

- Show completion status for the active profile's current set.
- Use a **simple kid-facing summary** at the top and a **detailed skill breakdown** below (mockup shows simplified metrics; spec keeps richer data underneath).

Elements:

- Back button to Set Dashboard.
- Title: `Your Progress` with chart icon.
- Active profile name.
- Current set title.
- **Primary metric (kid-facing):**
  - `Words Mastered: 12 / 20` with progress bar.
  - Label **Words Mastered** maps to overall word completion (review + quiz + spelling), not review-only.
  - Mastered words remain available for repeat practice; this label only controls progress visuals and prioritization.
- **Secondary metrics (skill breakdown):**
  - `Reviewed: 16 / 20`
  - `Quiz passed: 14 / 20`
  - `Spelling done: 10 / 20`
  - `Typed: 6 / 20` (if tracked)
- **Optional parent detail row** (expandable or smaller text):
  - `Quiz accuracy: 85%` derived from `quizCorrectCount / quizAttempts` across the set.
  - Do not make quiz accuracy the primary kid-facing score — counts are easier to understand.
- Word-level progress list with status icons.
- Reset current set button for active profile.
- Reset all progress for active profile behind confirmation.

**Not in v1 (pedagogy decision):**

- **Longest streak** / daily streak counters — excluded; see §15.6. Mockup showed a streak flame icon; v1 will not implement streaks.

Reset confirmation copy:

```text
Reset progress for this set?
This will erase Alex's progress for this word set on this device.
```

Reset all confirmation copy:

```text
Reset all progress for Alex?
This will erase all of Alex's local progress on this device.
```

---

## 7.10 Settings Screen

Purpose:

- App-level local settings and profile management.

Suggested settings:

- Speech speed:
  - Slow
  - Normal
  - Fast
- Auto-read word when opening Learn screen:
  - On/off
- Auto-read definition in quiz:
  - On/off
- Require Type It for completion:
  - On/off
- Manage Profiles:
  - Switch profile
  - Add profile
  - Rename profile
  - Delete profile
- Reset all progress for active profile.
- About app.

Settings should also be stored locally with `shared_preferences`.

---

## 7.11 Answer Feedback Screens

Purpose:

- Give immediate, encouraging feedback after quiz, spelling, and typing attempts.
- Align with mockup **Correct Answer** celebration while keeping wrong-answer feedback low-pressure.

### Correct Answer (Quiz, Spell It, Type It)

After a correct response, show a **dedicated feedback step** before Next:

Elements:

- Light positive visuals (soft confetti or sparkles — optional, not required every time).
- Encouraging headline: `Great job!`
- Correct word in a highlighted card.
- Speaker button for the correct word.
- `Next` button to continue the session.
- Do not use punitive language or red error styling on success.

Copy:

```text
Great job!
The correct answer is: brave
```

When to use full-screen vs inline:

- **Quiz:** dedicated feedback step after selection (matches mockup).
- **Spell It / Type It:** dedicated feedback step after Check succeeds.
- Keep animations brief and skippable via Next.

### Wrong Answer (Quiz, Spell It, Type It)

Wrong answers use **inline feedback** on the practice screen (no separate full screen):

Elements:

- Gentle headline: `Good try!`
- Reveal correct answer.
- Speaker button for correct word.
- Allow retry or Next depending on mode.
- Do not block the session permanently.

Copy:

```text
Good try!
The correct answer is: brave
```

### Set Completion Celebration

When all words in a set reach mastery, show a **larger one-time celebration** (more prominent than per-question feedback):

```text
You completed this word set!
You practiced every word in different ways.
```

Optional confetti. Return to Set Dashboard or Set Selection afterward.

---

## 8. Navigation Structure

### Reconciling mockup with full app flow

The mockup shows practice modes at the top level. The spec keeps **profile and word-set layers** above that. The mockup home screen is the **Set Dashboard**, not the app root.

```text
App root flow:

First Launch
  -> Create Profile
  -> Set Selection

Returning Launch
  -> Profile Selection (if 2+ profiles)
  -> Set Selection

Set Selection
  -> pick word set card
  -> Set Dashboard   ← mockup “Vocabulary Practice” 4-button home

Set Dashboard
  -> Learn Words | Quiz | Spell It | Type It
  -> Word List
  -> Progress
  -> Settings (gear icon)

Practice screens
  -> back to Set Dashboard
  -> Answer Feedback (correct) -> Next -> next item or back to dashboard
```

### Navigation decisions (v1)

- **No persistent bottom tab bar** in v1. The mockup’s bottom nav on the Progress screen is **not** used.
- Use **back buttons** and the Set Dashboard as the hub.
- Profile switching: Set Selection and Settings.
- Word set switching: Set Selection only.
- Settings: gear icon on Set Dashboard (and optionally Set Selection).

Rationale:

- Bottom tabs conflict with profile + word-set context.
- A single hub (Set Dashboard) keeps the child oriented to the active set.
- Reduces cognitive load for younger users.

### Recommended practice order (pedagogy)

The UI does not hard-lock modes, but the Set Dashboard should present modes top-to-bottom in suggested learning order:

1. Learn Words — exposure and meaning.
2. Quiz — retrieval from definition.
3. Spell It — productive spelling with scaffolding.
4. Type It — harder recall (optional/bonus by default).

Optional subtle UI hint: show a small `Try this next` label on the next incomplete mode.

---

## 9. Local State Architecture

Architecture must remain **simple** and **cross-platform**. Business logic, models, and screens should be shared Dart code. Storage and TTS access go through small service classes so Android/iOS differences stay hidden.

### Cross-Platform Rules

- UI screens must not import Android- or iOS-specific APIs directly.
- `shared_preferences` is the only persistence layer in v1 — works on both platforms out of the box.
- `flutter_tts` wraps each platform's native text-to-speech engine — use one shared `TextToSpeechService`.
- Avoid packages that support only one mobile platform unless there is no alternative.
- Prefer Flutter layout widgets that adapt to different screen sizes without separate platform UIs.

### Suggested structure:

```text
lib/
  main.dart
  app.dart

  data/
    vocabulary_sets.dart

  models/
    vocabulary_set.dart
    vocabulary_word.dart
    local_profile.dart
    word_progress.dart
    app_progress.dart
    letter_tile.dart

  services/
    profile_storage_service.dart
    progress_storage_service.dart
    text_to_speech_service.dart

  state/
    vocabulary_controller.dart
    profile_controller.dart
    progress_controller.dart
    settings_controller.dart

  screens/
    profile_selection_screen.dart
    create_profile_screen.dart
    set_selection_screen.dart
    set_dashboard_screen.dart
    learn_words_screen.dart
    quiz_screen.dart
    spell_it_screen.dart
    type_it_screen.dart
    word_list_screen.dart
    progress_screen.dart
    settings_screen.dart
    correct_answer_screen.dart

  widgets/
    app_scaffold.dart
    progress_bar.dart
    speaker_button.dart
    word_set_card.dart
    practice_mode_button.dart
    answer_option_button.dart
    letter_tile_widget.dart
    letter_slot_widget.dart
```

### State Management

For this simple app, avoid heavy state management.

Recommended:

- `ChangeNotifier`
- `ValueNotifier`
- `InheritedWidget`
- Or simple stateful widgets with a shared controller

Avoid Bloc, Riverpod, Redux, MobX, or over-engineering unless explicitly requested.

Recommended controllers:

```dart
class ProfileController extends ChangeNotifier {
  Future<void> load();
  Future<void> save();
  List<LocalProfile> get profiles;
  LocalProfile? get activeProfile;
  Future<void> createProfile({required String displayName, String? avatarEmoji});
  Future<void> renameProfile(String profileId, String displayName);
  Future<void> deleteProfile(String profileId);
  Future<void> setActiveProfile(String profileId);
}

class ProgressController extends ChangeNotifier {
  Future<void> load(String profileId);
  Future<void> save();
  void markReviewed(String setId, String wordId);
  void markQuizAttempt(String setId, String wordId, {required bool correct});
  void markSpellingAttempt(String setId, String wordId, {required bool correct});
  void markTypedAttempt(String setId, String wordId, {required bool correct});
  void resetSet(String setId);
  void resetAllForActiveProfile();
}
```

---

## 10. Text-to-Speech Requirements

Use the platform TTS engine through `flutter_tts`.

### Required TTS Features

- Read word.
- Read definition.
- Read quiz prompt.
- Read answer option.
- Stop current speech before starting new speech.
- Respect speech speed setting.

Suggested service:

```dart
class TextToSpeechService {
  final FlutterTts _tts = FlutterTts();

  Future<void> initialize() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate);
  }
}
```

### TTS UX Rules

- Every speaker icon should be large enough for a child to tap.
- Speaker icon should show a brief active state while speaking if feasible.
- Navigating away from a screen should stop speech.
- Starting new speech should stop old speech.
- Avoid auto-reading everything unless enabled in settings.

---

## 11. Word Set Switching

Users must be able to switch between sets.

### Requirements

- Set Selection screen lists all available hardcoded sets.
- User can tap a set to make it active.
- Active set ID is saved locally.
- Progress remains separate per profile and per set.
- Switching sets should not erase progress.
- Switching profiles should not erase any profile's progress.
- Completing one set should not affect another set.
- Completing work in one profile should not affect another profile.

### Data Ownership

Vocabulary data is hardcoded:

```dart
const List<VocabularySet> vocabularySets = [
  grade2CoreSet1,
  grade2CoreSet2,
  scienceWordsSet1,
];
```

Local progress references hardcoded word IDs.

### Important Stability Rule

Do not change a word ID after release if local progress should be preserved.

Bad:

```dart
id: 'brave-word'
```

Then later changing to:

```dart
id: 'brave'
```

This would orphan local progress.

Better:

```dart
id: 'grade2-core-001-brave'
```

### Recommended ID Format

```text
{setId}-{word}
```

Example:

```text
grade2-core-001-brave
grade2-core-001-gather
grade2-core-001-quiet
```

Set IDs:

```text
grade2-core-001
grade2-core-002
science-animals-001
reading-grammar-001
```

---

## 12. Progress Tracking Details

### Track Per Profile

Store for each local profile:

- Profile metadata: id, display name, created date, optional emoji.
- Active set for that profile.
- Optional last practice mode per set.
- All word-set progress for that profile.

### Track Per Word

Track per profile:

- Reviewed.
- Quiz correct.
- Spelling completed.
- Typed completed.
- Attempts.
- Last practiced date.

### Track Per Set

Derived from word progress for the active profile:

- Total words.
- Completed words.
- Reviewed words.
- Quiz completed words.
- Spelling completed words.
- Typed completed words.
- Percent complete.

Avoid storing derived values if they can be calculated from word progress.

### Track Last Active Set

Store per profile:

```text
selectedSetId
```

Optional per profile:

```text
lastModeBySet
```

Example:

```json
{
  "profile-7f3c2a91-4b2e-4d11-9c88-001122334455": {
    "selectedSetId": "grade2-core-001",
    "lastModeBySet": {
      "grade2-core-001": "quiz",
      "science-animals-001": "learn"
    }
  }
}
```

This allows a Continue button per profile.

---

## 13. Practice Session Rules

For quiz/spelling/type modes, decide which word appears next.

### V1 Recommended Order

Use a smart but simple order:

1. Prioritize incomplete words first.
2. Within the current session, re-prioritize words the child missed so they can see them again before the session ends.
3. Shuffle within priority groups so practice does not feel too predictable.
4. After all words are complete/mastered, allow repeat review mode with all words.

### Quiz Session

- Create a session list when the screen opens.
- Include incomplete quiz words first.
- If all quiz words are complete, include all words.
- Progress indicator shows session progress, not necessarily total set progress.

Example:

```text
Question 3 / 12
```

Wrong-answer repeat behavior:

- If a child answers a quiz item incorrectly, do not mark the quiz skill complete for that word.
- Reveal the correct answer gently.
- Put that word back into the current session queue after a short gap when possible.
- Do not create an infinite loop; after repeated misses, allow the child to continue and practice again later.

### Learn Session

- Default to first incomplete reviewed word.
- If all reviewed, start at first word.

### Spell Session

- Default to first incomplete spelling word.
- If all spelling complete, allow review.

### Type Session

- Default to first incomplete typed word.
- If all typed complete, allow review.

---

## 14. Feedback and Motivation

Keep feedback gentle and intrinsic. Align with §7.11 for correct-answer celebration screens and inline wrong-answer feedback.

Good feedback examples:

```text
Great thinking!
You figured it out!
Nice try — look closely and try again.
That one was tricky.
You’re building your word power.
```

Avoid:

```text
Wrong!
Failed!
Bad answer!
```

Use stars/checks sparingly. Do not use streaks, leaderboards, or daily-loss pressure in v1.

Completion celebration:

- When a word is mastered: small positive message (can reuse correct-answer feedback styling).
- When a set is completed: larger celebration screen (§7.11).
- Optional light confetti on set completion only — not required on every correct quiz answer.

Set complete message:

```text
You completed this word set!
You practiced every word in different ways.
```

---

## 15. Accessibility and Kid-Friendly Design

### UI

- Large tap targets.
- High contrast.
- Rounded cards.
- Minimal clutter.
- Simple icons.
- Large readable text.
- Avoid dense paragraphs.
- Use short instructions.

### Read-Aloud

- Speaker button available on all important text.
- TTS speed setting.
- Avoid requiring reading to navigate.

### Motor Skills

- Drag-and-drop should also support tap-to-place.
- Letter tiles should be large.
- Clear button should be easy to find.
- Do not make precision dragging mandatory.

### Error Tolerance

- Child can retry.
- Child can go back.
- Child can hear the word/definition again.
- Wrong answers should not block progress permanently.

---

## 15.5 Visual Design Direction (UI Mockup)

The reference mockup establishes the v1 look and feel. Implementation should match its spirit while keeping the full spec navigation flow.

### Overall style

- **Playful and cartoonish** — not corporate/minimal.
- Soft outdoor background (blue sky, green hills) on Set Dashboard and optionally practice screens.
- Rounded cards, large colorful buttons, generous whitespace.
- High contrast for word text and definitions — backgrounds must not harm readability.

### Branding

- App title: `Vocabulary Practice` with book icon.
- Portrait-only in v1.

### Mode button colors (Set Dashboard)

| Mode | Color | Subtitle shown on button |
|------|-------|--------------------------|
| Learn Words | Blue | — |
| Quiz | Green | `Multiple Choice` |
| Spell It | Purple | `Drag & Drop` |
| Type It | Orange | `Write Answer` |

### Practice screen patterns (from mockup)

- White content cards on soft background.
- Progress in header: `3 / 20`.
- Speaker icons on word, definition, prompt, and each quiz option.
- Quiz: vertical answer buttons with speaker per option; dot indicators for session position.
- Spell It: dashed empty slots + letter tile bank; Clear and Check buttons.
- Type It: single text field placeholder `Type your answer here...` and large Check button.
- Word List: rows with word, truncated definition, speaker icon, plus completion status icon from §7.8.

### Celebration visuals

- Correct-answer step: encouraging headline, highlighted answer card, optional light confetti/sparkles.
- Simple star or mascot illustration is optional — do not block MVP on character art.
- Set-completion celebration may be more prominent than per-answer feedback.

### Explicitly not adopting from mockup

| Mockup element | v1 decision |
|----------------|-------------|
| Bottom tab bar (Home / Learn / Quiz / Progress) | Not used — Set Dashboard is the hub (§8) |
| Longest streak / flame icon | Not in v1 — see §15.6 |
| Favorite/star on Learn Words | Not in v1 |
| Quiz Score 85% as primary metric | Replaced by kid-friendly counts; accuracy is optional detail (§7.9) |
| Skipping profile and word-set screens | Not allowed — mockup is Set Dashboard only, not app root |

### Screens still required beyond mockup

These must be designed even though the mockup does not show them:

- Profile Selection / Create Profile
- Set Selection (word set cards with per-set progress)
- Settings
- Wrong-answer inline states (quiz, spell, type)

---

## 15.6 Pedagogy Requirements

Vocabulary learning in v1 should follow evidence-informed practice patterns suited to elementary learners. The app is a **practice supplement**, not a full curriculum.

### Learning goals (v1)

For each word, the child should be able to:

1. **Recognize** the word and connect it to meaning (Learn Words).
2. **Understand** a child-friendly definition (Learn Words, TTS).
3. **Retrieve** the word from a definition (Quiz).
4. **Produce** the spelling with scaffolding (Spell It).
5. **Produce** the word from memory with less scaffolding (Type It — optional/bonus).

### Instructional design baked into v1

| Principle | How the app supports it |
|-----------|-------------------------|
| Multimodal exposure | See word, hear word (TTS), read definition, read example sentence |
| Contextual vocabulary | Example sentence required on Learn Words screen |
| Retrieval practice | Definition → word quiz with feedback |
| Productive practice | Spell It and Type It require active production |
| Scaffolding | Drag-and-drop spelling, hints on Type It, read-aloud everywhere |
| Immediate feedback | Correct-answer step and gentle wrong-answer messaging (§7.11) |
| Mastery visibility | Words Mastered + per-skill counts (§7.9) |
| Low reading barrier | TTS on all key text; large UI |
| Growth mindset tone | Encouraging copy; no punitive failure language (§14) |
| Manageable cognitive load | 4 answer choices max; one word/task at a time |
| Prioritize weak items | Incomplete words first in sessions (§13) |

### Recommended learner path

Not enforced, but surfaced in UI copy and mode ordering:

```text
Learn Words → Quiz → Spell It → Type It (bonus)
```

Pedagogy note: Quiz before Spell It assumes the child has been introduced to the word. The app should not require Spell It before the word appears in Learn or Quiz, but may show a gentle nudge if the child jumps ahead.

### Mastery rule (v1)

A word is **mastered** after:

- Reviewed at least once.
- Quiz correct at least once.
- Spelling correct at least once.

In v1, **mastered** means `complete for now` inside this app. It should be presented as an encouraging progress marker, not as a formal claim that the child will remember the word permanently.

All mastered words remain repeatable in Learn, Quiz, Spell It, Type It, and Word List.

Pedagogy tradeoff: **one success per mode** keeps the app simple and motivating, but long-term retention often benefits from repeated exposure over time. v1 intentionally uses a single-success threshold; see §15.7.

### What v1 does not optimize for

- Spaced repetition scheduling.
- Adaptive difficulty within a set.
- Formal assessment or grading.
- Competing with other learners.

---

## 15.7 Pedagogy Gaps and Out-of-Scope Learning Features

The following gaps are **known and accepted for v1**. Document them so future versions can address retention and depth without overbuilding now.

### High-value gaps (consider for v2+)

| Gap | Why it matters | v1 status |
|-----|----------------|-----------|
| **Formal spaced repetition** | Words fade without timed review across days; scheduled review is one of the strongest levers for long-term retention | Not in v1 — children can repeat practice freely, but the app does not schedule review by date |
| **Formal repeated-success requirement** | One quiz/spelling success may not be enough for durable learning | Not in v1 — children can repeat tasks as many times as needed, but the app does not require multiple correct completions before marking a word mastered |
| **Word → definition reverse quiz** | Tests receptive and productive knowledge in both directions | Not in v1 — quiz is definition → word only |
| **Use in context exercises** | Sentence completion / fill-in-the-blank checks real usage | Not in v1 — example sentence is exposure only, not interactive |
| **Child pronunciation practice** | Speaking a word strengthens memory and phonological awareness | Not in v1 — TTS is listen-only |
| **“Needs review” weak-word mode** | Revisit words with many wrong attempts | Not in v1 — attempt counts and `lastPracticedAt` are stored, but there is no dedicated review queue |
| **Semantic connections** | Synonyms, antonyms, word maps deepen understanding | Not in v1 — not in word model |

### Medium-value gaps

| Gap | Why it matters | v1 status |
|-----|----------------|-----------|
| **Letter-name/sound support in Spell It** | Helps younger spellers connect sounds to letters | Not in v1 — no per-letter audio |
| **“I don’t know” option in quiz** | Reduces random guessing; enables honest scaffolding | Not in v1 |
| **Interleaving across sets** | Mixing topics can improve transfer | Not in v1 — practice stays within one selected set |
| **Explicit teaching of part of speech** | Helps older students use words grammatically | Optional label only — not a taught lesson |
| **Homophone discrimination drills** | Words that sound alike need extra contrast | Not in v1 — speaker buttons help but no dedicated drill |
| **Writing word in a sentence** | Production in context | Not in v1 |

### Low-priority / gamification gaps (intentionally excluded)

| Gap | v1 decision |
|-----|-------------|
| Daily streaks | Excluded — can discourage learners who miss days and shift focus from mastery to maintaining streaks |
| Badges / star collections | Excluded — light celebration only |
| Leaderboards | Excluded |
| Sound effects beyond TTS | Optional later — not required for v1 |

### Content gaps (depend on word list authoring)

| Gap | Recommendation |
|-----|----------------|
| Age/grade appropriateness of definitions | Parent/teacher authors definitions when editing `vocabulary_sets.dart` |
| Cognates, morphology, roots | Future word model fields |
| Multi-word academic terms | Learn + Quiz + Type supported; Spell It may skip or use fixed spaces (§16) |
| Set size too large for one sitting | Keep sets around 10–20 words for v1; split larger lists into multiple sets |

### Pedagogy testing checklist (manual, pre-release)

- Can a child with limited reading skills complete Learn → Quiz with TTS only?
- Does example sentence clarify meaning without adding confusion?
- Is Spell It too hard before Learn/Quiz for target age?
- Does wrong-answer feedback feel encouraging, not punishing?
- Can a parent see which skill (review vs quiz vs spelling) needs work?
- Does switching profiles fully isolate progress?

---

## 16. Important Edge Cases

### Duplicate Letters

Words like:

```text
letter
bubble
puppy
success
```

Need unique letter tile IDs.

### Short Word Sets

If a set has fewer than 4 words, multiple choice should use fewer answers instead of crashing.

### Long Words

Long words may not fit on one row.

Spelling slots should wrap or shrink gracefully.

### Punctuation

Definitions and example sentences may contain punctuation.

TTS should read punctuation naturally.

### Multi-Word Vocabulary Terms

Some vocabulary entries may be phrases:

```text
natural selection
food chain
solar system
```

Need to decide whether spelling/type modes support spaces.

Recommended v1:

- Multiple choice supports multi-word terms.
- Learn mode supports multi-word terms.
- Type mode supports multi-word terms.
- Drag-and-drop spelling can either:
  - Include spaces as fixed separators, or
  - Disable drag spelling for multi-word terms.

### Homophones / Similar Words

If words sound similar, speaker buttons are important.

### Progress After Data Changes

If hardcoded words are removed from a set:

- Ignore orphaned progress.
- Do not crash.
- Optional: clean up old progress on save.

If new words are added:

- They appear as incomplete.

### Text-to-Speech Unavailable

If TTS fails:

- App should still work visually.
- Speaker button can show a friendly error or silently fail.

### Device Rotation

Prefer portrait-only for v1 unless otherwise requested.

### Local Profiles

If the last profile is deleted:

- Return to Create Profile flow.
- Do not crash.
- Do not leave the app without an active profile.

If two profiles have the same display name:

- Allow it in v1.
- Distinguish profiles by emoji and internal ID.

If a profile is switched mid-practice:

- Save current progress before switching.
- Stop any active speech.
- Open Set Selection for the newly active profile.

If local storage is corrupted or unreadable:

- Fail safely.
- Prefer starting with empty profiles over crashing.
- Optional: show a simple recovery message.

---

## 17. Questions / Clarifications Needed

Decisions marked **Decided** are locked for v1. Remaining items still need content input from the parent/teacher author.

### Content and Word Sets

1. How many word sets will be included in v1? **Still open — recommend 2–4 starter sets.**
2. About how many words per set? **Still open — recommend 10–20 words per set (§15.7).**
3. Will sets be organized by:
   - Grade level?
   - Theme?
   - School week?
   - Difficulty?
   - Subject area?
   **Still open — recommend grade + theme labels on each set.**
4. ~~Do words need example sentences?~~ **Decided: yes, required in v1 (§7.4, §15.6).**
5. ~~Do words need part of speech?~~ **Decided: yes in data model; optional small label in Learn Words UI.**
6. ~~Do words need synonyms or related words?~~ **Decided: not in v1.**
7. ~~Will there be multi-word terms?~~ **Decided: supported in Learn/Quiz/Type; Spell It may skip or use fixed spaces.**

### Completion

8. ~~What should count as completing a word?~~ **Decided: reviewed + quiz correct + spelling complete (§6).**
9. ~~Should Type It be required for completion?~~ **Decided: bonus by default; setting can require it (§7.10).**
10. ~~Should a child have to get a word correct multiple times before it is complete?~~ **Decided: no in v1 — one success per required mode marks the word mastered/complete for now (§15.6). Practice remains repeatable forever. Formal repeated-success requirements are a v2+ option (§15.7).**

### Quiz

11. ~~Should quiz show the definition as text, read it aloud, or both?~~ **Decided: both — text always visible, speaker for prompt (§7.5).**
12. ~~Should answer choices show text, speaker buttons, or both?~~ **Decided: both (§7.5, mockup).**
13. ~~Should there be 3 choices or 4 choices?~~ **Decided: 4 when possible (§7.5).**
14. ~~Should a wrong answer immediately reveal the correct answer?~~ **Decided: yes, with gentle copy (§7.5, §7.11).**
15. ~~Should wrong answers return later in the same session?~~ **Decided: yes (§18).**

### Spelling

16. ~~Should drag-and-drop also support tap-to-place?~~ **Decided: yes (§18).**
17. ~~Should spelling use extra distractor letters?~~ **Decided: yes (§7.6).**
18. ~~Should spelling include speaker support for each letter?~~ **Decided: no in v1 (§15.7).**
19. ~~Should multi-word terms be allowed in spelling mode?~~ **Decided: skip or fixed spaces in v1 (§18).**
20. ~~Should letter tiles be lowercase only?~~ **Decided: yes in v1 (§18).**

### Typing

21. ~~Should typing mode ignore capitalization?~~ **Decided: yes (§7.7).**
22. ~~Should typing mode ignore spaces and punctuation?~~ **Decided: trim whitespace; case-insensitive; punctuation not required in answer (§7.7).**
23. ~~Should hints be available?~~ **Decided: yes after 2 wrong attempts (§7.7).**
24. ~~After how many wrong tries should the answer be shown?~~ **Decided: 3 wrong attempts (§18).**

### Read-Aloud

25. ~~Should the app auto-read prompts when screens open?~~ **Decided: off by default; optional settings (§7.10).**
26. ~~What speech speed should be default?~~ **Decided: normal/slightly slow (§18).**
27. ~~Should there be a voice setting?~~ **Decided: use device default TTS voice in v1; speech speed setting only.**
28. ~~Should the word be read aloud before the definition in quizzes?~~ **Decided: no — quiz prompt reads the definition/question, not the answer word before selection.**

### Progress

29. ~~Should progress be per device only?~~ **Decided: yes — on-device only, per profile (§2).**
30. ~~Should there be multiple child profiles on the same device?~~ **Decided: yes (§7.1).**
31. ~~Should parents be able to reset one set?~~ **Decided: yes (§7.9).**
32. ~~Should parents be able to reset all progress for one profile?~~ **Decided: yes (§7.9).**
33. ~~Should the app show streaks or avoid gamification?~~ **Decided: no streaks in v1; light celebration only (§15.6, §15.7).**

### UI

34. ~~Should the visual style be more playful/cartoonish or clean/minimal?~~ **Decided: playful/cartoonish per mockup (§15.5).**
35. ~~Should there be sound effects beyond TTS?~~ **Decided: not required in v1.**
36. ~~Should the app use stars, badges, or simple checkmarks?~~ **Decided: simple checkmarks/status icons; no badge system (§7.8).**
37. ~~Should there be a progress screen for all sets combined?~~ **Decided: per-set progress in v1; all-sets summary optional later.**

### Platform

38. ~~iOS only, Android only, or both?~~ **Decided: both Android and iOS (§3).**
39. ~~Should the app be portrait-only?~~ **Decided: yes in v1 (§18).**
40. ~~Is tablet support important?~~ **Decided: nice-to-have; phone-first (§2).**

### Navigation and mockup alignment

41. ~~Does mockup home replace Set Selection?~~ **Decided: no — mockup home is Set Dashboard after set is chosen (§8).**
42. ~~Should v1 use bottom tab navigation?~~ **Decided: no — Set Dashboard hub with back buttons (§8).**
43. ~~Should correct answers use a dedicated celebration screen?~~ **Decided: yes for quiz/spell/type correct responses (§7.11).**
44. ~~What does “Words Learned” mean in the UI?~~ **Decided: label as Words Mastered = overall word completion (§7.9).**

---

## 18. Recommended V1 Decisions

To avoid overbuilding, use these defaults unless changed.

### Data

- Hardcoded Dart vocabulary data.
- Multiple sets supported from the start.
- Each word has:
  - Word.
  - Definition.
  - Example sentence.
  - Part of speech.
  - Difficulty.

### Profiles

- Multiple local profiles on one device.
- No login, email, password, or verification.
- Profile requires display name only.
- Optional emoji avatar from a small preset list.
- If one profile exists, auto-enter that profile.
- If two or more profiles exist, show Profile Selection on launch.
- Profile switching available from Set Selection and Settings.
- Deleting a profile deletes only that profile's progress.

### Progress

- Local-only using `shared_preferences`.
- Progress separated by profile and by word set.
- Reset actions apply to the active profile only.
- Completion requires:
  - Reviewed.
  - Quiz correct once.
  - Spelling correct once.
- Typed answer is bonus by default.

- Mastered/completed words remain available for repeat practice.
- Mastery affects visual progress and prioritization only; it never locks content.

### Quiz

- 4 choices when possible.
- Definition shown and readable.
- Every answer option has a speaker button.
- Wrong answer reveals the correct answer.
- Wrong answer can come back later.

### Spelling

- Drag-and-drop plus tap-to-place.
- Extra distractor letters.
- Duplicate letters handled by unique tile IDs.
- Lowercase letters only in v1.
- Multi-word terms can skip spelling mode in v1 or use fixed spaces.

### Typing

- Case-insensitive.
- Trim whitespace.
- Hint available after 2 wrong attempts.
- Show answer after 3 wrong attempts.

### TTS

- Manual speaker buttons everywhere.
- Auto-read off by default.
- Normal/slower speed default.

### UI

- Playful/cartoonish visual style per mockup (§15.5).
- Color-coded mode buttons on Set Dashboard.
- Portrait-only.
- Kid-friendly, large buttons.
- Simple progress bars.
- Dedicated correct-answer feedback step; inline wrong-answer feedback.
- No bottom tab bar.
- No streaks, badges, or favorite/bookmark features.
- No ads, no monetization, no remote account.

### Progress display

- Primary kid metric: **Words Mastered** (`completedWords / totalWords`).
- Secondary: per-skill counts (Reviewed, Quiz passed, Spelling, Typed).
- Optional detail: quiz accuracy % for parents — derived, not stored.
- No daily streak tracking.

### Pedagogy

- Example sentences required on Learn Words.
- Suggested mode order: Learn → Quiz → Spell → Type.
- Single success per required mode marks a word mastered/complete for now in v1.
- Practice remains repeatable even after mastery.
- See §15.6 and §15.7 for full pedagogy requirements and known gaps.

### Platform

- Flutter app for **Android and iOS**.
- Single shared codebase; no separate native apps.
- On-device storage only via `shared_preferences`.
- Core flows must be verified on both platforms.

---

## 19. Suggested MVP Build Order

### Phase 1 — App Shell, Profiles, and Hardcoded Data

- Create Flutter project configured for Android and iOS.
- Add models.
- Add hardcoded word sets.
- Add profile storage service.
- Add profile selection and create profile screens.
- Add set selection screen.
- Add selected set state scoped to active profile.
- Add set dashboard.

Acceptance criteria:

- First launch prompts profile creation.
- User can create a profile with a name only.
- User with one profile enters directly on relaunch.
- User with multiple profiles sees profile picker on relaunch.
- User can switch profiles.
- User can choose a set.
- User can see set dashboard.
- No vocabulary progress yet required.

---

### Phase 2 — Local Progress

- Add progress storage service.
- Load/save progress using `shared_preferences`.
- Scope progress to active profile.
- Track selected set per profile.
- Calculate set completion per profile.
- Show progress bars on profile-aware screens.

Acceptance criteria:

- Selected set persists per profile after app restart.
- Progress persists per profile after app restart.
- Switching profiles shows the correct progress for each profile.
- Reset set progress works for the active profile only.
- Delete profile removes only that profile's data.

---

### Phase 3 — Learn Words + TTS

- Add text-to-speech service.
- Add Learn Words screen.
- Add speaker buttons.
- Mark words reviewed.

Acceptance criteria:

- User can navigate words.
- Word can be read aloud.
- Definition can be read aloud.
- Reviewed progress updates.

---

### Phase 4 — Multiple Choice Quiz

- Add quiz question generation.
- Add answer choice shuffling.
- Add speaker buttons for answers.
- Add correct/wrong feedback.
- Update quiz progress.

Acceptance criteria:

- User sees definition prompt.
- User chooses correct word from options.
- Speaker buttons work.
- Correct answers update local progress.

---

### Phase 5 — Drag-and-Drop Spelling

- Add spelling screen.
- Generate letter tiles.
- Support duplicate letters.
- Support extra distractors.
- Support clear/check.
- Update spelling progress.

Acceptance criteria:

- User can spell target word.
- Correct spelling updates progress.
- Incorrect spelling allows retry.
- Duplicate letters work correctly.

---

### Phase 6 — Type It

- Add typed answer screen.
- Normalize input.
- Add hints.
- Update typed progress.

Acceptance criteria:

- User can type answer.
- Correct answer updates progress.
- Wrong answer gives gentle feedback.
- Hints work.

---

### Phase 7 — Polish

- Add word list screen.
- Add progress screen (Words Mastered + skill breakdown).
- Add settings screen.
- Add correct-answer feedback screen (§7.11).
- Add set-completion celebration.
- Apply mockup visual styling (§15.5).
- Add reset confirmations.
- Run pedagogy checklist (§15.7).

---

### Phase 8 — Cross-Platform Verification

- Run the app on Android and iOS.
- Verify profile create/switch/delete on both platforms.
- Verify progress persists after app restart on both platforms.
- Verify TTS speaker buttons on both platforms.
- Verify drag/tap spelling interactions on both platforms.

Acceptance criteria:

- All core flows work on Android.
- All core flows work on iOS.
- No platform-specific crashes in storage or TTS.

---

## 20. Testing Checklist

### Data Tests

- App handles empty set list gracefully.
- App handles set with 1 word.
- App handles set with 2-3 words.
- App handles set with 20+ words.
- App handles duplicate letters.
- App handles long words.
- App handles multi-word terms.

### Profile Tests

- First launch creates first profile successfully.
- Second profile can be added without affecting the first profile's progress.
- Switching profiles loads the correct progress.
- Renaming a profile preserves its progress.
- Deleting a profile removes only that profile's progress.
- Active profile persists after app restart.

### Progress Tests

- Progress persists after app restart for each profile.
- Switching profiles preserves each profile's progress independently.
- Switching sets preserves each set’s progress within a profile.
- Reset current set only resets that set for the active profile.
- Reset all clears only the active profile's progress.
- New hardcoded words appear incomplete for all profiles.
- Removed hardcoded words do not crash progress calculation.

### Pedagogy / UX Tests

- Learn Words shows example sentence and TTS for word, definition, and sentence.
- Suggested mode order is visible on Set Dashboard.
- Correct-answer feedback is encouraging and includes speaker for answer word.
- Wrong-answer feedback does not use punitive language.
- Words Mastered matches overall completion formula.
- Mastered words remain available in Learn, Quiz, Spell It, Type It, and Word List.
- Mastery does not lock or hide any word.
- No streak UI appears anywhere.

### Cross-Platform Tests

- App launches on Android.
- App launches on iOS.
- Profile and progress persistence works on Android after restart.
- Profile and progress persistence works on iOS after restart.
- TTS works on Android.
- TTS works on iOS.
- Spelling drag/tap works on Android.
- Spelling drag/tap works on iOS.

### TTS Tests

- Word speaker works.
- Definition speaker works.
- Quiz prompt speaker works.
- Answer option speakers work.
- Speech stops when leaving screen.
- Starting new speech stops previous speech.

### Quiz Tests

- Correct answer is always included.
- Answers are shuffled.
- No duplicate answer options.
- Small sets do not crash.
- Correct answer updates progress.
- Wrong answer does not mark complete.

### Spelling Tests

- Letter tiles include all target letters.
- Extra letters are added.
- Duplicate letters are handled.
- Clear button works.
- Correct spelling marks complete.
- Wrong spelling allows retry.

### Typing Tests

- Correct answer with uppercase still passes.
- Leading/trailing spaces ignored.
- Wrong answer gives feedback.
- Hint appears after configured attempts.

---

## 21. Non-Goals for V1

Do not build these unless explicitly requested:

- Login, signup, email verification, or passwords.
- Remote user accounts.
- Parent dashboard with login.
- Remote content editing.
- Cloud sync.
- Firebase.
- SQLite, Hive, Drift, Realm, or other local database packages.
- Remote database.
- Ads.
- In-app purchases.
- Leaderboards.
- Social sharing.
- Push notifications.
- AI-generated definitions.
- Web admin panel.
- Multi-device sync.
- Detailed analytics.

---

## 22. Cursor Implementation Prompt

Use this as the implementation instruction for Cursor:

```text
Build a simple Flutter mobile app for kids to practice vocabulary on both Android and iOS from one codebase.

The app must be local-only. Do not use a backend, remote database, login, email verification, authentication, ads, analytics, Firebase, or any remote service. Vocabulary word sets should be hardcoded in Dart files. Profiles and progress must be stored on the device only using shared_preferences. Do not use SQLite, Hive, or other database packages in v1.

All architecture must be cross-platform: shared Dart UI and logic, with platform differences isolated in thin service wrappers for storage and TTS.

Core features:
1. Local profile selection and creation with display name only. Support multiple profiles on one device with independent progress. No login or verification.
2. Set Selection screen where the active profile can switch between hardcoded word sets and see completion progress per set.
3. Set Dashboard screen with practice modes for the selected set.
4. Learn Words mode with word, definition, example sentence, and speaker buttons using text-to-speech.
5. Multiple Choice Quiz mode where the app shows/reads a definition and the user chooses the correct word. Each answer option must have its own speaker button.
6. Spell It mode where the user spells the correct word using draggable/tappable scrambled letter tiles, including extra distractor letters.
7. Type It mode where the user types the correct word from the definition.
8. Word List screen for reviewing all words in the selected set.
9. Progress screen showing Words Mastered and per-skill breakdown for the selected set and active profile.
10. Settings screen with profile management and reset actions scoped to the active profile.
11. Correct-answer feedback screen after quiz/spell/type success; inline wrong-answer feedback.
12. Playful kid-friendly UI per mockup: color-coded Set Dashboard mode buttons, large speakers, rounded cards.

Navigation: Profile Selection -> Set Selection -> Set Dashboard (mockup 4-button home) -> practice modes. No bottom tab bar in v1.

Pedagogy: require example sentences in Learn Words; suggest Learn -> Quiz -> Spell -> Type order; no streaks; single success per required mode marks a word mastered/complete for now in v1. Practice must remain repeatable forever; mastery controls progress visuals and prioritization only. See section 15.6 and 15.7.

Use Flutter with flutter_tts and shared_preferences.

Use simple maintainable architecture:
- models/
- data/
- services/
- state/
- screens/
- widgets/

Progress must be tracked separately per local profile, per word set, and per word. Switching profiles or sets must preserve the correct local progress. Completion for a word should require reviewed + quizCorrect + spellingCompleted. Typed answer should be tracked but not required for completion by default.

Make the UI kid-friendly:
- large buttons
- readable text
- rounded cards
- simple navigation
- speaker buttons on important text
- gentle feedback
- no ads
- no external network dependency

Handle edge cases:
- sets with fewer than 4 words
- duplicate letters in spelling
- long words
- multi-word terms
- progress after hardcoded vocabulary data changes
- text-to-speech failure

Implement the app in phases:
1. App shell, models, hardcoded data, local profiles, set selection, dashboard.
2. Local progress persistence scoped to profiles.
3. Learn Words with TTS.
4. Multiple choice quiz.
5. Drag/tap spelling.
6. Type It mode.
7. Word list, progress screen, settings, polish.
8. Cross-platform verification on Android and iOS.

Prioritize clean, understandable code over heavy abstractions.
```

---

## 23. Recommended First Hardcoded Sample Data

Use this starter set to validate the UI before importing a larger list.

```dart
const VocabularySet grade2CoreSet1 = VocabularySet(
  id: 'grade2-core-001',
  title: 'Grade 2 Core Words - Set 1',
  description: 'Common words for vocabulary practice.',
  gradeLabel: 'Grade 2',
  theme: 'Core Vocabulary',
  words: [
    VocabularyWord(
      id: 'grade2-core-001-brave',
      word: 'brave',
      definition: 'To show courage and face danger or pain without fear.',
      exampleSentence: 'The brave firefighter helped the family.',
      partOfSpeech: 'adjective',
      difficulty: WordDifficulty.easy,
    ),
    VocabularyWord(
      id: 'grade2-core-001-gather',
      word: 'gather',
      definition: 'To come together in one place.',
      exampleSentence: 'The students gather on the rug for story time.',
      partOfSpeech: 'verb',
      difficulty: WordDifficulty.easy,
    ),
    VocabularyWord(
      id: 'grade2-core-001-quiet',
      word: 'quiet',
      definition: 'Making little or no noise.',
      exampleSentence: 'The library is a quiet place to read.',
      partOfSpeech: 'adjective',
      difficulty: WordDifficulty.easy,
    ),
    VocabularyWord(
      id: 'grade2-core-001-smile',
      word: 'smile',
      definition: 'To make a happy expression with your mouth.',
      exampleSentence: 'She gave her friend a big smile.',
      partOfSpeech: 'verb',
      difficulty: WordDifficulty.easy,
    ),
    VocabularyWord(
      id: 'grade2-core-001-lake',
      word: 'lake',
      definition: 'A large body of water surrounded by land.',
      exampleSentence: 'We saw ducks swimming in the lake.',
      partOfSpeech: 'noun',
      difficulty: WordDifficulty.easy,
    ),
  ],
);
```

---

## 24. Additional Design Notes

### Keep the App Editable

Because vocabulary is hardcoded, the data file should be clean and easy to edit.

Avoid burying word data inside UI files.

Good:

```text
lib/data/vocabulary_sets.dart
```

Bad:

```text
lib/screens/quiz_screen.dart
```

### Keep Progress Versioned

Use a versioned local storage key:

```text
vocab_app_state_v1
```

This gives room to migrate profiles, progress, and settings together later.

### Keep IDs Stable

Progress depends on IDs. IDs should not be generated from list index.

Bad:

```dart
id: 'word-1'
```

Better:

```dart
id: 'grade2-core-001-brave'
```

### Prefer Derived Progress

Do not manually store set percent complete. Calculate it from word progress so it stays accurate.

### Avoid Too Much Gamification

A light celebration is fine. Do not add streak pressure, competitive scoring, or punishment mechanics unless requested.

The app is for practice, not performance anxiety. See §15.6 and §15.7 for pedagogy rationale.

### UI Mockup Reference

The practice-mode mockup is the visual target for Set Dashboard and practice screens. Profile Selection and Set Selection screens should use the same playful style but were not mocked — design them as simpler card/list flows with the same colors, rounded corners, and large tap targets.

---

## 25. Future Enhancements

Possible later features:

- Import word sets from CSV bundled at build time.
- Parent-only edit mode.
- Per-profile app settings instead of global settings.
- Profile PIN protection for parent-only actions.
- **Spaced repetition** and review scheduling (§15.7).
- **Weak-word review mode** based on attempt history (§15.7).
- **Formal repeated-success requirement** before mastery, such as requiring correct answers across multiple sessions or days.
- **Word → definition** reverse quiz (§15.7).
- **Sentence completion / use in context** exercises (§15.7).
- **Child pronunciation** practice with speech recognition (§15.7).
- Synonyms, antonyms, and word maps in word model (§15.7).
- Optional daily streak (off by default) if requested later.
- All-sets combined progress summary.
- Audio recording so child can pronounce words.
- Sentence fill-in-the-blank mode.
- Matching game mode.
- Printable worksheet export.
- Optional cloud sync.
- Optional web version.

Do not implement these in v1 unless explicitly requested.
