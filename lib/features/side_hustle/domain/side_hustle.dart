/// Whether an entry is money coming in or money going out.
enum HustleEntryType { income, cost }

/// One bit of side hustle money. Amounts are whole cents (R12.50 = 1250).
class HustleEntry {
  const HustleEntry({
    required this.id,
    required this.type,
    required this.amountCents,
    required this.date,
    this.note = '',
  });

  /// Throws if the data is damaged, so the store can start fresh.
  factory HustleEntry.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String;
    final type = HustleEntryType.values.firstWhere((t) => t.name == typeName);
    final amount = json['amountCents'] as int;
    if (amount <= 0) throw const FormatException('amount must be above zero');
    return HustleEntry(
      id: json['id'] as String,
      type: type,
      amountCents: amount,
      date: DateTime.parse(json['date'] as String),
      note: (json['note'] as String?) ?? '',
    );
  }

  final String id;
  final HustleEntryType type;
  final int amountCents;
  final DateTime date;
  final String note;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'amountCents': amountCents,
    'date': date.toIso8601String(),
    'note': note,
  };
}

/// The worked-out picture of the side hustle.
class HustleSummary {
  const HustleSummary({
    required this.incomeCents,
    required this.costCents,
    required this.entryCount,
  });

  final int incomeCents;
  final int costCents;
  final int entryCount;

  /// What you keep: income minus costs. Can be negative.
  int get keepCents => incomeCents - costCents;

  bool get isLoss => keepCents < 0;

  /// What you keep as a whole percent of income (rounded). Null when there
  /// is no income, because a percent of nothing means nothing.
  int? get keepPercent {
    if (incomeCents <= 0) return null;
    final n = keepCents * 100;
    if (n >= 0) return (n + incomeCents ~/ 2) ~/ incomeCents;
    return -((-n + incomeCents ~/ 2) ~/ incomeCents);
  }
}

/// All the side hustle maths. Pure Dart, no Flutter, fully tested.
class SideHustleCalculator {
  const SideHustleCalculator._();

  /// Adds up [entries]. If [month] is given, only entries in that calendar
  /// month (same year and month) are counted.
  static HustleSummary summarise(
    List<HustleEntry> entries, {
    DateTime? month,
  }) {
    var income = 0;
    var cost = 0;
    var count = 0;
    for (final e in entries) {
      if (month != null &&
          (e.date.year != month.year || e.date.month != month.month)) {
        continue;
      }
      count++;
      if (e.type == HustleEntryType.income) {
        income += e.amountCents;
      } else {
        cost += e.amountCents;
      }
    }
    return HustleSummary(
      incomeCents: income,
      costCents: cost,
      entryCount: count,
    );
  }
}
