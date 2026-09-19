import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/validators.dart';
import '../models/brand.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../repositories/brand_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/product_repository.dart';
import '../widgets/loading_view.dart';

class ProductFormScreen extends StatefulWidget {
  final String? productId;
  const ProductFormScreen({super.key, this.productId});
  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();
  String? _categoryId;
  String? _brandId;
  List<Category> _categories = [];
  List<Brand> _brands = [];
  bool _loading = true;
  bool _saving = false;

  bool get _isEdit => widget.productId != null;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    // Читаем все репозитории из context ДО await
    final catRepo = context.read<CategoryRepository>();
    final brandRepo = context.read<BrandRepository>();
    final productRepo = context.read<ProductRepository>();

    final cats = await catRepo.findAll();
    final brands = await brandRepo.findAll();
    if (!mounted) return;

    setState(() {
      _categories = cats;
      _brands = brands;
    });

    if (_isEdit) {
      final p = await productRepo.findById(widget.productId!);
      if (!mounted) return;
      if (p != null) {
        setState(() {
          _name.text = p.name;
          _desc.text = p.description;
          _price.text = p.price.toString();
          _stock.text = p.stock.toString();
          _categoryId = p.categoryId;
          _brandId = p.brandId;
        });
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Читаем репозиторий и messenger ДО await
    final repo = context.read<ProductRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    setState(() => _saving = true);
    try {
      final product = Product(
        id: widget.productId,
        name: _name.text.trim(),
        description: _desc.text.trim(),
        price: double.parse(_price.text.trim()),
        stock: int.parse(_stock.text.trim()),
        categoryId: _categoryId,
        brandId: _brandId,
      );
      if (_isEdit) {
        await repo.update(product);
      } else {
        await repo.create(product);
      }
      if (mounted) router.go('/catalog');
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Ошибка сохранения: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(appBar: AppBar(), body: const LoadingView());
    }
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Редактирование' : 'Новый товар')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: 'Название',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        V.combine([V.required(), V.length(min: 2, max: 150)]),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _desc,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Описание',
                      border: OutlineInputBorder(),
                    ),
                    validator: V.length(max: 2000),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Цена',
                      border: OutlineInputBorder(),
                    ),
                    validator: V.combine([V.required(), V.positiveNumber()]),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stock,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Остаток',
                      border: OutlineInputBorder(),
                    ),
                    validator: V.combine([V.required(), V.integer(min: 0)]),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _categoryId,
                    decoration: const InputDecoration(
                      labelText: 'Категория',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories
                        .map((c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _categoryId = v),
                    validator: (v) => v == null ? 'Выберите категорию' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _brandId,
                    decoration: const InputDecoration(
                      labelText: 'Бренд',
                      border: OutlineInputBorder(),
                    ),
                    items: _brands
                        .map((b) =>
                            DropdownMenuItem(value: b.id, child: Text(b.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _brandId = v),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _saving ? null : _submit,
                    child: Text(_saving ? 'Сохранение...' : 'Сохранить'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}