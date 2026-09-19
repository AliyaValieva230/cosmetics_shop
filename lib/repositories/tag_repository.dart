import '../models/tag.dart';

abstract interface class TagRepository {
  Future<List<Tag>> findAll();
  Future<Tag> create(Tag t);
  Future<Tag> update(Tag t);
  Future<void> delete(String id);
}