/// What the person has told us about their month. Money is in whole cents
/// (R12.50 = 1250).
class FamilyContributionPlan {
  const FamilyContributionPlan({
    this.takeHomeCents = 0,
    this.essentialsCents = 0,
    this.savingsCents = 0,
    this.requestedCents = 0,
  });

  /// Pay after tax, per month.
  final int takeHomeCents;

  /// The person's own rent, food, transport, data and debt payments.
  final int essentialsCents;

  /// What the person saves for themselves each month (0 = none).
  final int savingsCents;

  /// What the family is asking for each month (0 = no specific amount).
  final int requestedCents;
}

/// How the amount the family asked for fits the person's month.
enum FamilyAffordability {
  /// No amount was asked for.
  none,

  /// Within the safe amount.
  comfortable,

  /// Possible, but it uses part of the personal buffer.
  tight,

  /// More than the month can carry after essentials and savings.
  tooMuch,
}

/// The worked-out picture.
class FamilyContributionResult {
  const FamilyContributionResult({
    required this.takeHomeCents,
    required this.essentialsCents,
    required this.savingsCents,
    required this.bufferCents,
    required this.roomCents,
    required this.safeCents,
    required this.safePercent,
    required this.requestedCents,
    required this.affordability,
    required this.shortfallCents,
    required this.leftAfterRequestCents,
  });

  final int takeHomeCents;
  final int essentialsCents;
  final int savingsCents;

  /// Money kept for the person (a share of take-home).
  final int bufferCents;

  /// Take-home minus essentials and savings, before the buffer (never below 0).
  final int roomCents;

  /// The amount that is safe to send each month (never below 0).
  final int safeCents;

  /// [safeCents] as a whole-number percent of take-home.
  final int safePercent;

  final int requestedCents;
  final FamilyAffordability affordability;

  /// How far the request is above [safeCents] (0 if it is not).
  final int shortfallCents;

  /// What is left of the month after essentials, savings and the request.
  /// Can be negative.
  final int leftAfterRequestCents;
}

/// All the family contribution maths. Pure Dart, no Flutter, fully tested.
class FamilyContributionCalculator {
  const FamilyContributionCalculator._();

  /// The share of take-home kept for the person. A rule of thumb, not a law.
  static const int bufferPercent = 10;

  /// [bufferPercent] of take-home, rounded to the cent.
  static int bufferCents(int takeHomeCents) =>
      (takeHomeCents * bufferPercent + 50) ~/ 100;

  static FamilyContributionResult calculate(FamilyContributionPlan plan) {
    final takeHome = plan.takeHomeCents < 0 ? 0 : plan.takeHomeCents;
    final essentials = plan.essentialsCents < 0 ? 0 : plan.essentialsCents;
    final savings = plan.savingsCents < 0 ? 0 : plan.savingsCents;
    final requested = plan.requestedCents < 0 ? 0 : plan.requestedCents;

    final buffer = bufferCents(takeHome);
    final rawRoom = takeHome - essentials - savings;
    final room = rawRoom > 0 ? rawRoom : 0;
    final safe = room - buffer > 0 ? room - buffer : 0;
    final percent =
    takeHome <= 0 ? 0 : (safe * 100 + takeHome ~/ 2) ~/ takeHome;

    FamilyAffordability affordability;
    if (requested <= 0) {
      affordability = FamilyAffordability.none;
    } else if (requested <= safe) {
      affordability = FamilyAffordability.comfortable;
    } else if (requested <= room) {
      affordability = FamilyAffordability.tight;
    } else {
      affordability = FamilyAffordability.tooMuch;
    }

    return FamilyContributionResult(
      takeHomeCents: takeHome,
      essentialsCents: essentials,
      savingsCents: savings,
      bufferCents: buffer,
      roomCents: room,
      safeCents: safe,
      safePercent: percent,
      requestedCents: requested,
      affordability: affordability,
      shortfallCents: requested > safe ? requested - safe : 0,
      leftAfterRequestCents: takeHome - essentials - savings - requested,
    );
  }
}