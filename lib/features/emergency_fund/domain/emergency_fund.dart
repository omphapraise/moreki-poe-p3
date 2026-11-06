/// One saving put into the emergency fund.
class FundDeposit {
  const FundDeposit({
    required this.id,
    required this.amountCents,
    required this.date,
  });

  factory FundDeposit.fromJson(Map<String, dynamic> json) => FundDeposit(
    id: json['id'] as String,
    amountCents: json['amountCents'] as int,
    date: DateTime.parse(json['date'] as String),
  );

  final String id;
  final int amountCents;
  final DateTime date;

  Map<String, dynamic> toJson() => {
    'id': id,
    'amountCents': amountCents,
    'date': date.toIso8601String(),
  };
}

/// What the person has told us about their emergency fund. Money is in
/// whole cents (R12.50 = 1250).
class EmergencyFundPlan {
  const EmergencyFundPlan({
    this.essentialsCents = 0,
    this.targetMonths = 3,
    this.monthlyContributionCents = 0,
  });

  /// Rent, food, transport and bills for one month.
  final int essentialsCents;

  /// How many months of essentials the goal covers (1, 3 or 6).
  final int targetMonths;

  /// How much the person plans to save each month (0 = not set).
  final int monthlyContributionCents;

  EmergencyFundPlan copyWith({
    int? essentialsCents,
    int? targetMonths,
    int? monthlyContributionCents,
  }) =>
      EmergencyFundPlan(
        essentialsCents: essentialsCents ?? this.essentialsCents,
        targetMonths: targetMonths ?? this.targetMonths,
        monthlyContributionCents:
        monthlyContributionCents ?? this.monthlyContributionCents,
      );
}

/// A stepping stone on the way to the goal. [months] == 0 means
/// "one week of essentials".
class FundMilestone {
  const FundMilestone({
    required this.months,
    required this.targetCents,
    required this.reached,
  });

  final int months;
  final int targetCents;
  final bool reached;
}

/// The worked-out picture of the fund.
class FundProgress {
  const FundProgress({
    required this.targetCents,
    required this.savedCents,
    required this.remainingCents,
    required this.fraction,
    required this.isComplete,
    required this.milestones,
    this.monthsToGoal,
    this.estimatedFinish,
  });

  final int targetCents;
  final int savedCents;
  final int remainingCents;

  /// 0.0 to 1.0.
  final double fraction;
  final bool isComplete;
  final List<FundMilestone> milestones;

  /// Whole months to reach the goal at the planned monthly saving.
  /// 0 when the goal is reached. Null when it can't be estimated
  /// (no goal, or no monthly saving set).
  final int? monthsToGoal;

  /// The month the goal would be reached (an estimate).
  final DateTime? estimatedFinish;
}

/// All the emergency fund maths. Pure Dart, no Flutter, fully tested.
class EmergencyFundCalculator {
  const EmergencyFundCalculator._();

  /// The goal lengths the person can choose, in months.
  static const List<int> targetOptions = [1, 3, 6];

  /// About one week of essentials: 7/30 of a month, rounded to the cent.
  static int weekOfEssentialsCents(int essentialsCents) =>
      (essentialsCents * 7 + 15) ~/ 30;

  static FundProgress calculate({
    required EmergencyFundPlan plan,
    required int savedCents,
    required DateTime today,
  }) {
    final essentials = plan.essentialsCents < 0 ? 0 : plan.essentialsCents;
    final monthly = plan.monthlyContributionCents;
    final saved = savedCents < 0 ? 0 : savedCents;

    final target = essentials * plan.targetMonths;
    final remaining = target > saved ? target - saved : 0;
    final fraction =
    target <= 0 ? 0.0 : (saved / target).clamp(0.0, 1.0).toDouble();
    final complete = target > 0 && saved >= target;

    int? monthsToGoal;
    DateTime? finish;
    if (complete) {
      monthsToGoal = 0;
    } else if (target > 0 && monthly > 0) {
      monthsToGoal = (remaining + monthly - 1) ~/ monthly; // round up
      finish = DateTime(today.year, today.month + monthsToGoal);
    }

    final milestones = <FundMilestone>[];
    if (essentials > 0) {
      final week = weekOfEssentialsCents(essentials);
      milestones.add(
        FundMilestone(months: 0, targetCents: week, reached: saved >= week),
      );
      for (final m in targetOptions) {
        if (m <= plan.targetMonths) {
          final cents = essentials * m;
          milestones.add(
            FundMilestone(
              months: m,
              targetCents: cents,
              reached: saved >= cents,
            ),
          );
        }
      }
    }

    return FundProgress(
      targetCents: target,
      savedCents: saved,
      remainingCents: remaining,
      fraction: fraction,
      isComplete: complete,
      milestones: milestones,
      monthsToGoal: monthsToGoal,
      estimatedFinish: finish,
    );
  }
}