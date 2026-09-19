import '../models/order.dart';

abstract interface class OrderRepository {
  Future<List<Order>> findAll({
    String? status, String? userId,
    int page = 1, int perPage = 20, String sort = '-created',
  });
  Future<Order?> findById(String id);
  Future<Order> create(Order o);
  Future<Order> update(Order o);
  Future<void> delete(String id);
}