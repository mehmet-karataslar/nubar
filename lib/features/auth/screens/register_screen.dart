import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/core/utils/validators.dart';
import 'package:nubar/features/auth/providers/auth_provider.dart';
import 'package:nubar/features/auth/screens/login_screen.dart';
import 'package:nubar/shared/widgets/nubar_button.dart';
import 'package:nubar/shared/widgets/nubar_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _buildUsername(String email) {
    final localPart = email.split('@').first;
    final normalized = localPart.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9_]'),
      '',
    );
    final base = normalized.isEmpty ? 'user' : normalized;
    final suffix = DateTime.now().millisecondsSinceEpoch.toString().substring(
      8,
    );
    return '${base}_$suffix';
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final localeCode = Localizations.localeOf(context).languageCode;
      final preferredLang = switch (localeCode) {
        'ku' || 'ckb' || 'tr' || 'ar' || 'en' => localeCode,
        _ => 'ku',
      };

      ref
          .read(authNotifierProvider.notifier)
          .signUp(
            email: email,
            password: _passwordController.text,
            username: _buildUsername(email),
            firstName: 'Nubar',
            lastName: 'User',
            fullName: 'Nubar User',
            preferredLang: preferredLang,
          );
    }
  }

  String _friendlyAuthError(Object? error, AppLocalizations l10n) {
    if (error is AuthApiException) {
      if (error.code == 'user_already_exists' ||
          error.message.toLowerCase().contains('already registered')) {
        return l10n.authUserAlreadyExists;
      }
    }
    return l10n.authGenericError;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (previous, state) {
      if (previous?.isLoading == true && state.hasError) {
        final message = _friendlyAuthError(state.error, l10n);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
      if (previous?.isLoading == true &&
          !state.isLoading &&
          !state.hasError &&
          mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/arka plan.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Container(
            color: Colors.black.withValues(alpha: 0.18),
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.createAccount,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.welcomeSubtitle,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        NubarTextField(
                          controller: _emailController,
                          label: l10n.email,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 14),
                        NubarTextField(
                          controller: _passwordController,
                          label: l10n.password,
                          prefixIcon: Icons.lock_outlined,
                          obscureText: _obscurePassword,
                          validator: Validators.validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        NubarButton(
                          text: l10n.createAccount,
                          onPressed: _handleRegister,
                          isLoading: authState.isLoading,
                          width: double.infinity,
                          icon: Icons.how_to_reg_rounded,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l10n.alreadyHaveAccount),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(l10n.login),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
