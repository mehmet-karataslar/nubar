import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/core/utils/validators.dart';
import 'package:nubar/features/auth/providers/auth_provider.dart';
import 'package:nubar/features/auth/screens/register_screen.dart';
import 'package:nubar/shared/widgets/nubar_button.dart';
import 'package:nubar/shared/widgets/nubar_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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

  void _showForgotPasswordDialog(BuildContext context, dynamic l10n) {
    final resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.forgotPassword),
        content: TextField(
          controller: resetEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(hintText: l10n.email),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final email = resetEmailController.text.trim();
              if (email.isNotEmpty) {
                ref.read(authNotifierProvider.notifier).resetPassword(email);
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.done)));
              }
            },
            child: Text(l10n.send),
          ),
        ],
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(authNotifierProvider.notifier)
          .signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (_, state) {
      state.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        },
      );
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
                      maxWidth: 560,
                    ),
                    child: Center(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.login,
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
                            const SizedBox(height: 24),
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
                            const SizedBox(height: 4),
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: TextButton(
                                onPressed: () {
                                  _showForgotPasswordDialog(context, l10n);
                                },
                                child: Text(l10n.forgotPassword),
                              ),
                            ),
                            const SizedBox(height: 10),
                            NubarButton(
                              text: l10n.login,
                              onPressed: _handleLogin,
                              isLoading: authState.isLoading,
                              width: double.infinity,
                              icon: Icons.login_rounded,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.dontHaveAccount,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.95),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(l10n.register),
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
