import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moreki/core/format/money_format.dart';
import 'package:moreki/core/format/money_parts.dart';
import 'package:moreki/core/l10n/app_language.dart';
import 'package:moreki/core/l10n/app_strings.dart';
import 'package:moreki/core/theme/app_colors.dart';
import 'package:moreki/core/theme/app_spacing.dart';
import 'package:moreki/core/widgets/accent_glow.dart';
import 'package:moreki/core/widgets/hero_number.dart';
import 'package:moreki/core/widgets/moreki_data_row.dart';
import 'package:moreki/core/widgets/pill_segmented_control.dart';
import 'package:moreki/features/money/application/money_controller.dart';
import 'package:moreki/features/money/domain/expense.dart';

/// English names for the categories. Kept public because other files and
/// tests may use it. The Money screen itself shows the translated names
/// (money.cat.* keys, same English text).
String categoryLabel(ExpenseCategory c) {
  switch (c) {
    case ExpenseCategory.food:
      return 'Food and groceries';
    case ExpenseCategory.transport:
      return 'Transport (taxi, bus, petrol)';
    case ExpenseCategory.rent:
      return 'Rent';
    case ExpenseCategory.airtimeData:
      return 'Airtime and data';
    case ExpenseCategory.electricity:
      return 'Electricity';
    case ExpenseCategory.family:
      return 'Family';
    case ExpenseCategory.entertainment:
      return 'Entertainment';
    case ExpenseCategory.other:
      return 'Other';
  }
}

/// Translated category name for the Money screen.
String _categoryName(AppStrings s, ExpenseCategory c) {
  switch (c) {
    case ExpenseCategory.food:
      return s.get('money.cat.food');
    case ExpenseCategory.transport:
      return s.get('money.cat.transport');
    case ExpenseCategory.rent:
      return s.get('money.cat.rent');
    case ExpenseCategory.airtimeData:
      return s.get('money.cat.airtimeData');
    case ExpenseCategory.electricity:
      return s.get('money.cat.electricity');
    case ExpenseCategory.family:
      return s.get('money.cat.family');
    case ExpenseCategory.entertainment:
      return s.get('money.cat.entertainment');
    case ExpenseCategory.other:
      return s.get('money.cat.other');
  }
}

String _shortDate(AppStrings s, DateTime d) =>
    '${d.day} ${s.month(d.month)} ${d.year}';

/// Newest date first. Expenses on the same date keep "last added first".
List<Expense> _newestFirst(List<Expense> list) {
  final indexed = [for (var i = 0; i < list.length; i++) (i, list[i])];
  indexed.sort((a, b) {
    final byDate = b.$2.date.compareTo(a.$2.date);
    return byDate != 0 ? byDate : b.$1.compareTo(a.$1);
  });
  return [for (final x in indexed) x.$2];
}

/// The Money tab: set a budget, add expenses (on any date), see the list,
/// delete an expense (with Undo).
class MoneyPage extends StatefulWidget {
  const MoneyPage({super.key, required this.controller});

  final MoneyController controller;

  @override
  State<MoneyPage> createState() => _MoneyPageState();
}

class _MoneyPageState extends State<MoneyPage> {
  static const int _recentCount = 3;

  final _budgetField = TextEditingController();
  final _amountField = TextEditingController();
  final _noteField = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.food;
  DateTime? _date; // null = today
  int _view = 0; // 0 = Overview, 1 = Expenses
  bool _budgetBad = false;
  bool _amountBad = false;

  @override
  void dispose() {
    _budgetField.dispose();
    _amountField.dispose();
    _noteField.dispose();
    super.dispose();
  }

  bool get _dateIsToday =>
      _date == null || DateUtils.isSameDay(_date, DateTime.now());

