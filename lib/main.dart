import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moreki/core/theme/app_theme.dart';
import 'package:moreki/features/crisis/data/crisis_store.dart';
import 'package:moreki/features/emergency_fund/data/emergency_fund_store.dart';
import 'package:moreki/features/family_contribution/data/family_contribution_store.dart';
import 'package:moreki/features/money/data/money_store.dart';
import 'package:moreki/features/profile/data/profile_store.dart';
import 'package:moreki/features/shell/app_shell.dart';
import 'package:moreki/features/side_hustle/data/side_hustle_store.dart';
import 'package:moreki/features/widget/data/widget_syncing_money_store.dart';
import 'package:moreki/features/widget/data/widget_updater.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MorekiApp(
      store: _buildStore(),
      emergencyFundStore: SharedPrefsEmergencyFundStore(),
      familyContributionStore: SharedPrefsFamilyContributionStore(),
      profileStore: SharedPrefsProfileStore(),
      sideHustleStore: SharedPrefsSideHustleStore(),
      crisisStore: SharedPrefsCrisisStore(),
    ),
  );
}

/// On Android the saved money data also refreshes the home-screen widget.
MoneyStore _buildStore() {
  final saved = SharedPrefsMoneyStore();
  final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  if (!isAndroid) return saved;
  return WidgetSyncingMoneyStore(inner: saved, updater: HomeWidgetUpdater());
}

class MorekiApp extends StatelessWidget {
  const MorekiApp({
    super.key,
    this.store,
    this.emergencyFundStore,
    this.familyContributionStore,
    this.profileStore,
    this.sideHustleStore,
    this.crisisStore,
  });

  /// Where to save money data. Null means "don't save" (used in tests).
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moreki',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark, // dark first while we build
      home: AppShell(
        store: store,
        emergencyFundStore: emergencyFundStore,
        familyContributionStore: familyContributionStore,
        profileStore: profileStore,
        sideHustleStore: sideHustleStore,
        crisisStore: crisisStore,
      ),
    );
  }
}
