import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';

enum LoadStatus { idle, loading, success, error }

class ProductListNotifier extends ChangeNotifier {
  final ProductRepository _repo;
  ProductListNotifier(this._repo);

  LoadStatus _status = LoadStatus.idle;
  String? _error;
  List<Product> _items = [];
  int _page = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  ProductQuery _query = ProductQuery();

  LoadStatus get status => _status;
  String? get error => _error;
  List<Product> get items => List.unmodifiable(_items);
  int get page => _page;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  ProductQuery get query => _query;

  Future<void> load({ProductQuery? query}) async {
    if (query != null) _query = query;
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final r = await _repo.findAll(_query);
      _items = r.items;
      _page = r.page;
      _totalPages = r.totalPages;
      _totalItems = r.totalItems;
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить данные';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> setPage(int p) async {
    _query = _query.copyWith(page: p);
    await load();
  }
}