  /// The date saved with the expense. Today keeps the real time; a picked
  /// day is saved at midday.
  DateTime _dateForExpense() {
    final now = DateTime.now();
    final d = _date;
    if (d == null || DateUtils.isSameDay(d, now)) return now;
    return DateTime(d.year, d.month, d.day, 12);
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? today,
      firstDate: DateTime(today.year - 1, 1, 1),
      lastDate: today,
    );
    if (picked == null || !mounted) return;
    setState(() => _date = picked);
  }

  void _saveBudget() {
    final cents = parseRandToCents(_budgetField.text);
    if (cents == null || cents <= 0) {
      setState(() => _budgetBad = true);
      return;
    }
    widget.controller.setBudgetCents(cents);
    FocusScope.of(context).unfocus();
    setState(() => _budgetBad = false);
  }

  void _addExpense() {
    final cents = parseRandToCents(_amountField.text);
    if (cents == null || cents <= 0) {
      setState(() => _amountBad = true);
      return;
    }
    widget.controller.addExpense(
      amountCents: cents,
      category: _category,
      date: _dateForExpense(),
      note: _noteField.text.trim(),
    );
    _amountField.clear();
    _noteField.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _amountBad = false;
      _date = null;
    });
  }

  /// Deletes an expense and offers Undo for a few seconds. Only the most
  /// recent delete can be undone.
  Future<void> _deleteExpense(Expense expense) async {
    final messenger = ScaffoldMessenger.of(context);
    final controller = widget.controller;
    final s = AppLanguage.of(context);
    final textStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: AppColors.darkTextPrimary);

    final removed = await controller.removeExpense(expense.id);
    if (removed == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(s.get('money.deleted'), style: textStyle),
          duration: const Duration(seconds: 6),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surface2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          action: SnackBarAction(
            label: s.get('money.undo'),
            textColor: AppColors.green,
            onPressed: () => controller.restoreExpense(removed),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AccentGlow(
      color: AppColors.green,
      child: SafeArea(
        child: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) => _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final s = AppLanguage.of(context);
    final c = widget.controller;
    final summary = c.summary;
    final budget = c.budgetCents;
    final sorted = _newestFirst(c.expenses);
    final hero = splitRandForDisplay(
      formatRand(budget > 0 ? summary.remainingCents : summary.spentCents),
    );
    final now = DateTime.now();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      children: [
        Semantics(
          header: true,
          child: Text(s.get('money.title'), style: text.headlineMedium),
        ),
        const SizedBox(height: AppSpacing.xl),
        HeroNumber(
          label: budget > 0 ? s.get('money.left') : s.get('money.spentLabel'),
          value: hero.whole,
          unit: hero.cents,
          caption: budget > 0
              ? s.format('money.caption', {
                  'spent': formatRand(summary.spentCents),
                  'budget': formatRand(budget),
                })
              : s.get('money.noBudgetCaption'),
        ),
        const SizedBox(height: AppSpacing.xl),
        PillSegmentedControl(
          labels: [
            s.get('money.view.overview'),
            s.get('money.view.expenses'),
          ],
          selectedIndex: _view,
          onChanged: (i) => setState(() => _view = i),
          accent: AppColors.green,
        ),
        const SizedBox(height: AppSpacing.xl),
        if (_view == 0) ...[
          _Panel(
            title: s.get('money.budget.title'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  budget > 0
                      ? s.format(
                          'money.budget.current',
                          {'amount': formatRand(budget)},
                        )
                      : s.get('money.budget.notSet'),
                  style: text.bodySmall?.copyWith(color: muted, fontSize: 13),
                ),
                const SizedBox(height: AppSpacing.xl),
                _AmountField(
                  key: const Key('budgetField'),
                  controller: _budgetField,
                  label: s.get('money.budget.field'),
                  errorText: _budgetBad ? s.get('money.budget.error') : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('saveBudgetButton'),
                    onPressed: _saveBudget,
                    child: Text(s.get('money.budget.save')),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Panel(
            title: s.get('money.add.title'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AmountField(
                  key: const Key('amountField'),
                  controller: _amountField,
                  label: s.get('money.add.amount'),
                  errorText: _amountBad ? s.get('money.add.error') : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                DropdownMenu<ExpenseCategory>(
                  expandedInsets: EdgeInsets.zero,
                  label: Text(s.get('money.add.category')),
                  initialSelection: _category,
                  onSelected: (cat) {
                    if (cat != null) setState(() => _category = cat);
                  },
                  dropdownMenuEntries: [
                    for (final cat in ExpenseCategory.values)
                      DropdownMenuEntry(
                        value: cat,
                        label: _categoryName(s, cat),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton.icon(
                  key: const Key('expenseDateButton'),
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: Text(
                    _dateIsToday
                        ? s.get('money.add.dateToday')
                        : s.format(
                            'money.add.date',
                            {'date': _shortDate(s, _date!)},
                          ),
                  ),
                ),
                if (_date != null &&
                    (_date!.year != now.year || _date!.month != now.month))
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      s.get('money.add.otherMonth'),
                      style:
                          text.bodySmall?.copyWith(color: muted, fontSize: 13),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  key: const Key('noteField'),
                  controller: _noteField,
                  inputFormatters: [LengthLimitingTextInputFormatter(60)],
                  style: text.bodyLarge,
                  decoration: _decoration(
                    s.get('money.add.note'),
                    hint: s.get('money.add.noteHint'),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('addExpenseButton'),
                    onPressed: _addExpense,
                    child: Text(s.get('money.add.button')),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(s.get('money.recent.title'), style: text.titleMedium),
          if (sorted.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                s.get('money.recent.empty'),
                style: text.bodyMedium?.copyWith(color: muted, fontSize: 14),
              ),
            )
          else ...[
            for (var i = 0; i < sorted.length && i < _recentCount; i++)
              _ExpenseRow(
                expense: sorted[i],
                showDivider: i < sorted.length - 1 && i < _recentCount - 1,
                onDelete: () => _deleteExpense(sorted[i]),
              ),
            if (sorted.length > _recentCount)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  key: const Key('seeAllExpensesButton'),
                  onPressed: () => setState(() => _view = 1),
                  child: Text(
                    s.format('money.recent.seeAll', {'n': '${sorted.length}'}),
                  ),
                ),
              ),
          ],
        ] else ...[
          Text(s.get('money.all.title'), style: text.titleMedium),
          if (sorted.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                s.get('money.all.empty'),
                style: text.bodyMedium?.copyWith(color: muted, fontSize: 14),
              ),
            )
          else
            for (var i = 0; i < sorted.length; i++)
              _ExpenseRow(
                expense: sorted[i],
                showDivider: i < sorted.length - 1,
                onDelete: () => _deleteExpense(sorted[i]),
              ),
        ],
      ],
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({
    required this.expense,
    required this.showDivider,
    required this.onDelete,
  });

  final Expense expense;
  final bool showDivider;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final s = AppLanguage.of(context);
    final date = _shortDate(s, expense.date);
    final title = _categoryName(s, expense.category);
    final amount = formatRand(expense.amountCents);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MorekiDataRow(
                title: title,
                subtitle: expense.note.isEmpty
                    ? date
                    : '$date \u00B7 ${expense.note}',
                value: amount,
                showDivider: false,
              ),
            ),
            IconButton(
              key: ValueKey('deleteExpense_${expense.id}'),
              tooltip: s.format(
                'money.deleteTooltip',
                {'title': title, 'amount': amount},
              ),
              onPressed: onDelete,
              color: muted,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: AppColors.hairline),
      ],
    );
  }
}

InputDecoration _decoration(
  String label, {
  String? errorText,
  bool rand = false,
  String? hint,
}) {
  return InputDecoration(
    labelText: label,
    errorText: errorText,
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textMuted),
    prefixText: rand ? 'R ' : null,
    // Always floated, so the "R" and the label show even when the field
    // is empty, and every field looks the same.
    floatingLabelBehavior: FloatingLabelBehavior.always,
    filled: true,
    fillColor: AppColors.surface2,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.lg,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide.none,
    ),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({
    super.key,
    required this.controller,
    required this.label,
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: _decoration(
        label,
        errorText: errorText,
        rand: true,
        hint: '0.00',
      ),
    );
  }
}
