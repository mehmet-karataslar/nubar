import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nubar/core/utils/validators.dart';
import 'package:nubar/features/auth/providers/auth_provider.dart';
import 'package:nubar/shared/widgets/nubar_button.dart';
import 'package:nubar/shared/widgets/nubar_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedLang = 'ku';

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      ref.read(authNotifierProvider.notifier).signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            username: _usernameController.text.trim(),
            fullName: _fullNameController.text.trim(),
            preferredLang: _selectedLang,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (_, state) {
      state.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createAccount),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Username
                NubarTextField(
                  controller: _usernameController,
                  label: l10n.username,
                  prefixIcon: Icons.alternate_email,
                  validator: Validators.validateUsername,
                ),
                const SizedBox(height: 16),

                // Full name
                NubarTextField(
                  controller: _fullNameController,
                  label: l10n.fullName,
                  prefixIcon: Icons.person_outlined,
                  validator: Validators.validateFullName,
                ),
                const SizedBox(height: 16),

                // Email
                NubarTextField(
                  controller: _emailController,
                  label: l10n.email,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),

                // Password
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
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Language selection
                Text(
                  l10n.selectLanguage,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedLang,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.language),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'ku', child: Text('Kurmancî')),
                    DropdownMenuItem(value: 'ckb', child: Text('سۆرانی')),
                    DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                    DropdownMenuItem(value: 'ar', child: Text('العربية')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedLang = value);
                    }
                  },
                ),
                const SizedBox(height: 32),

                // Register button
                NubarButton(
                  text: l10n.createAccount,
                  onPressed: _handleRegister,
                  isLoading: authState.isLoading,
                  width: double.infinity,
                ),
                const SizedBox(height: 16),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.alreadyHaveAccount),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
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
  }
}
