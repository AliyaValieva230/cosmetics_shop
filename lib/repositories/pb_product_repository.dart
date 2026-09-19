import '../core/api_client.dart';
import '../models/product.dart';
import 'product_repository.dart';

class PbProductRepository implements ProductRepository {
  @override
  Future<ProductPage> findAll(ProductQuery query) async {
    final filters = <String>[];
    if (query.search != null && query.search!.isNotEmpty) {
      final s = query.search!.replaceAll('"', '');
      filters.add('(name ~ "$s" || description ~ "$s")');
    }
    if (query.categoryId != null) filters.add('category = "${query.categoryId}"');
    if (query.brandId != null) filters.add('brand = "${query.brandId}"');
    if (query.minPrice != null) filters.add('price >= ${query.minPrice}');
    if (query.maxPrice != null) filters.add('price <= ${query.maxPrice}');

    final result = await pb.collection('products').getList(
          page: query.page,
          perPage: query.perPage,
          sort: query.sort,
          filter: filters.join(' && '),
          expand: 'category,brand',
        );
    return ProductPage(
      items: result.items.map((e) => Product.fromRecord(e)).toList(),
      page: result.page,
      totalPages: result.totalPages,
      totalItems: result.totalItems,
    );
  }

  @override
  Future<Product?> findById(String id) async {
    try {
      final r = await pb.collection('products').getOne(id, expand: 'category,brand');
      return Product.fromRecord(r);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Product> create(Product p) async {
    final r = await pb.collection('products').create(body: p.toJson());
    return Product.fromRecord(r);
  }

  @override
  Future<Product> update(Product p) async {
    final r = await pb.collection('products').update(p.id!, body: p.toJson());
    return Product.fromRecord(r);
  }

  @override
  Future<void> delete(String id) async {
    await pb.collection('products').delete(id);
  }
}