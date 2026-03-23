import 'package:flutter/material.dart';

class ProfileTabsHeader extends StatelessWidget {
  final List<Tab> tabs;

  const ProfileTabsHeader({super.key, required this.tabs});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: colorScheme.surface,
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: colorScheme.outline.withValues(alpha: 0.15),
        indicatorColor: colorScheme.primary,
        indicatorWeight: 3,
        labelStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        tabs: tabs,
      ),
    );
  }
}
