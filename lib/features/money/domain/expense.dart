/// The spending categories, built around everyday South African costs.
/// The names here are internal keys; the words the user sees will come
/// from the translation files later (so they work in all 4 languages).
enum ExpenseCategory {
  food,
  transport, // taxi, bus, petrol
  rent,
  airtimeData,
  electricity, // prepaid electricity
  family, // money sent to or spent on family
  entertainment,
  other,
}

/// One recorded expense. Money is kept in whole cents (R12.50 = 1250)
/// so we never get rounding errors from decimals.
class Expense {
  const Expense({
    required this.id,
    required this.amountCents,
    required this.category,
    required this.date,
    this.note = '',
  });

  final String id;
  final int amountCents;
  final ExpenseCategory category;
  final DateTime date;
  final String note;

  /// Turns the expense into plain data that can be saved.
  Map<String, dynamic> toJson() => {
    'id': id,
    'amountCents': amountCents,
    'category': category.name,
    'date': date.toIso8601String(),
    'note': note,
  };

  /// Rebuilds an expense from saved data.
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      amountCents: json['amountCents'] as int,
      category: ExpenseCategory.values.firstWhere(
            (c) => c.name == json['category'],
        orElse: () => ExpenseCategory.other,
      ),
      date: DateTime.parse(json['date'] as String),
      note: (json['note'] as String?) ?? '',
    );
  }
}