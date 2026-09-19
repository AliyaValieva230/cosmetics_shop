import '../core/api_client.dart';
import '../models/tag.dart';
import 'tag_repository.dart';

class PbTagRepository implements TagRepository {
  @override
  Future<List<Tag>> findAll() async {
    final r = await pb.collection('tags').getFullList(sort: 'name');
    return r.map((e) => Tag.fromRecord(e)).toList();
  }

  @override
  Future<Tag> create(Tag t) async {
    final r = await pb.collection('tags').create(body: t.toJson());
    return Tag.fromRecord(r);
  }

  @override
  Future<Tag> update(Tag t) async {
    final r = await pb.collection('tags').update(t.id!, body: t.toJson());
    return Tag.fromRecord(r);
  }

  @override
  Future<void> delete(String id) async {
    await pb.collection('tags').delete(id);
  }
}