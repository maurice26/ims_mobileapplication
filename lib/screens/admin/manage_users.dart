import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/user_provider.dart';
import '../../widgets/role_guard.dart';

class ManageUsers extends ConsumerWidget {
  const ManageUsers({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return RoleGuard(
      requiredRole: 'admin',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Users'),
          backgroundColor: const Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(usersProvider),
            ),
          ],
        ),
        body: usersAsync.when(
          data: (users) => users.isEmpty
              ? const Center(child: Text('No users'))
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Dismissible(
                      key: ValueKey(user.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        // TODO: Delete user mutation
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${user.name} deleted')),
                        );
                      },
                      child: ListTile(
                        title: Text(user.name),
                        subtitle: Text('${user.email} - ${user.roleDisplay}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // TODO: Edit user dialog
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                // TODO: Confirm delete
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $error'),
                ElevatedButton(
                  onPressed: () => ref.invalidate(usersProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Add user dialog/mutation
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
