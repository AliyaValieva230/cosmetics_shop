import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Доступ запрещён')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.block, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('У вас нет прав для этой страницы'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/catalog'),
              child: const Text('На главную'),
            ),
          ],
        ),
      ),
    );
  }
}