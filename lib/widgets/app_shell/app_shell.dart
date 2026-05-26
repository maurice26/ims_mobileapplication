import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/role_drawer.dart';

class AppShell extends ConsumerWidget {
  final Widget body;
  final String title;
  final bool showDrawer;
  final List<Widget>? actions;

  const AppShell({
    super.key,
    required this.body,
    required this.title,
    this.showDrawer = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      drawer: showDrawer ? const RoleDrawer() : null,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              automaticallyImplyLeading: false,
              leading: showDrawer
                  ? IconButton(
                      tooltip: 'Menu',
                      icon: const Icon(Icons.menu_rounded),
                      onPressed: () => scaffoldKey.currentState?.openDrawer(),
                    )
                  : null,
              title: Text(title),
              actions: [
                if (authState?.isAuthenticated == true)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Chip(
                      label: Text(authState!.role.capitalize()),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      side: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                ...?actions,
              ],
            ),
            SliverFillRemaining(child: body),
          ],
        ),
      ),
    );
  }
}

extension _Capitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
