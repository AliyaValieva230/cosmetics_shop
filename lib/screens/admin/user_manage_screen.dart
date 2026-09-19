import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../core/api_client.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';

class UserManageScreen extends StatefulWidget {
  const UserManageScreen({super.key});
  @override
  State<UserManageScreen> createState() => _UserManageScreenState();
}

class _UserManageScreenState extends State<UserManageScreen> {
  List<RecordModel>? _users;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _users = null;
      _error = null;
    });
    try {
      final r = await pb.collection('users').getFullList(sort: 'name');
      if (mounted) {
        setState(() => _users = r);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Не удалось загрузить пользователей');
      }
    }
  }

  Future<void> _changeRole(RecordModel user, String newRole) async {
    try {
      await pb.collection('users').update(user.id, body: {'role': newRole});
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _delete(RecordModel user) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Удалить пользователя?',
      content: user.getStringValue('name'),
    );
    if (!ok) return;
    try {
      await pb.collection('users').delete(user.id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_error != null) {
      body = ErrorView(message: _error!, onRetry: _load);
    } else if (_users == null) {
      body = const LoadingView();
    } else if (_users!.isEmpty) {
      body = const EmptyView(message: 'Пользователей нет');
    } else {
      body = ListView.separated(
        itemCount: _users!.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final u = _users![i];
          final role = u.getStringValue('role');
          return ListTile(
            title: Text(u.getStringValue('name')),
            subtitle: Text('${u.getStringValue('email')} · $role'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: role,
                  items: const [
                    DropdownMenuItem(value: 'customer', child: Text('Покупатель')),
                    DropdownMenuItem(value: 'manager', child: Text('Менеджер')),
                    DropdownMenuItem(value: 'admin', child: Text('Администратор')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      _changeRole(u, v);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _delete(u),
                ),
              ],
            ),
          );
        },
      );
    }
    return AppScaffold(currentPath: '/admin/users', child: body);
  }
}