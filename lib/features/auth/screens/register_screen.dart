import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/core/utils/validators.dart';
import 'package:nubar/features/auth/providers/auth_provider.dart';
import 'package:nubar/features/auth/screens/login_screen.dart';
import 'package:nubar/main.dart';
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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedLang = 'ku';

  @override
  void initState() {
    super.initState();
    final currentCode = ref.read(localeProvider).languageCode;
    _selectedLang = switch (currentCode) {
      'ku' || 'ckb' || 'tr' || 'ar' || 'en' => currentCode,
      _ => 'ku',
    };
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _buildUsername(String firstName, String lastName) {
    final normalized = '$firstName$lastName'.toLowerCase().replaceAll(
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
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final fullName = '$firstName $lastName'.trim();
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim();

      ref
          .read(authNotifierProvider.notifier)
          .signUp(
            email: email,
            password: _passwordController.text,
            username: _buildUsername(firstName, lastName),
            firstName: firstName,
            lastName: lastName,
            fullName: fullName,
            phone: phone.isEmpty ? null : phone,
            preferredLang: _selectedLang,
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
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/arka plan.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Container(
            color: Colors.black.withValues(alpha: 0.34),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.all(20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      maxWidth: 620,
                    ),
                    child: Center(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.createAccount,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.welcomeSubtitle,
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 14),
                            NubarTextField(
                              controller: _firstNameController,
                              label: l10n.firstName,
                              prefixIcon: Icons.person_outline,
                              validator: Validators.validateRequiredName,
                            ),
                            const SizedBox(height: 14),
                            NubarTextField(
                              controller: _lastNameController,
                              label: l10n.lastName,
                              prefixIcon: Icons.person_outlined,
                              validator: Validators.validateRequiredName,
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
                              controller: _phoneController,
                              label: l10n.phoneOptional,
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: Validators.validateOptionalPhone,
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
                            const SizedBox(height: 14),
                            Text(
                              l10n.selectLanguage,
                              style: textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedLang,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.language),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'ku',
                                  child: Text('Kurmancî'),
                                ),
                                DropdownMenuItem(
                                  value: 'ckb',
                                  child: Text('سۆرانی'),
                                ),
                                DropdownMenuItem(
                                  value: 'tr',
                                  child: Text('Türkçe'),
                                ),
                                DropdownMenuItem(
                                  value: 'ar',
                                  child: Text('العربية'),
                                ),
                                DropdownMenuItem(
                                  value: 'en',
                                  child: Text('English'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedLang = value);
                                  ref.read(localeProvider.notifier).state =
                                      Locale(value);
                                }
                              },
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
                                Text(
                                  l10n.alreadyHaveAccount,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.95),
                                  ),
                                ),
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
