# Moreki

Moreki is a financial-coaching app for South Africans aged 18 to 35: first-job earners, family supporters, people with irregular income and side hustlers. It is built by **Cubic Code** (Ompha Mabila) in Flutter for Android, and is also a university PoE project (IIE Varsity College, Software Development diploma).

The tone is an encouraging older sibling: no shaming, Rand-based, locally relevant.

## What works today

| Area | What it does |
| --- | --- |
| **Home** | Left to spend, spending ring, Moreki Score and a quick link to add an expense. |
| **Money** | Set a monthly budget, add and review expenses, saved on the phone. |
| **Plan** | One place to open every money tool. |
| **Ask Moreki** | Saved answers to 185 common money questions (63 answers, 16 topics) with a simple matcher. **Not live AI**, and it says so on screen. Answers can open the matching tool. |
| **Emergency Fund Builder** | Enter monthly essentials, choose a 1, 3 or 6 month goal, log savings, see progress, milestones and an estimated finish month. |
| **Family Contribution Calculator** | Works out what is safe to send family each month after essentials, savings and a 10% personal buffer, and says whether an amount asked for is comfortable, tight or too much. |
| **Profile** | Name, payday (with next-payday countdown), language choice, privacy and about notes. |
| **Home-screen widget** | Android widget showing "Left to spend" and the Moreki Score. Android only. |

## What is not built yet (honest list)

- Sign-in (Firebase Auth), cloud sync, Firestore, push notifications and a REST API. Data is saved **on the phone only**.
- Translations: the language picker saves a choice, but the app is **English only** for now. French, Tshivenda and siSwati drafts will need review by fluent speakers before release.
- The other planned workflows: Salary Diagnosis, Credit Score Monitoring, Tax Return Made Simple, Side Hustle Tracker, Funeral Cover and Medical Aid Guide, Crisis Mode. They show as "Coming soon".
- Light theme, iOS build (no Mac available, so iOS is prepared but untested).

Moreki never fakes credit scores, tax submissions or integrations, and never moves real money.

## How it is built

- **Flutter / Dart**, state with plain `ChangeNotifier` and `ListenableBuilder`.
- **Money is whole cents** (`int`) everywhere, never `double`.
- **Rules live in pure Dart** (no Flutter), so they are easy to test. No AI does any arithmetic.
- Every feature uses four folders under `lib/features/<feature>/`:
    - `domain`: rules and data shapes (pure Dart)
    - `data`: stores that save and load (`shared_preferences` today, built behind an interface so Firebase can replace it)
    - `application`: controllers
    - `presentation`: screens
- Saved data that is damaged is ignored (the app starts fresh) instead of crashing, and sensitive data is never logged.
- Design: OLED-black dark theme, Manrope font, one accent colour per screen.

```
lib/
  core/        theme, shared widgets, money formatting
  features/
    coach/ dashboard/ emergency_fund/ family_contribution/
    money/ profile/ shell/ widget/
test/          unit and widget tests
assets/coach/  saved coach answers (coach_en.json)
```

## Run it

You need the Flutter SDK (Dart 3.13 or newer) and an Android emulator or phone.

```
flutter pub get
flutter run
```

## Test it

```
flutter test
```

Some tests deliberately force failures (damaged saved data, a widget update that fails), so you will see log lines such as `Moreki: saved money data could not be read`. That is expected. The same tests run automatically on every push through GitHub Actions (`.github/workflows/flutter-tests.yml`).

## Privacy

Everything stays on the phone. There is no account and nothing is sent anywhere. Moreki gives guidance, not financial advice.

## Facts to re-check before a public launch

The Coach contains figures and contacts that change over time. Verify these against official sources first: the NCR contact number, the SADAG helpline, the UIF earnings cap, the tax-free savings limits and the rule for provisional tax on side income (deliberately left unverified).

## AI use

This project was built with help from an AI assistant (Claude) for planning, code and tests. All code was run and tested by the author, and all business rules are covered by automated tests.

## Credits

Cubic Code, Nelspruit, South Africa.