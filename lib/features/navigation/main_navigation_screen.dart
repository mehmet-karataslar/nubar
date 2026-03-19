import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nubar/features/feed/screens/feed_screen.dart';
import 'package:nubar/features/search/screens/search_screen.dart';
import 'package:nubar/features/notifications/screens/notifications_screen.dart';
import 'package:nubar/features/notifications/providers/notifications_provider.dart';
import 'package:nubar/features/messages/screens/messages_list_screen.dart';
import 'package:nubar/features/profile/screens/profile_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FeedScreen(),
    SearchScreen(),
    NotificationsScreen(),
    MessagesListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.feed,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: const Icon(Icons.search),
            label: l10n.search,
          ),
          NavigationDestination(
            icon: unreadCount > 0
                ? Badge(
                    label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                    child: const Icon(Icons.notifications_outlined),
                  )
                : const Icon(Icons.notifications_outlined),
            selectedIcon: unreadCount > 0
                ? Badge(
                    label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                    child: const Icon(Icons.notifications),
                  )
                : const Icon(Icons.notifications),
            label: l10n.notifications,
          ),
          NavigationDestination(
            icon: const Icon(Icons.mail_outlined),
            selectedIcon: const Icon(Icons.mail),
            label: l10n.messages,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outlined),
            selectedIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
