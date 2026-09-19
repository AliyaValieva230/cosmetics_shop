import '../models/product.dart';

class ProductQuery {
  final String? search;
  final String? categoryId;
  final String? brandId;
  final double? minPrice;
  final double? maxPrice;
  final int page;
  final int perPage;
  final String sort;

  ProductQuery({
    this.search, this.categoryId, this.brandId,
    this.minPrice, this.maxPrice,
    this.page = 1, this.perPage = 12, this.sort = '-created',
  });

  ProductQuery copyWith({
    String? search, String? categoryId, String? brandId,
    double? minPrice, double? maxPrice,
    int? page, int? perPage, String? sort,
  }) =>
      ProductQuery(
        search: search ?? this.search,
        categoryId: categoryId ?? this.categoryId,
        brandId: brandId ?? this.brandId,
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
        page: page ?? this.page,
        perPage: perPage ?? this.perPage,
        sort: sort ?? this.sort,
      );

  Map<String, String> toQueryParams() {
    final m = <String, String>{};
    if (search != null && search!.isNotEmpty) m['q'] = search!;
    if (categoryId != null) m['cat'] = categoryId!;
    if (brandId != null) m['brand'] = brandId!;
    if (minPrice != null) m['min'] = minPrice!.toString();
    if (maxPrice != null) m['max'] = maxPrice!.toString();
    if (page > 1) m['page'] = page.toString();
    if (sort != '-created') m['sort'] = sort;
    return m;
  }

  factory ProductQuery.fromQueryParams(Map<String, String> p) => ProductQuery(
        search: p['q'],
        categoryId: p['cat'],
        brandId: p['brand'],
        minPrice: p['min'] != null ? double.tryParse(p['min']!) : null,
        maxPrice: p['max'] != null ? double.tryParse(p['max']!) : null,
        page: int.tryParse(p['page'] ?? '1') ?? 1,
        sort: p['sort'] ?? '-created',
      );
}

class ProductPage {
  final List<Product> items;
  final int page;
  final int totalPages;
  final int totalItems;
  ProductPage({
    required this.items, required this.page,
    required this.totalPages, required this.totalItems,
  });
}

abstract interface class ProductRepository {
  Future<ProductPage> findAll(ProductQuery query);
  Future<Product?> findById(String id);
  Future<Product> create(Product product);
  Future<Product> update(Product product);
  Future<void> delete(String id);
}