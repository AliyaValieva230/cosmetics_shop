import '../core/api_client.dart';
import '../models/brand.dart';
import 'brand_repository.dart';

class PbBrandRepository implements BrandRepository {
  @override
  Future<List<Brand>> findAll() async {
    final r = await pb.collection('brands').getFullList(sort: 'name');
    return r.map((e) => Brand.fromRecord(e)).toList();
  }

  @override
  Future<Brand?> findById(String id) async {
    try {
      final r = await pb.collection('brands').getOne(id);
      return Brand.fromRecord(r);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Brand> create(Brand b) async {
    final r = await pb.collection('brands').create(body: b.toJson());
    return Brand.fromRecord(r);
  }

  @override
  Future<Brand> update(Brand b) async {
    final r = await pb.collection('brands').update(b.id!, body: b.toJson());
    return Brand.fromRecord(r);
  }

  @override
  Future<void> delete(String id) async {
    await pb.collection('brands').delete(id);
  }
}