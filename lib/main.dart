import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/core/l10n/fallback_material_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nubar/core/theme/app_theme.dart';
import 'package:nubar/core/theme/theme_provider.dart';
import 'package:nubar/features/auth/providers/auth_provider.dart';
import 'package:nubar/features/auth/screens/login_screen.dart';
import 'package:nubar/features/navigation/main_navigation_screen.dart';
import 'package:nubar/shared/services/supabase_service.dart';
import 'package:nubar/shared/widgets/loading_indicator.dart';

final localeProvider = StateProvider<Locale>((ref) => const Locale('ku'));

final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await SupabaseService.initialize();

  runApp(const ProviderScope(child: NubarApp()));
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
        FallbackMaterialLocalizationsDelegate(),
        GlobalWidgetsLocalizations.delegate,
        FallbackWidgetsLocalizationsDelegate(),
        GlobalCupertinoLocalizations.delegate,
        FallbackCupertinoLocalizationsDelegate(),
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

    return FutureBuilder<void>(
      future: Future<void>.delayed(const Duration(milliseconds: 1400)),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _StartupSplashScreen();
        }

        return authState.when(
          loading: () =>
              const Scaffold(body: Center(child: LoadingIndicator())),
          error: (_, _) => const LoginScreen(),
          data: (state) {
            final user = state.session?.user;
            if (user == null) {
              return const LoginScreen();
            }
            return const MainNavigationScreen();
          },
        );
      },
    );
  }
}

class _StartupSplashScreen extends StatelessWidget {
  const _StartupSplashScreen();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [
              colorScheme.primary.withValues(alpha: 0.22),
              colorScheme.secondary.withValues(alpha: 0.18),
              colorScheme.error.withValues(alpha: 0.1),
              colorScheme.surface,
            ],
            stops: const [0.0, 0.35, 0.72, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 116,
                  width: 116,
                  padding: const EdgeInsetsDirectional.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.82),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.14),
                        blurRadius: 26,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Image.asset('assets/icons/icon.png'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nubar',
                  style: textTheme.headlineMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kurdish Voices, Shared Freely',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 18),
                const LoadingIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
