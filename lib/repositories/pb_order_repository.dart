import '../core/api_client.dart';
import '../models/order.dart';
import 'order_repository.dart';

class PbOrderRepository implements OrderRepository {
  @override
  Future<List<Order>> findAll({
    String? status, String? userId,
    int page = 1, int perPage = 20, String sort = '-created',
  }) async {
    final filters = <String>[];
    if (status != null) filters.add('status = "$status"');
    if (userId != null) filters.add('user = "$userId"');
    final r = await pb.collection('orders').getList(
          page: page, perPage: perPage, sort: sort,
          filter: filters.join(' && '), expand: 'user',
        );
    return r.items.map((e) => Order.fromRecord(e)).toList();
  }

  @override
  Future<Order?> findById(String id) async {
    try {
      final r = await pb.collection('orders').getOne(id, expand: 'user');
      return Order.fromRecord(r);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Order> create(Order o) async {
    final r = await pb.collection('orders').create(body: o.toJson());
    return Order.fromRecord(r);
  }

  @override
  Future<Order> update(Order o) async {
    final r = await pb.collection('orders').update(o.id!, body: o.toJson());
    return Order.fromRecord(r);
  }

  @override
  Future<void> delete(String id) async {
    await pb.collection('orders').delete(id);
  }
}