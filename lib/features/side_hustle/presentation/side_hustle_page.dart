import 'package:flutter/material.dart';
import 'package:moreki/core/format/money_format.dart';
import 'package:moreki/core/l10n/app_language.dart';
import 'package:moreki/core/theme/app_colors.dart';
import 'package:moreki/core/theme/app_spacing.dart';
import 'package:moreki/core/widgets/accent_glow.dart';
import 'package:moreki/core/widgets/hero_number.dart';
import 'package:moreki/core/widgets/moreki_data_row.dart';
import 'package:moreki/features/side_hustle/application/side_hustle_controller.dart';
import 'package:moreki/features/side_hustle/domain/side_hustle.dart';

String _signed(int cents) =>
    cents < 0 ? '-${formatRand(-cents)}' : formatRand(cents);

/// The Side Hustle Tracker screen.
class SideHustlePage extends StatefulWidget {
  const SideHustlePage({super.key, required this.controller});

  final SideHustleController controller;

  @override
  State<SideHustlePage> createState() => _SideHustlePageState();
}

class _SideHustlePageState extends State<SideHustlePage> {
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _note = TextEditingController();
  HustleEntryType _type = HustleEntryType.income;
  bool _amountBad = false;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    FocusScope.of(context).unfocus();
    final cents = parseRandToCents(_amount.text);
    if (cents == null || cents <= 0) {
      setState(() => _amountBad = true);
      return;
    }
    setState(() => _amountBad = false);
    final ok = await widget.controller.addEntry(
      type: _type,
      amountCents: cents,
      note: _note.text,
    );
    if (ok) {
      _amount.clear();
      _note.clear();
    }
  }

  Future<void> _delete(HustleEntry entry) async {
    final lang = AppLanguage.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await widget.controller.deleteEntry(entry.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(lang.get('sh.deleted')),
          action: SnackBarAction(
            label: lang.get('sh.undo'),
            onPressed: () => widget.controller.restoreEntry(entry),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final lang = AppLanguage.of(context);

    return Scaffold(
      body: AccentGlow(
        color: AppColors.orange,
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
                      tooltip: lang.get('sh.back'),
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          lang.get('sh.title'),
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
    final c = widget.controller;
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final month = c.thisMonth;
    final all = c.allTime;
    final entries = c.entries;

    final String caption;
    if (month.entryCount == 0) {
      caption = lang.get('sh.hero.captionNone');
    } else if (month.incomeCents <= 0) {
      caption = lang.get('sh.hero.captionNoIncome');
    } else if (month.isLoss) {
      caption = lang.get('sh.hero.captionLoss');
    } else {
      caption = lang.format('sh.hero.captionKeep', {
        'percent': '${month.keepPercent ?? 0}',
      });
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          lang.get('sh.intro'),
          style: text.bodyMedium?.copyWith(color: muted, fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.xl),
        HeroNumber(
          label: lang.get('sh.hero.label'),
          value: _signed(month.keepCents),
          caption: caption,
        ),
        const SizedBox(height: AppSpacing.xl),
        MorekiDataRow(
          title: lang.get('sh.row.income'),
          value: formatRand(month.incomeCents),
        ),
        MorekiDataRow(
          title: lang.get('sh.row.costs'),
          value: formatRand(month.costCents),
        ),
        MorekiDataRow(
          title: lang.get('sh.row.allTime'),
          value: _signed(all.keepCents),
          valueColor: AppColors.orange,
          showDivider: false,
        ),
        const SizedBox(height: AppSpacing.xl),
        _Panel(
          title: lang.get('sh.panel.title'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<HustleEntryType>(
                  key: const Key('sideHustleTypeToggle'),
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: HustleEntryType.income,
                      label: Text(lang.get('sh.type.income')),
                    ),
                    ButtonSegment(
                      value: HustleEntryType.cost,
                      label: Text(lang.get('sh.type.cost')),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (s) => setState(() => _type = s.first),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _Field(
                key: const Key('sideHustleAmountField'),
                controller: _amount,
                label: lang.get('sh.field.amount'),
                errorText: _amountBad ? lang.get('sh.err.amount') : null,
                money: true,
              ),
              const SizedBox(height: AppSpacing.lg),
              _Field(
                key: const Key('sideHustleNoteField'),
                controller: _note,
                label: lang.get('sh.field.note'),
                hint: lang.get('sh.field.noteHint'),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('addSideHustleButton'),
                  onPressed: _add,
                  child: Text(lang.get('sh.add')),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(lang.get('sh.recent.title'), style: text.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        if (entries.isEmpty)
          Text(
            lang.get('sh.recent.empty'),
            style: text.bodyMedium?.copyWith(color: muted, fontSize: 14),
          )
        else
          for (final e in entries.take(20))
            _EntryRow(
              entry: e,
              onDelete: () => _delete(e),
            ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          lang.get('sh.note'),
          style: text.bodySmall?.copyWith(color: muted, fontSize: 13),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry, required this.onDelete});

  final HustleEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguage.of(context);
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final isIncome = entry.type == HustleEntryType.income;
    final title = entry.note.isEmpty
        ? lang.get(isIncome ? 'sh.type.income' : 'sh.type.cost')
        : entry.note;
    final amount = formatRand(entry.amountCents);
    final date = '${entry.date.day} ${lang.month(entry.date.month)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
            color: isIncome ? AppColors.green : AppColors.orange,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.bodyLarge),
                Text(
                  date,
                  style: text.bodySmall?.copyWith(color: muted, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            isIncome ? '+$amount' : '-$amount',
            style: text.bodyLarge?.copyWith(
              color: isIncome ? AppColors.green : AppColors.orange,
            ),
          ),
          IconButton(
            tooltip: lang.format('sh.deleteTooltip', {
              'title': title,
              'amount': amount,
            }),
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
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
    this.hint,
    this.errorText,
    this.money = false,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? errorText;
  final bool money;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: money
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixText: money ? 'R ' : null,
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
