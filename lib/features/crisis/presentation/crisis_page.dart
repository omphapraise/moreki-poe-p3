import 'package:flutter/material.dart';
import 'package:moreki/core/format/money_format.dart';
import 'package:moreki/core/l10n/app_language.dart';
import 'package:moreki/core/l10n/app_strings.dart';
import 'package:moreki/core/theme/app_colors.dart';
import 'package:moreki/core/theme/app_spacing.dart';
import 'package:moreki/core/widgets/accent_glow.dart';
import 'package:moreki/core/widgets/hero_number.dart';
import 'package:moreki/core/widgets/moreki_data_row.dart';
import 'package:moreki/features/crisis/application/crisis_controller.dart';
import 'package:moreki/features/crisis/domain/crisis.dart';

String _signed(int cents) =>
    cents < 0 ? '-${formatRand(-cents)}' : formatRand(cents);

/// Cents as plain typed text, like 250 or 12.50. Blank for zero.
String _plain(int cents) {
  if (cents <= 0) return '';
  final rand = cents ~/ 100;
  final rest = cents % 100;
  if (rest == 0) return '$rand';
  return '$rand.${rest.toString().padLeft(2, '0')}';
}

/// The Crisis Mode screen.
class CrisisPage extends StatefulWidget {
  const CrisisPage({super.key, required this.controller});

  final CrisisController controller;

  @override
  State<CrisisPage> createState() => _CrisisPageState();
}

class _CrisisPageState extends State<CrisisPage> {
  late final TextEditingController _income;
  late final TextEditingController _rent;
  late final TextEditingController _food;
  late final TextEditingController _transport;
  late final TextEditingController _debt;
  late final TextEditingController _other;

  /// Which fields (by position, 0 to 5) hold something we can't read.
  final Set<int> _bad = {};

  @override
  void initState() {
    super.initState();
    final p = widget.controller.plan;
    _income = TextEditingController(text: _plain(p.incomeCents));
    _rent = TextEditingController(text: _plain(p.rentCents));
    _food = TextEditingController(text: _plain(p.foodCents));
    _transport = TextEditingController(text: _plain(p.transportCents));
    _debt = TextEditingController(text: _plain(p.debtCents));
    _other = TextEditingController(text: _plain(p.otherCents));
  }

  @override
  void dispose() {
    _income.dispose();
    _rent.dispose();
    _food.dispose();
    _transport.dispose();
    _debt.dispose();
    _other.dispose();
    super.dispose();
  }

  /// Blank counts as zero. Anything unreadable or negative gives null.
  int? _read(TextEditingController c) {
    final raw = c.text.trim();
    if (raw.isEmpty) return 0;
    final cents = parseRandToCents(raw);
    if (cents == null || cents < 0) return null;
    return cents;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final lang = AppLanguage.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final controllers = [_income, _rent, _food, _transport, _debt, _other];
    final values = controllers.map(_read).toList();
    final bad = <int>{
      for (var i = 0; i < values.length; i++)
        if (values[i] == null) i,
    };
    setState(() {
      _bad
        ..clear()
        ..addAll(bad);
    });
    if (bad.isNotEmpty) return;

    final ok = await widget.controller.updatePlan(
      CrisisPlan(
        incomeCents: values[0]!,
        rentCents: values[1]!,
        foodCents: values[2]!,
        transportCents: values[3]!,
        debtCents: values[4]!,
        otherCents: values[5]!,
      ),
    );
    if (ok) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(lang.get('cm.saved'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final lang = AppLanguage.of(context);

    return Scaffold(
      body: AccentGlow(
        color: AppColors.red,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: lang.get('cm.back'),
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          lang.get('cm.title'),
                          style: text.headlineMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: widget.controller,
                  builder: (context, _) => _buildBody(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final lang = AppLanguage.of(context);
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final s = widget.controller.summary;

    final String caption;
    if (!s.hasData) {
      caption = lang.get('cm.hero.captionNone');
    } else if (s.incomeCents <= 0) {
      caption = lang.get('cm.hero.captionNoIncome');
    } else if (s.isShort) {
      caption = lang.get('cm.hero.captionShort');
    } else {
      caption = lang.format('cm.hero.captionOk', {
        'percent': '${s.essentialsPercent ?? 0}',
      });
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          lang.get('cm.intro'),
          style: text.bodyMedium?.copyWith(color: muted, fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.xl),
        HeroNumber(
          label: lang.get('cm.hero.label'),
          value: _signed(s.leftCents),
          caption: caption,
        ),
        const SizedBox(height: AppSpacing.xl),
        MorekiDataRow(
          title: lang.get('cm.row.income'),
          value: formatRand(s.incomeCents),
        ),
        MorekiDataRow(
          title: lang.get('cm.row.essentials'),
          value: formatRand(s.essentialsCents),
        ),
        MorekiDataRow(
          title: lang.get('cm.row.left'),
          value: _signed(s.leftCents),
          valueColor: s.isShort ? AppColors.red : AppColors.green,
          showDivider: false,
        ),
        const SizedBox(height: AppSpacing.xl),
        _Panel(
          title: lang.get('cm.panel.title'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field(lang, 'crisisIncomeField', _income, 'cm.field.income', 0),
              _field(lang, 'crisisRentField', _rent, 'cm.field.rent', 1),
              _field(lang, 'crisisFoodField', _food, 'cm.field.food', 2),
              _field(
                lang,
                'crisisTransportField',
                _transport,
                'cm.field.transport',
                3,
              ),
              _field(lang, 'crisisDebtField', _debt, 'cm.field.debt', 4),
              _field(lang, 'crisisOtherField', _other, 'cm.field.other', 5),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('saveCrisisButton'),
                  onPressed: _save,
                  child: Text(lang.get('cm.save')),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(lang.get('cm.steps.title'), style: text.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 1; i <= 5; i++)
          _StepRow(number: i, text: lang.get('cm.step$i')),
        const SizedBox(height: AppSpacing.xl),
        Text(
          lang.get('cm.note'),
          style: text.bodySmall?.copyWith(color: muted, fontSize: 13),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _field(
    AppStrings lang,
    String keyName,
    TextEditingController controller,
    String labelKey,
    int position,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: _Field(
        key: Key(keyName),
        controller: controller,
        label: lang.get(labelKey),
        errorText: _bad.contains(position) ? lang.get('cm.err.amount') : null,
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: style.labelMedium?.copyWith(color: AppColors.red),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(text, style: style.bodyLarge)),
        ],
      ),
    );
  }
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
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
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
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        prefixText: 'R ',
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
      ),
    );
  }
}
