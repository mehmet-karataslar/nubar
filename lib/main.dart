import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nubar/core/theme/app_theme.dart';
import 'package:nubar/core/theme/theme_provider.dart';
import 'package:nubar/features/auth/providers/auth_provider.dart';
import 'package:nubar/features/auth/screens/login_screen.dart';
import 'package:nubar/features/auth/screens/onboarding_screen.dart';
import 'package:nubar/shared/services/supabase_service.dart';
import 'package:nubar/shared/widgets/loading_indicator.dart';
import 'package:nubar/features/navigation/main_navigation_screen.dart';

final localeProvider = StateProvider<Locale>((ref) => const Locale('ku'));

final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await SupabaseService.initialize();

  runApp(
    const ProviderScope(
      child: NubarApp(),
    ),
  );
}

class NubarApp extends ConsumerWidget {
  const NubarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Nûbar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(themeMode),
      locale: locale,
      supportedLocales: const [
        Locale('ku'),
        Locale('ckb'),
        Locale('tr'),
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final onboardingComplete = ref.watch(onboardingCompleteProvider);

    return authState.when(
      data: (state) {
        if (state.session != null) {
          return const MainNavigationScreen();
        }
        if (!onboardingComplete) {
          return const OnboardingScreen();
        }
        return const LoginScreen();
      },
      loading: () => const Scaffold(
        body: LoadingIndicator(),
      ),
      error: (error, stack) => const LoginScreen(),
    );
  }
}
