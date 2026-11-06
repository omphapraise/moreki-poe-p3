import 'package:flutter/material.dart';
import 'package:moreki/core/l10n/app_language.dart';
import 'package:moreki/core/l10n/app_strings.dart';
import 'package:moreki/core/theme/app_colors.dart';
import 'package:moreki/core/theme/app_spacing.dart';
import 'package:moreki/core/widgets/accent_glow.dart';
import 'package:moreki/features/coach/application/coach_controller.dart';
import 'package:moreki/features/coach/data/coach_repository.dart';
import 'package:moreki/features/coach/presentation/coach_page.dart';
import 'package:moreki/features/crisis/application/crisis_controller.dart';
import 'package:moreki/features/crisis/data/crisis_store.dart';
import 'package:moreki/features/crisis/presentation/crisis_page.dart';
import 'package:moreki/features/dashboard/dashboard_page.dart';
import 'package:moreki/features/emergency_fund/application/emergency_fund_controller.dart';
import 'package:moreki/features/emergency_fund/data/emergency_fund_store.dart';
import 'package:moreki/features/emergency_fund/presentation/emergency_fund_page.dart';
import 'package:moreki/features/family_contribution/application/family_contribution_controller.dart';
import 'package:moreki/features/family_contribution/data/family_contribution_store.dart';
import 'package:moreki/features/family_contribution/presentation/family_contribution_page.dart';
import 'package:moreki/features/money/application/money_controller.dart';
import 'package:moreki/features/money/data/money_store.dart';
import 'package:moreki/features/money/presentation/money_page.dart';
import 'package:moreki/features/profile/application/profile_controller.dart';
import 'package:moreki/features/profile/data/profile_store.dart';
import 'package:moreki/features/profile/presentation/profile_page.dart';
import 'package:moreki/features/side_hustle/application/side_hustle_controller.dart';
import 'package:moreki/features/side_hustle/data/side_hustle_store.dart';
import 'package:moreki/features/side_hustle/presentation/side_hustle_page.dart';

