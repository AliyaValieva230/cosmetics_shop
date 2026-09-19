import '../core/api_client.dart';
import '../models/profile.dart';
import 'profile_repository.dart';

class PbProfileRepository implements ProfileRepository {
  @override
  Future<Profile?> findByUserId(String userId) async {
    try {
      final r = await pb.collection('profiles').getFirstListItem('user = "$userId"');
      return Profile.fromRecord(r);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Profile> create(Profile p) async {
    final r = await pb.collection('profiles').create(body: p.toJson());
    return Profile.fromRecord(r);
  }

  @override
  Future<Profile> update(Profile p) async {
    final r = await pb.collection('profiles').update(p.id!, body: p.toJson());
    return Profile.fromRecord(r);
  }

  @override
  Future<void> delete(String id) async {
    await pb.collection('profiles').delete(id);
  }
}