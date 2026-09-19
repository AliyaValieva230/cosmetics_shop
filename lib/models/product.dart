import 'package:pocketbase/pocketbase.dart';

class Product {
  final String? id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? categoryId;
  final String? brandId;
  final String? categoryName;
  final String? brandName;

  Product({
    this.id,
    required this.name,
    this.description = '',
    required this.price,
    required this.stock,
    this.categoryId,
    this.brandId,
    this.categoryName,
    this.brandName,
  });

  factory Product.fromRecord(RecordModel r) {
  final category = r.get<RecordModel>('expand.category');
  final brand = r.get<RecordModel>('expand.brand');
  return Product(
    id: r.id,
    name: r.getStringValue('name'),
    description: r.getStringValue('description'),
    price: r.getDoubleValue('price'),
    stock: r.getIntValue('stock'),
    categoryId: r.getStringValue('category'),
    brandId: r.getStringValue('brand'),
    categoryName: category.getStringValue('name'),
    brandName: brand.getStringValue('name'),
  );
}

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'category': categoryId,
        'brand': brandId,
      };
}