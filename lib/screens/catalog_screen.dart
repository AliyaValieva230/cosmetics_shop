import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/breakpoints.dart';
import '../models/brand.dart';
import '../models/category.dart';
import '../repositories/brand_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/product_repository.dart';
import '../state/product_list_notifier.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/product_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchCtrl = TextEditingController();
  final _minPrice = TextEditingController();
  final _maxPrice = TextEditingController();
  List<Category> _categories = [];
  List<Brand> _brands = [];
  ProductQuery _query = ProductQuery();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _minPrice.dispose();
    _maxPrice.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    // Читаем всё из context ДО первого await
    final catRepo = context.read<CategoryRepository>();
    final brandRepo = context.read<BrandRepository>();
    final notifier = context.read<ProductListNotifier>();
    final uri = GoRouterState.of(context).uri;

    final cats = await catRepo.findAll();
    final brands = await brandRepo.findAll();
    if (!mounted) return;

    setState(() {
      _categories = cats;
      _brands = brands;
    });

    _query = ProductQuery.fromQueryParams(uri.queryParameters);
    _searchCtrl.text = _query.search ?? '';
    _minPrice.text = _query.minPrice?.toString() ?? '';
    _maxPrice.text = _query.maxPrice?.toString() ?? '';

    await notifier.load(query: _query);
  }

  void _apply(ProductQuery q) {
    _query = q;
    final params = _query.toQueryParams();
    final uri = Uri(
      path: '/catalog',
      queryParameters: params.isEmpty ? null : params,
    );
    context.go(uri.toString());
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ProductListNotifier>();
    final columns = byScreen(context, compact: 1, medium: 2, expanded: 4);

    return AppScaffold(
      currentPath: '/catalog',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Поиск',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (v) => _apply(_query.copyWith(search: v.trim())),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String?>(
                    value: _query.categoryId,
                    decoration: const InputDecoration(
                      labelText: 'Категория',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Все')),
                      ..._categories.map((c) =>
                          DropdownMenuItem(value: c.id, child: Text(c.name))),
                    ],
                    onChanged: (v) => _apply(_query.copyWith(categoryId: v)),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String?>(
                    value: _query.brandId,
                    decoration: const InputDecoration(
                      labelText: 'Бренд',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Все')),
                      ..._brands.map((b) =>
                          DropdownMenuItem(value: b.id, child: Text(b.name))),
                    ],
                    onChanged: (v) => _apply(_query.copyWith(brandId: v)),
                  ),
                ),
                SizedBox(
                  width: 130,
                  child: TextField(
                    controller: _minPrice,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Цена от',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(
                  width: 130,
                  child: TextField(
                    controller: _maxPrice,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'до',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    value: _query.sort,
                    decoration: const InputDecoration(
                      labelText: 'Сортировка',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: '-created', child: Text('Новые')),
                      DropdownMenuItem(value: 'price', child: Text('Цена ↑')),
                      DropdownMenuItem(value: '-price', child: Text('Цена ↓')),
                      DropdownMenuItem(value: 'name', child: Text('Название')),
                    ],
                    onChanged: (v) =>
                        v != null ? _apply(_query.copyWith(sort: v)) : null,
                  ),
                ),
                FilledButton(
                  onPressed: () => _apply(_query.copyWith(
                    minPrice: double.tryParse(_minPrice.text),
                    maxPrice: double.tryParse(_maxPrice.text),
                  )),
                  child: const Text('Применить'),
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
                const EmptyView(message: 'Товары не найдены'),
              LoadStatus.success => GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3 / 4,
                  ),
                  itemCount: notifier.items.length,
                  itemBuilder: (_, i) {
                    final p = notifier.items[i];
                    return ProductCard(
                      product: p,
                      onTap: () => context.go('/product/${p.id}'),
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