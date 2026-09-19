import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../repositories/product_repository.dart';
import '../../state/product_list_notifier.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';

class ProductManageScreen extends StatefulWidget {
  const ProductManageScreen({super.key});
  @override
  State<ProductManageScreen> createState() => _ProductManageScreenState();
}

class _ProductManageScreenState extends State<ProductManageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    // Читаем notifier из context ДО await
    final notifier = context.read<ProductListNotifier>();
    await notifier.load(query: ProductQuery(perPage: 100));
  }

  Future<void> _delete(Product p) async {
    // Читаем всё, что нужно, ДО await showDialog
    final repo = context.read<ProductRepository>();
    final notifier = context.read<ProductListNotifier>();

    final ok = await showConfirmDialog(
      context,
      title: 'Удалить товар?',
      content: p.name,
    );
    if (!ok) return;

    await repo.delete(p.id!);
    await notifier.load(query: ProductQuery(perPage: 100));
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ProductListNotifier>();
    return AppScaffold(
      currentPath: '/manager/products',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                FilledButton.icon(
                  onPressed: () => context.go('/product-form'),
                  icon: const Icon(Icons.add),
                  label: const Text('Новый товар'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: switch (notifier.status) {
              LoadStatus.idle || LoadStatus.loading => const LoadingView(),
              LoadStatus.error => ErrorView(
                  message: notifier.error ?? 'Ошибка',
                  onRetry: _load,
                ),
              LoadStatus.success when notifier.items.isEmpty =>
                const EmptyView(message: 'Товаров нет'),
              LoadStatus.success => ListView.separated(
                  itemCount: notifier.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final p = notifier.items[i];
                    return ListTile(
                      title: Text(p.name),
                      subtitle: Text(
                        '${p.brandName ?? "—"} · ${p.price.toStringAsFixed(0)} ₽ · ост. ${p.stock}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                context.go('/product-form?id=${p.id}'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _delete(p),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            },
          ),
        ],
      ),
    );
  }
}