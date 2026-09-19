import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profile.dart';
import '../repositories/profile_repository.dart';
import '../state/auth_notifier.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  Profile? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = context.read<AuthNotifier>();
      final repo = context.read<ProfileRepository>();
      final p = await repo.findByUserId(auth.userId) ??
          await repo.create(Profile(userId: auth.userId));
      if (!mounted) return;
      _phoneCtrl.text = p.phone;
      _addressCtrl.text = p.address;
      setState(() {
        _profile = p;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Не удалось загрузить профиль';
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_profile == null) return;
    final repo = context.read<ProfileRepository>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final updated = Profile(
        id: _profile!.id,
        userId: _profile!.userId,
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        birthdate: _profile!.birthdate,
        bonusBalance: _profile!.bonusBalance,
      );
      await repo.update(updated);
      messenger.showSnackBar(
        const SnackBar(content: Text('Профиль сохранён')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();

    Widget body;
    if (_loading) {
      body = const LoadingView();
    } else if (_error != null) {
      body = ErrorView(message: _error!, onRetry: _load);
    } else {
      final p = _profile!;
      body = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
                const SizedBox(height: 16),
                Text(auth.userName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(auth.userEmail,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Chip(
                  label: Text('Роль: ${auth.role}'),
                  avatar: const Icon(Icons.badge, size: 18),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Телефон',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Адрес',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  enabled: false,
                  initialValue: p.bonusBalance.toStringAsFixed(0),
                  decoration: const InputDecoration(
                    labelText: 'Бонусный баланс',
                    border: OutlineInputBorder(),
                    suffixText: '₽',
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(onPressed: _save, child: const Text('Сохранить')),
              ],
            ),
          ),
        ),
      );
    }

    return AppScaffold(currentPath: '/profile', child: body);
  }
}