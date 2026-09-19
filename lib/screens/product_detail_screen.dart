import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../state/auth_notifier.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';

class ProductDetailScreen extends StatefulWidget {
  final String id;
  const ProductDetailScreen({super.key, required this.id});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final p = await context.read<ProductRepository>().findById(widget.id);
      if (!mounted) return;
      setState(() { _product = p; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Не удалось загрузить товар'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final canEdit = auth.isManager || auth.isAdmin;

    Widget body;
    if (_loading) {
      body = const LoadingView();
    } else if (_error != null) {
      body = ErrorView(message: _error!, onRetry: _load);
    } else if (_product == null) {
      body = const Center(child: Text('Товар не найден'));
    } else {
      final p = _product!;
      body = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 240, width: double.infinity,
                  color: Colors.pink.shade50, alignment: Alignment.center,
                  child: const Icon(Icons.spa, size: 96, color: Colors.pink),
                ),
                const SizedBox(height: 24),
                Text(p.name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                if (p.brandName != null)
                  Text('Бренд: ${p.brandName}', style: TextStyle(color: Colors.grey.shade700)),
                if (p.categoryName != null)
                  Text('Категория: ${p.categoryName}', style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 16),
                Text('${p.price.toStringAsFixed(0)} ₽',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.pink)),
                const SizedBox(height: 8),
                Text('В наличии: ${p.stock} шт.'),
                const SizedBox(height: 16),
                Text(p.description),
                if (canEdit) ...[
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.go('/product-form?id=${p.id}'),
                    icon: const Icon(Icons.edit),
                    label: const Text('Редактировать'),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return AppScaffold(currentPath: '/catalog', child: body);
  }
}