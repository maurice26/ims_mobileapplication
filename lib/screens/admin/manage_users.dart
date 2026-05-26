import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/user_service.dart';
import '../../widgets/app_shell/page_wrapper.dart';
import '../../widgets/datagrid/ims_table.dart';
import '../../widgets/datagrid/ims_table_row_actions.dart';
import '../../widgets/role_guard.dart';

class ManageUsers extends ConsumerWidget {
  const ManageUsers({super.key});

  Future<void> _showUserDialog({
    required BuildContext context,
    required WidgetRef ref,
    User? user,
  }) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final passwordController = TextEditingController();
    var role = user?.role.toLowerCase() ?? 'user';
    final isEdit = user != null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit user' : 'Create user'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) return 'Email is required';
                    if (!email.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                if (!isEdit) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Temporary password',
                    ),
                    obscureText: true,
                    validator: (value) => value == null || value.length < 6
                        ? 'Use at least 6 characters'
                        : null,
                  ),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'sales', child: Text('Sales')),
                    DropdownMenuItem(value: 'user', child: Text('User')),
                  ],
                  onChanged: (value) => role = value ?? role,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final token = ref.read(authProvider)?.token;
              if (token == null) return;

              final service = UserService();
              final result = isEdit
                  ? await service.updateUser(token, {
                      'userId': int.parse(user.id),
                      'name': nameController.text.trim(),
                      'email': emailController.text.trim(),
                      'role': role,
                    })
                  : await service.createUser(token, {
                      'name': nameController.text.trim(),
                      'email': emailController.text.trim(),
                      'password': passwordController.text,
                      'role': role,
                    });

              if (result.hasException) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Save failed: ${result.exception}')),
                  );
                }
                return;
              }

              await ref.refresh(usersProvider.future);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEdit ? 'User updated' : 'User created'),
                  ),
                );
              }
            },
            child: Text(isEdit ? 'Save' : 'Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(
    BuildContext context,
    WidgetRef ref,
    User user,
  ) async {
    final token = ref.read(authProvider)?.token;
    final userId = int.tryParse(user.id);
    if (token == null || userId == null) return;

    final result = await UserService().deleteUser(token, userId);
    if (result.hasException) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: ${result.exception}')),
        );
      }
      return;
    }

    await ref.refresh(usersProvider.future);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${user.name} deleted')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return RoleGuard(
      requiredRole: 'admin',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Users'),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => ref.invalidate(usersProvider),
            ),
          ],
        ),
        body: PageWrapper(
          subtitle: 'Create accounts, assign roles, and keep access tidy.',
          child: usersAsync.when(
            data: (users) => ImsTable<User>(
              items: users,
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Role')),
                DataColumn(label: Text('Actions')),
              ],
              rowBuilder: (user) => DataRow(
                cells: [
                  DataCell(Text(user.name)),
                  DataCell(Text(user.email)),
                  DataCell(Text(user.roleDisplay)),
                  DataCell(
                    ImsTableRowActions(
                      onEdit: () => _showUserDialog(
                        context: context,
                        ref: ref,
                        user: user,
                      ),
                      onDelete: () => _deleteUser(context, ref, user),
                      deleteLabel: 'Delete ${user.name}?',
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _RetryState(
              message: 'Could not load users: $error',
              onRetry: () => ref.invalidate(usersProvider),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showUserDialog(context: context, ref: ref),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('New user'),
        ),
      ),
    );
  }
}

class _RetryState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _RetryState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
