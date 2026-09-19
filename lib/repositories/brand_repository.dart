import '../models/brand.dart';

abstract interface class BrandRepository {
  Future<List<Brand>> findAll();
  Future<Brand?> findById(String id);
  Future<Brand> create(Brand b);
  Future<Brand> update(Brand b);
  Future<void> delete(String id);
}