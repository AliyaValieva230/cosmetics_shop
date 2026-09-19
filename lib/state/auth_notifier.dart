import 'package:flutter/foundation.dart';
import '../core/api_client.dart';

class AuthNotifier extends ChangeNotifier {
  bool get isLoggedIn => pb.authStore.isValid;
  String get role => pb.authStore.record?.getStringValue('role') ?? '';
  String get userId => pb.authStore.record?.id ?? '';
  String get userName => pb.authStore.record?.getStringValue('name') ?? '';
  String get userEmail => pb.authStore.record?.getStringValue('email') ?? '';
  bool get isCustomer => role == 'customer';
  bool get isManager => role == 'manager';
  bool get isAdmin => role == 'admin';

  Future<void> login(String email, String password) async {
    await pb.collection('users').authWithPassword(email, password);
    notifyListeners();
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    await pb.collection('users').create(body: {
      'email': email,
      'password': password,
      'passwordConfirm': password,
      'name': name,
      'role': 'customer',
    });
    await login(email, password);
    try {
      await pb.collection('profiles').create(body: {
        'user': pb.authStore.record!.id,
        'phone': '',
        'address': '',
        'bonus_balance': 0,
      });
    } catch (_) {}
  }

  void logout() {
    pb.authStore.clear();
    notifyListeners();
  }
}