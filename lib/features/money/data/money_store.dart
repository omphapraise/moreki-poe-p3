import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:moreki/features/money/domain/expense.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Everything we save about a user's money.
class MoneyData {
  const MoneyData({this.budgetCents = 0, this.expenses = const []});

  final int budgetCents;
  final List<Expense> expenses;
}

/// Where the money data is kept. The app only talks to this interface,
/// so we can swap in Firebase or a database later without touching screens.
abstract class MoneyStore {
  Future<MoneyData> load();
  Future<void> save(MoneyData data);
}

/// Saves the data on the phone as one block of JSON.
/// NOTE: one slot per device for now. Once users can log in, the key will
/// include the user's id so accounts never share data (a bug in the old app).
class SharedPrefsMoneyStore implements MoneyStore {
  static const _key = 'moreki_money_v1';

  @override
  Future<MoneyData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const MoneyData();

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final expenses = (map['expenses'] as List<dynamic>)
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList();
      return MoneyData(
        budgetCents: map['budgetCents'] as int,
        expenses: expenses,
      );
    } catch (_) {
      // Saved data was damaged: start fresh instead of crashing.
      // (We never print the data itself, only that it failed.)
      debugPrint('Moreki: saved money data could not be read');
      return const MoneyData();
    }
  }

  @override
  Future<void> save(MoneyData data) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode({
      'budgetCents': data.budgetCents,
      'expenses': data.expenses.map((e) => e.toJson()).toList(),
    });
    await prefs.setString(_key, json);
  }
}