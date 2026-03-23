// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/core/theme/app_theme.dart';
import 'package:nubar/core/theme/theme_provider.dart';
import 'package:nubar/features/auth/providers/auth_provider.dart';
import 'package:nubar/features/profile/screens/blocked_users_screen.dart';
import 'package:nubar/main.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentTheme = ref.watch(themeProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          // ── Appearance ──
          _SectionHeader(title: l10n.theme),
          _ThemeSelector(
            currentTheme: currentTheme,
            onChanged: (mode) {
              ref.read(themeProvider.notifier).setTheme(mode);
            },
          ),

          const Divider(),

          // ── Language ──
          _SectionHeader(title: l10n.language),
          _LanguageSelector(
            currentLocale: currentLocale,
            onChanged: (locale) {
              ref.read(localeProvider.notifier).state = locale;
            },
          ),

          const Divider(),

          // ── Privacy ──
          _SectionHeader(title: l10n.privacy),
          ListTile(
            leading: const Icon(Icons.block),
            title: Text(l10n.blockedUsers),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BlockedUsersScreen()),
              );
            },
          ),

          const Divider(),

          // ── Account ──
          _SectionHeader(title: l10n.account),
          ListTile(
            leading: const Icon(Icons.password),
            title: Text(l10n.changePassword),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChangePasswordDialog(context, ref),
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              l10n.logout,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () => _showLogoutConfirm(context, ref),
          ),

          const Divider(),

          // ── About ──
          _SectionHeader(title: l10n.about),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.appName),
            subtitle: const Text('v1.0.0'),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.changePassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.resetPasswordDesc),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.email,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                ref
                    .read(authNotifierProvider.notifier)
                    .resetPassword(emailController.text.trim());
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.resetPasswordSent)));
              }
            },
            child: Text(l10n.send),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(authNotifierProvider.notifier).signOut();
            },
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final AppThemeMode currentTheme;
  final ValueChanged<AppThemeMode> onChanged;

  const _ThemeSelector({required this.currentTheme, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final themes = [
      (
        AppThemeMode.nubar,
        l10n.themeNubar,
        Icons.park,
        const Color(0xFF2D6A4F),
      ),
      (
        AppThemeMode.dark,
        l10n.themeDark,
        Icons.dark_mode,
        const Color(0xFF0D1117),
      ),
      (
        AppThemeMode.light,
        l10n.themeLight,
        Icons.light_mode,
        const Color(0xFFFFFFFF),
      ),
      (
        AppThemeMode.earth,
        l10n.themeEarth,
        Icons.landscape,
        const Color(0xFF8B4513),
      ),
      (
        AppThemeMode.ocean,
        l10n.themeOcean,
        Icons.water,
        const Color(0xFF1A6B8A),
      ),
      (
        AppThemeMode.amoled,
        l10n.themeAmoled,
        Icons.phone_android,
        const Color(0xFF000000),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: themes.map((theme) {
          final isSelected = currentTheme == theme.$1;
          return ChoiceChip(
            avatar: CircleAvatar(
              backgroundColor: theme.$4,
              radius: 10,
              child: Icon(theme.$3, size: 12, color: cs.onPrimary),
            ),
            label: Text(theme.$2),
            selected: isSelected,
            onSelected: (_) => onChanged(theme.$1),
            selectedColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.2),
          );
        }).toList(),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onChanged;

  const _LanguageSelector({
    required this.currentLocale,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final languages = [
      (const Locale('ku'), 'Kurmancî', '🇹🇯'),
      (const Locale('ckb'), 'سۆرانی', '🇮🇶'),
      (const Locale('tr'), 'Türkçe', '🇹🇷'),
      (const Locale('ar'), 'العربية', '🇸🇦'),
      (const Locale('en'), 'English', '🇬🇧'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: languages.map((lang) {
          final isSelected = currentLocale.languageCode == lang.$1.languageCode;
          return RadioListTile<Locale>(
            value: lang.$1,
            groupValue: currentLocale,
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
            title: Text(lang.$2),
            secondary: Text(lang.$3, style: const TextStyle(fontSize: 20)),
            selected: isSelected,
            dense: true,
          );
        }).toList(),
      ),
    );
  }
}