/// Main screen with the bottom navigation bar.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.store,
    this.emergencyFundStore,
    this.familyContributionStore,
    this.profileStore,
    this.sideHustleStore,
    this.crisisStore,
  });

  /// Where to save data. Null means "don't save" (used in tests).
  final MoneyStore? store;

  /// Where to save the emergency fund. Null means "don't save" (tests).
  final EmergencyFundStore? emergencyFundStore;

  /// Where to save the family contribution numbers. Null means "don't save".
  final FamilyContributionStore? familyContributionStore;

  /// Where to save the profile. Null means "don't save" (tests).
  final ProfileStore? profileStore;

  /// Where to save the side hustle entries. Null means "don't save" (tests).
  final SideHustleStore? sideHustleStore;

  /// Where to save the Crisis Mode numbers. Null means "don't save" (tests).
  final CrisisStore? crisisStore;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const int _moneyTab = 1;

  late final MoneyController _money;
  late final CoachController _coach;
  late final EmergencyFundController _fund;
  late final FamilyContributionController _family;
  late final ProfileController _profile;
  late final SideHustleController _hustle;
  late final CrisisController _crisis;
  bool _coachRequested = false;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _money = MoneyController(store: widget.store);
    _money.load();
    _fund = EmergencyFundController(store: widget.emergencyFundStore);
    _fund.load();
    _family = FamilyContributionController(
      store: widget.familyContributionStore,
    );
    _family.load();
    _profile = ProfileController(store: widget.profileStore);
    _profile.load();
    _hustle = SideHustleController(store: widget.sideHustleStore);
    _hustle.load();
    _crisis = CrisisController(store: widget.crisisStore);
    _crisis.load();
    _coach = CoachController(repository: AssetCoachRepository());
  }

  @override
  void dispose() {
    _money.dispose();
    _fund.dispose();
    _family.dispose();
    _profile.dispose();
    _hustle.dispose();
    _crisis.dispose();
    _coach.dispose();
    super.dispose();
  }

  void _goToMoney() => setState(() => _index = _moneyTab);

  /// Gives [page] the saved language. Rebuilds when the language changes.
  Widget _withLanguage(Widget page) {
    return ListenableBuilder(
      listenable: _profile,
      child: page,
      builder: (context, child) => AppLanguage(
        code: _profile.settings.languageCode,
        child: child!,
      ),
    );
  }

  /// Wipes everything saved on this phone. The Coach is left alone: it holds
  /// no personal data.
  Future<void> _deleteAllData() async {
    await _money.clearAll();
    await _fund.clearAll();
    await _family.clearAll();
    await _hustle.clearAll();
    await _crisis.clearAll();
    await _profile.clearAll();
  }

  void _openEmergencyFund() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _withLanguage(EmergencyFundPage(controller: _fund)),
      ),
    );
  }

  void _openFamilyContribution() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            _withLanguage(FamilyContributionPage(controller: _family)),
      ),
    );
  }

  void _openSideHustle() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _withLanguage(SideHustlePage(controller: _hustle)),
      ),
    );
  }

  void _openCrisis() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _withLanguage(CrisisPage(controller: _crisis)),
      ),
    );
  }

  void _openCoach() {
    // The saved answers are only read the first time the Coach is opened.
    if (!_coachRequested) {
      _coachRequested = true;
      _coach.load();
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _withLanguage(
          CoachPage(
            controller: _coach,
            availableFeatures: const {
              'money',
              'emergencyFund',
              'familyContribution',
              'sideHustle',
              'crisis',
            },
            onOpenFeature: (feature) {
              if (feature == 'money') {
                Navigator.of(context).pop();
                _goToMoney();
              } else if (feature == 'emergencyFund') {
                Navigator.of(context).pop();
                _openEmergencyFund();
              } else if (feature == 'familyContribution') {
                Navigator.of(context).pop();
                _openFamilyContribution();
              } else if (feature == 'sideHustle') {
                Navigator.of(context).pop();
                _openSideHustle();
              } else if (feature == 'crisis') {
                Navigator.of(context).pop();
                _openCrisis();
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _profile,
      builder: (context, _) {
        final strings = AppStrings(_profile.settings.languageCode);
        return Scaffold(
          body: AppLanguage(
            code: _profile.settings.languageCode,
            child: IndexedStack(
              index: _index,
              children: [
                DashboardPage(
                  controller: _money,
                  onOpenMoney: _goToMoney,
                  profile: _profile,
                ),
                MoneyPage(controller: _money),
                _PlanPage(
                  onOpenCoach: _openCoach,
                  onOpenEmergencyFund: _openEmergencyFund,
                  onOpenFamilyContribution: _openFamilyContribution,
                  onOpenSideHustle: _openSideHustle,
                  onOpenCrisis: _openCrisis,
                ),
                ProfilePage(
                  controller: _profile,
                  onDeleteAllData: _deleteAllData,
                ),
              ],
            ),
          ),
          bottomNavigationBar: DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.black,
              border: Border(top: BorderSide(color: AppColors.hairline)),
            ),
            child: NavigationBar(
              height: 72,
              backgroundColor: Colors.black,
              surfaceTintColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon:
                      Icon(Icons.home_rounded, color: AppColors.green),
                  label: strings.get('nav.home'),
                  tooltip: strings.get('nav.home'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.green,
                  ),
                  label: strings.get('nav.money'),
                  tooltip: strings.get('nav.money'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.grid_view_outlined),
                  selectedIcon:
                      Icon(Icons.grid_view_rounded, color: AppColors.green),
                  label: strings.get('nav.plan'),
                  tooltip: strings.get('nav.plan'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person, color: AppColors.green),
                  label: strings.get('nav.profile'),
                  tooltip: strings.get('nav.profile'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// One entry on the Plan tab.
class _PlanItem {
  const _PlanItem(this.title, this.blurb, this.icon, this.color);

  final String title;
  final String blurb;
  final IconData icon;
  final Color color;
}

class _PlanPage extends StatelessWidget {
  const _PlanPage({
    required this.onOpenCoach,
    required this.onOpenEmergencyFund,
    required this.onOpenFamilyContribution,
    required this.onOpenSideHustle,
    required this.onOpenCrisis,
  });

  final VoidCallback onOpenCoach;
  final VoidCallback onOpenEmergencyFund;
  final VoidCallback onOpenFamilyContribution;
  final VoidCallback onOpenSideHustle;
  final VoidCallback onOpenCrisis;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final s = AppLanguage.of(context);

    final comingSoon = <_PlanItem>[
      _PlanItem(
        s.get('plan.salary.title'),
        s.get('plan.salary.blurb'),
        Icons.payments_outlined,
        AppColors.cyan,
      ),
      _PlanItem(
        s.get('plan.credit.title'),
        s.get('plan.credit.blurb'),
        Icons.speed_outlined,
        AppColors.blue,
      ),
      _PlanItem(
        s.get('plan.tax.title'),
        s.get('plan.tax.blurb'),
        Icons.receipt_long_outlined,
        AppColors.violet,
      ),
      _PlanItem(
        s.get('plan.cover.title'),
        s.get('plan.cover.blurb'),
        Icons.health_and_safety_outlined,
        AppColors.cyan,
      ),
    ];

    return AccentGlow(
      color: AppColors.violet,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(s.get('plan.title'), style: text.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              s.get('plan.subtitle'),
              style: text.bodyMedium?.copyWith(color: muted, fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.xl),
            _PlanCard(
              item: _PlanItem(
                s.get('plan.coach.title'),
                s.get('plan.coach.blurb'),
                Icons.auto_awesome,
                AppColors.green,
              ),
              tag: s.get('plan.open'),
              onTap: onOpenCoach,
            ),
            const SizedBox(height: AppSpacing.md),
            _PlanCard(
              item: _PlanItem(
                s.get('plan.fund.title'),
                s.get('plan.fund.blurb'),
                Icons.shield_outlined,
                AppColors.green,
              ),
              tag: s.get('plan.open'),
              onTap: onOpenEmergencyFund,
            ),
            const SizedBox(height: AppSpacing.md),
            _PlanCard(
              item: _PlanItem(
                s.get('plan.family.title'),
                s.get('plan.family.blurb'),
                Icons.groups_outlined,
                AppColors.yellow,
              ),
              tag: s.get('plan.open'),
              onTap: onOpenFamilyContribution,
            ),
            const SizedBox(height: AppSpacing.md),
            _PlanCard(
              item: _PlanItem(
                s.get('plan.hustle.title'),
                s.get('plan.hustle.blurb'),
                Icons.storefront_outlined,
                AppColors.orange,
              ),
              tag: s.get('plan.open'),
              onTap: onOpenSideHustle,
            ),
            const SizedBox(height: AppSpacing.md),
            _PlanCard(
              item: _PlanItem(
                s.get('plan.crisis.title'),
                s.get('plan.crisis.blurb'),
                Icons.favorite_border,
                AppColors.red,
              ),
              tag: s.get('plan.open'),
              onTap: onOpenCrisis,
            ),
            const SizedBox(height: AppSpacing.md),
            for (final item in comingSoon) ...[
              _PlanCard(item: item, tag: s.get('plan.comingSoon')),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.item, required this.tag, this.onTap});

  final _PlanItem item;
  final String tag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Semantics(
      container: true,
      button: onTap != null,
      onTap: onTap,
      label: '${item.title}. ${item.blurb} $tag.',
      child: ExcludeSemantics(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(28),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icon, color: item.color),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: text.titleMedium?.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            item.blurb,
                            style: text.bodyMedium?.copyWith(
                              color: muted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      tag,
                      style: text.labelMedium?.copyWith(
                        color: muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
