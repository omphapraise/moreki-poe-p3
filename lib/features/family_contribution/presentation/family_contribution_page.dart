import 'package:flutter/material.dart';
import 'package:moreki/core/format/money_format.dart';
import 'package:moreki/core/l10n/app_language.dart';
import 'package:moreki/core/theme/app_colors.dart';
import 'package:moreki/core/theme/app_spacing.dart';
import 'package:moreki/core/widgets/accent_glow.dart';
import 'package:moreki/core/widgets/hero_number.dart';
import 'package:moreki/core/widgets/moreki_data_row.dart';
import 'package:moreki/features/family_contribution/application/family_contribution_controller.dart';
import 'package:moreki/features/family_contribution/domain/family_contribution.dart';

/// 25000 cents -> "250", 1250 cents -> "12.50", 0 -> "".
String _centsToInput(int cents) {
  if (cents <= 0) return '';
  final rands = cents ~/ 100;
  final rest = cents % 100;
  return rest == 0 ? '$rands' : '$rands.${rest.toString().padLeft(2, '0')}';
}

/// 0 = fine, 1 = missing, 2 = not a valid amount.
int _flagFor(String text, int? cents) {
  if (text.trim().isEmpty) return 1;
  if (cents == null) return 2;
  return 0;
}

String? _errorText(BuildContext context, int flag, String missingKey) {
  final lang = AppLanguage.of(context);
  if (flag == 1) return lang.get(missingKey);
  if (flag == 2) return lang.get('fam.err.amount');
  return null;
}

class _Verdict {
  const _Verdict(this.title, this.body, this.color, this.icon);

  final String title;
  final String body;
  final Color color;
  final IconData icon;
}

_Verdict _verdictFor(BuildContext context, FamilyContributionResult r) {
  final lang = AppLanguage.of(context);
  final asked = formatRand(r.requestedCents);
  switch (r.affordability) {
    case FamilyAffordability.comfortable:
      return _Verdict(
        lang.get('fam.v.comfortable.title'),
        lang.format('fam.v.comfortable.body', {
          'asked': asked,
          'left': formatRand(r.leftAfterRequestCents),
        }),
        AppColors.green,
        Icons.check_circle_outline,
      );
    case FamilyAffordability.tight:
      return _Verdict(
        lang.get('fam.v.tight.title'),
        lang.format('fam.v.tight.body', {
          'asked': asked,
          'shortfall': formatRand(r.shortfallCents),
        }),
        AppColors.yellow,
        Icons.info_outline,
      );
    case FamilyAffordability.tooMuch:
      final body = r.safeCents > 0
          ? lang.format('fam.v.tooMuch.bodySafe', {
              'asked': asked,
              'shortfall': formatRand(r.shortfallCents),
              'safe': formatRand(r.safeCents),
            })
          : lang.get('fam.v.tooMuch.bodyNone');
      return _Verdict(
        lang.get('fam.v.tooMuch.title'),
        body,
        AppColors.orange,
        Icons.error_outline,
      );
    case FamilyAffordability.none:
      return const _Verdict('', '', AppColors.yellow, Icons.info_outline);
  }
}

/// The Family Contribution Calculator screen.
class FamilyContributionPage extends StatefulWidget {
  const FamilyContributionPage({super.key, required this.controller});

  final FamilyContributionController controller;

  @override
  State<FamilyContributionPage> createState() => _FamilyContributionPageState();
}

class _FamilyContributionPageState extends State<FamilyContributionPage> {
  final TextEditingController _takeHome = TextEditingController();
  final TextEditingController _essentials = TextEditingController();
  final TextEditingController _savings = TextEditingController();
  final TextEditingController _requested = TextEditingController();

  // 0 = fine, 1 = missing, 2 = bad amount. Translated at build time.
  int _takeHomeFlag = 0;
  int _essentialsFlag = 0;
  bool _savingsBad = false;
  bool _requestedBad = false;

  @override
  void initState() {
    super.initState();
    final plan = widget.controller.plan;
    _takeHome.text = _centsToInput(plan.takeHomeCents);
    _essentials.text = _centsToInput(plan.essentialsCents);
    _savings.text = _centsToInput(plan.savingsCents);
    _requested.text = _centsToInput(plan.requestedCents);
  }

