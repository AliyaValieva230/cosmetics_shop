import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://127.0.0.1:8090',
);

late final PocketBase pb;

Future<void> initPocketBase() async {
  final prefs = await SharedPreferences.getInstance();

  pb = PocketBase(
    apiUrl,
    authStore: AsyncAuthStore(
      save: (String data) async => prefs.setString('pb_auth', data),
      clear: () async => prefs.remove('pb_auth'),
      initial: prefs.getString('pb_auth'),
    ),
  );

  try {
    if (pb.authStore.isValid) {
      await pb.collection('users').authRefresh();
    }
  } catch (_) {
    pb.authStore.clear();
  }
}