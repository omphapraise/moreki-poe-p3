/// The numbers someone types in when money gets tight. Amounts are whole
/// cents (R12.50 = 1250). Nothing here is ever sent anywhere.
class CrisisPlan {
  const CrisisPlan({
    this.incomeCents = 0,
    this.rentCents = 0,
    this.foodCents = 0,
    this.transportCents = 0,
    this.debtCents = 0,
    this.otherCents = 0,
  });

  /// Throws if the data is damaged, so the store can start fresh.
  factory CrisisPlan.fromJson(Map<String, dynamic> json) {
    final plan = CrisisPlan(
      incomeCents: json['incomeCents'] as int,
      rentCents: json['rentCents'] as int,
      foodCents: json['foodCents'] as int,
      transportCents: json['transportCents'] as int,
      debtCents: json['debtCents'] as int,
      otherCents: json['otherCents'] as int,
    );
    final all = [
      plan.incomeCents,
      plan.rentCents,
      plan.foodCents,
      plan.transportCents,
      plan.debtCents,
      plan.otherCents,
    ];
    if (all.any((v) => v < 0)) {
      throw const FormatException('amounts cannot be negative');
    }
    return plan;
  }

  final int incomeCents;
  final int rentCents;
  final int foodCents;
  final int transportCents;
  final int debtCents;
  final int otherCents;

  CrisisPlan copyWith({
    int? incomeCents,
    int? rentCents,
    int? foodCents,
    int? transportCents,
    int? debtCents,
    int? otherCents,
  }) {
    return CrisisPlan(
      incomeCents: incomeCents ?? this.incomeCents,
      rentCents: rentCents ?? this.rentCents,
      foodCents: foodCents ?? this.foodCents,
      transportCents: transportCents ?? this.transportCents,
      debtCents: debtCents ?? this.debtCents,
      otherCents: otherCents ?? this.otherCents,
    );
  }

  Map<String, dynamic> toJson() => {
    'incomeCents': incomeCents,
    'rentCents': rentCents,
    'foodCents': foodCents,
    'transportCents': transportCents,
    'debtCents': debtCents,
    'otherCents': otherCents,
  };
}

/// The worked-out picture for a [CrisisPlan].
class CrisisSummary {
  const CrisisSummary({
    required this.incomeCents,
    required this.essentialsCents,
  });

  final int incomeCents;
  final int essentialsCents;

  /// Income minus essentials. Negative means you are short.
  int get leftCents => incomeCents - essentialsCents;

  bool get isShort => leftCents < 0;

  /// True once the person has typed in anything at all.
  bool get hasData => incomeCents > 0 || essentialsCents > 0;

  /// Essentials as a whole percent of income (rounded). Null when there is
  /// no income, because a percent of nothing means nothing.
  int? get essentialsPercent {
    if (incomeCents <= 0) return null;
    return (essentialsCents * 100 + incomeCents ~/ 2) ~/ incomeCents;
  }
}

/// All the Crisis Mode maths. Pure Dart, no Flutter, fully tested.
class CrisisCalculator {
  const CrisisCalculator._();

  static CrisisSummary summarise(CrisisPlan plan) {
    final essentials = plan.rentCents +
        plan.foodCents +
        plan.transportCents +
        plan.debtCents +
        plan.otherCents;
    return CrisisSummary(
      incomeCents: plan.incomeCents,
      essentialsCents: essentials,
    );
  }
}
