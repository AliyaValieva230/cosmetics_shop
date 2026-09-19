import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'core/api_client.dart';
import 'core/router.dart';
import 'repositories/product_repository.dart';
import 'repositories/pb_product_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/pb_category_repository.dart';
import 'repositories/brand_repository.dart';
import 'repositories/pb_brand_repository.dart';
import 'repositories/tag_repository.dart';
import 'repositories/pb_tag_repository.dart';
import 'repositories/order_repository.dart';
import 'repositories/pb_order_repository.dart';
import 'repositories/review_repository.dart';
import 'repositories/pb_review_repository.dart';
import 'repositories/profile_repository.dart';
import 'repositories/pb_profile_repository.dart';
import 'state/auth_notifier.dart';
import 'state/product_list_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await initPocketBase();

  final productRepo = PbProductRepository();
  final categoryRepo = PbCategoryRepository();
  final brandRepo = PbBrandRepository();
  final tagRepo = PbTagRepository();
  final orderRepo = PbOrderRepository();
  final reviewRepo = PbReviewRepository();
  final profileRepo = PbProfileRepository();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthNotifier()),
      Provider<ProductRepository>.value(value: productRepo),
      Provider<CategoryRepository>.value(value: categoryRepo),
      Provider<BrandRepository>.value(value: brandRepo),
      Provider<TagRepository>.value(value: tagRepo),
      Provider<OrderRepository>.value(value: orderRepo),
      Provider<ReviewRepository>.value(value: reviewRepo),
      Provider<ProfileRepository>.value(value: profileRepo),
      ChangeNotifierProvider(
        create: (ctx) => ProductListNotifier(ctx.read<ProductRepository>()),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Магазин косметики',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.pink, useMaterial3: true),
      routerConfig: router,
    );
  }
}