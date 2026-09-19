import '../core/api_client.dart';
import '../models/category.dart';
import 'category_repository.dart';

class PbCategoryRepository implements CategoryRepository {
  @override
  Future<List<Category>> findAll() async {
    final r = await pb.collection('categories').getFullList(sort: 'name');
    return r.map((e) => Category.fromRecord(e)).toList();
  }

  @override
  Future<Category?> findById(String id) async {
    try {
      final r = await pb.collection('categories').getOne(id);
      return Category.fromRecord(r);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Category> create(Category c) async {
    final r = await pb.collection('categories').create(body: c.toJson());
    return Category.fromRecord(r);
  }

  @override
  Future<Category> update(Category c) async {
    final r = await pb.collection('categories').update(c.id!, body: c.toJson());
    return Category.fromRecord(r);
  }

  @override
  Future<void> delete(String id) async {
    await pb.collection('categories').delete(id);
  }
}