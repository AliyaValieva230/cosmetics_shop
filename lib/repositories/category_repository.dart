import '../models/category.dart';

abstract interface class CategoryRepository {
  Future<List<Category>> findAll();
  Future<Category?> findById(String id);
  Future<Category> create(Category c);
  Future<Category> update(Category c);
  Future<void> delete(String id);
}