  @override
  void dispose() {
    _takeHome.dispose();
    _essentials.dispose();
    _savings.dispose();
    _requested.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    FocusScope.of(context).unfocus();

    final takeHome = parseRandToCents(_takeHome.text);
    final essentials = parseRandToCents(_essentials.text);
    final savingsText = _savings.text.trim();
    final requestedText = _requested.text.trim();
    final savings = savingsText.isEmpty ? 0 : parseRandToCents(savingsText);
    final requested =
        requestedText.isEmpty ? 0 : parseRandToCents(requestedText);

    var takeHomeFlag = _flagFor(_takeHome.text, takeHome);
    if (takeHomeFlag == 0 && takeHome == 0) takeHomeFlag = 1;
    final essentialsFlag = _flagFor(_essentials.text, essentials);
    final savingsBad = savings == null;
    final requestedBad = requested == null;

    setState(() {
      _takeHomeFlag = takeHomeFlag;
      _essentialsFlag = essentialsFlag;
      _savingsBad = savingsBad;
      _requestedBad = requestedBad;
    });

    if (takeHomeFlag != 0 ||
        essentialsFlag != 0 ||
        savingsBad ||
        requestedBad) {
      return;
    }

    await widget.controller.savePlan(
      takeHomeCents: takeHome!,
      essentialsCents: essentials!,
      savingsCents: savings,
      requestedCents: requested,
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final lang = AppLanguage.of(context);

    return Scaffold(
      body: AccentGlow(
        color: AppColors.yellow,
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
                      tooltip: lang.get('fam.back'),
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          lang.get('fam.title'),
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
    final result = c.result;
    final hasPlan = c.hasPlan;
    final verdict = _verdictFor(context, result);
    final buffer = '${FamilyContributionCalculator.bufferPercent}';

    final String heroCaption;
    if (!hasPlan) {
      heroCaption = lang.get('fam.hero.captionNone');
    } else if (result.safeCents > 0) {
      heroCaption = lang.format('fam.hero.captionSafe', {
        'percent': '${result.safePercent}',
      });
    } else {
      heroCaption = lang.get('fam.hero.captionZero');
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          lang.get('fam.intro'),
          style: text.bodyMedium?.copyWith(color: muted, fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.xl),
        HeroNumber(
          label: lang.get('fam.hero.label'),
          value: formatRand(result.safeCents),
          caption: heroCaption,
        ),
        if (hasPlan) ...[
          const SizedBox(height: AppSpacing.xl),
          MorekiDataRow(
            title: lang.get('fam.row.takeHome'),
            value: formatRand(result.takeHomeCents),
          ),
          MorekiDataRow(
            title: lang.get('fam.row.essentials'),
            value: formatRand(result.essentialsCents),
          ),
          MorekiDataRow(
            title: lang.get('fam.row.savings'),
            value: formatRand(result.savingsCents),
          ),
          MorekiDataRow(
            title: lang.format('fam.row.buffer', {'percent': buffer}),
            subtitle: lang.get('fam.row.bufferSub'),
            value: formatRand(result.bufferCents),
          ),
          MorekiDataRow(
            title: lang.get('fam.row.safe'),
            value: formatRand(result.safeCents),
            valueColor: AppColors.yellow,
            showDivider: false,
          ),
          if (result.affordability != FamilyAffordability.none) ...[
            const SizedBox(height: AppSpacing.xl),
            _VerdictCard(verdict: verdict),
          ],
        ],
        const SizedBox(height: AppSpacing.xl),
        _Panel(
          title: lang.get('fam.panel.title'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AmountField(
                key: const Key('familyTakeHomeField'),
                controller: _takeHome,
                label: lang.get('fam.field.takeHome'),
                errorText:
                    _errorText(context, _takeHomeFlag, 'fam.err.takeHome'),
              ),
              const SizedBox(height: AppSpacing.lg),
              _AmountField(
                key: const Key('familyEssentialsField'),
                controller: _essentials,
                label: lang.get('fam.field.essentials'),
                errorText:
                    _errorText(context, _essentialsFlag, 'fam.err.essentials'),
              ),
              const SizedBox(height: AppSpacing.lg),
              _AmountField(
                key: const Key('familySavingsField'),
                controller: _savings,
                label: lang.get('fam.field.savings'),
                errorText: _savingsBad ? lang.get('fam.err.amount') : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              _AmountField(
                key: const Key('familyRequestedField'),
                controller: _requested,
                label: lang.get('fam.field.requested'),
                errorText: _requestedBad ? lang.get('fam.err.amount') : null,
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('calculateFamilyButton'),
                  onPressed: _calculate,
                  child: Text(lang.get('fam.calculate')),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          lang.format('fam.note', {'percent': buffer}),
          style: text.bodySmall?.copyWith(color: muted, fontSize: 13),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _VerdictCard extends StatelessWidget {
  const _VerdictCard({required this.verdict});

  final _Verdict verdict;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: verdict.color),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(verdict.icon, color: verdict.color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(verdict.title, style: text.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  verdict.body,
                  style: text.bodyMedium?.copyWith(color: muted, fontSize: 14),
                ),
              ],
            ),
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
