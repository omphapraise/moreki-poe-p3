import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moreki/core/l10n/app_strings.dart';
import 'package:moreki/core/theme/app_colors.dart';
import 'package:moreki/core/theme/app_spacing.dart';
import 'package:moreki/core/widgets/accent_glow.dart';
import 'package:moreki/core/widgets/moreki_data_row.dart';
import 'package:moreki/features/profile/application/profile_controller.dart';
import 'package:moreki/features/profile/domain/profile.dart';

String _fullDate(AppStrings s, DateTime d) =>
    '${d.day} ${s.month(d.month)} ${d.year}';

String _daysLabel(AppStrings s, int days) {
  if (days == 0) return s.get('profile.today');
  if (days == 1) return s.get('profile.tomorrow');
  return s.format('profile.daysAway', {'n': '$days'});
}

/// The Profile tab.
class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.controller,
    this.onDeleteAllData,
  });

  final ProfileController controller;

  /// Runs when the user confirms "Delete all my data". The delete button is
  /// only shown when this is given.
  final Future<void> Function()? onDeleteAllData;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _payday = TextEditingController();

  bool _populated = false;
  bool _paydayBad = false;

  AppStrings get _s => AppStrings(widget.controller.settings.languageCode);

  @override
  void initState() {
    super.initState();
    if (widget.controller.loaded) {
      _populated = true;
      _fillFields();
    } else {
      // Saved data arrives a moment after the app starts.
      widget.controller.addListener(_onController);
    }
  }

  void _onController() {
    if (!_populated && widget.controller.loaded) {
      _populated = true;
      _fillFields();
    }
  }

  void _fillFields() {
    final s = widget.controller.settings;
    _name.text = s.displayName;
    _payday.text = s.paydayDay?.toString() ?? '';
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    _name.dispose();
    _payday.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final dayText = _payday.text.trim();
    int? day;
    var bad = false;
    if (dayText.isNotEmpty) {
      day = int.tryParse(dayText);
      if (day == null || day < 1 || day > 31) bad = true;
    }
    setState(() => _paydayBad = bad);
    if (bad) return;

    await widget.controller.saveDetails(
      displayName: _name.text,
      paydayDay: day,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_s.get('profile.saved'))),
    );
  }

  Future<void> _confirmDeleteAll() async {
    final deleteAll = widget.onDeleteAllData;
    if (deleteAll == null) return;
    FocusScope.of(context).unfocus();
    final s = _s;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.get('profile.deleteTitle')),
        content: Text(s.get('profile.deleteBody')),
        actions: [
          TextButton(
            key: const Key('cancelDeleteAllButton'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(s.get('profile.cancel')),
          ),
          FilledButton(
            key: const Key('confirmDeleteAllButton'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(s.get('profile.deleteEverything')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await deleteAll();
    if (!mounted) return;
    _name.clear();
    _payday.clear();
    setState(() => _paydayBad = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.get('profile.deleted'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AccentGlow(
      color: AppColors.blue,
      child: SafeArea(
        child: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) => _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final c = widget.controller;
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final settings = c.settings;
    final s = AppStrings(settings.languageCode);
    final name = settings.displayName;
    final payday = c.payday;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: name.isEmpty
                  ? const Icon(Icons.person_outline, color: AppColors.blue)
                  : Text(
                      name.characters.first.toUpperCase(),
                      style: text.titleLarge?.copyWith(color: AppColors.blue),
                    ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  name.isEmpty
                      ? s.get('profile.title')
                      : s.format('profile.hi', {'name': name}),
                  style: text.headlineMedium,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          s.get('profile.subtitle'),
          style: text.bodyMedium?.copyWith(color: muted, fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (payday != null) ...[
          MorekiDataRow(
            title: s.get('profile.nextPayday'),
            subtitle: _fullDate(s, payday.date),
            value: _daysLabel(s, payday.daysAway),
            valueColor: AppColors.blue,
            showDivider: false,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        _Panel(
          title: s.get('profile.aboutYou'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                key: const Key('profileNameField'),
                controller: _name,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(
                    ProfileSettings.maxNameLength,
                  ),
                ],
                style: text.bodyLarge,
                decoration: _decoration(s.get('profile.nameLabel')),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                key: const Key('profilePaydayField'),
                controller: _payday,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                style: text.bodyLarge,
                decoration: _decoration(
                  s.get('profile.paydayLabel'),
                  errorText: _paydayBad ? s.get('profile.badDay') : null,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('saveProfileButton'),
                  onPressed: _save,
                  child: Text(s.get('profile.save')),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _Panel(
          title: s.get('profile.language'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final lang in ProfileSettings.languages)
                    ChoiceChip(
                      key: Key('language_${lang.code}'),
                      label: Text(lang.label),
                      selected: settings.languageCode == lang.code,
                      onSelected: (_) => c.setLanguage(lang.code),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                s.get('profile.languageNote'),
                style: text.bodySmall?.copyWith(color: muted, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _Panel(
          title: s.get('profile.privacy'),
          child: Text(
            s.get('profile.privacyBody'),
            style: text.bodyMedium?.copyWith(color: muted, fontSize: 14),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _Panel(
          title: s.get('profile.about'),
          child: Text(
            s.get('profile.aboutBody'),
            style: text.bodyMedium?.copyWith(color: muted, fontSize: 14),
          ),
        ),
        if (widget.onDeleteAllData != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _Panel(
            title: s.get('profile.data'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.get('profile.dataBody'),
                  style: text.bodyMedium?.copyWith(color: muted, fontSize: 14),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    key: const Key('deleteAllDataButton'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red,
                      side: const BorderSide(color: AppColors.red),
                    ),
                    onPressed: _confirmDeleteAll,
                    child: Text(s.get('profile.deleteButton')),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  InputDecoration _decoration(String label, {String? errorText}) {
    return InputDecoration(
      labelText: label,
      errorText: errorText,
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
