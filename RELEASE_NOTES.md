# Moreki 1.0.0 (build 1) - Release Notes

Moreki is a South African financial-coaching app for 18-35s, by Cubic Code.
First released: 1 November 2026. Updated: 4 November 2026 (daily spending chart, restyled Moreki Score, English, French and Afrikaans). Platform: Android. iOS is prepared but not built or tested.

## What's in this release

- Home: your money picture at a glance, in Rand, with an Overview view and a Spending now view.
- Moreki Score: a 0 to 100 score shown as a ring, with your budget used and your biggest spend beside it. It stays locked until you have set a budget and logged 3 expenses on 2 different days, so it never shows a made-up number. It is not a credit score.
- Daily spending chart: a bar chart of what you spent each day, built from your real dated expenses, with today's bar highlighted.
- Money tab: set a monthly budget, add and view expenses. Amounts are stored as whole cents, never decimals, so the maths stays exact. Expenses are listed newest first by their date, and back-dated expenses land in the right place.
- Plan: your money tools in one place. Three tools are live (Ask Moreki, Emergency Fund Builder, Family Contribution Calculator). Six more are shown as Coming soon.
- Ask Moreki: saved answers to common money questions, with a status label and sources on each answer. It does not use a live AI connection.
- Emergency Fund Builder: set a goal in months of essential costs, add what you save, see milestones and an estimate of when you will get there.
- Family Contribution Calculator: work out a safe amount to send your family each month after your essentials, savings and a personal buffer, with a plain-language verdict.
- Languages: English, French and Afrikaans. Pick one on the Profile tab and the app switches.
- Profile: your name, payday and language.
- Android home-screen widget: a Moreki widget you can add to your home screen.
- Delete all data: remove everything Moreki has stored on your device in one action.

## Quality and safety

- 237 automated tests pass. Static analysis reports 0 errors and 0 warnings (a few harmless style hints remain).
- All money maths is deterministic and tested. No AI does arithmetic.
- Sensitive data is never written to logs.
- No real money is moved. Moreki does not connect to banks and shows no credit scores.
- The score ring was checked on screen in both states: locked (lock icon, no score) and unlocked (20 / 100 from real logged expenses).
- Expense ordering was checked on screen with back-dated expenses (29 Oct to 2 Nov), and the monthly total only counts the current month.

## Languages (honest notes)

- English, French and Afrikaans are in this build. Tshivenda and siSwati are planned, not included in this build. If one of those was saved earlier, the app falls back to English.
- French and Afrikaans were drafted by an AI and should get a fluent speaker's skim of the money terms.
- Ask Moreki's screen text is translated, but its saved answers, topic names, related questions and source titles are English only for now.
- The system date-picker dialog stays in English.

## Known limits (honest list)

- Your data is stored on your device only. There is no account, no cloud sync and no backup.
- No REST API, no push notifications.
- Six Plan tools are Coming soon and not built: Salary Diagnosis, Credit Score Monitoring, Tax Return Made Simple, Side Hustle Tracker, Funeral Cover and Medical Aid Guide, Crisis Mode.
- Not yet verified: large-cents display on the home-screen widget.
- Tested on an Android emulator. A physical-phone test is still to come.
- Coach reference figures (NCR and SADAG numbers, UIF cap, tax-free savings limit) need a final check before public launch. The provisional-tax rule is deliberately left out until verified.
