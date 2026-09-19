import '../models/profile.dart';

abstract interface class ProfileRepository {
  Future<Profile?> findByUserId(String userId);
  Future<Profile> create(Profile p);
  Future<Profile> update(Profile p);
  Future<void> delete(String id);
}