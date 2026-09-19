import 'package:pocketbase/pocketbase.dart';

class Order {
  final String? id;
  final String userId;
  final String userName;
  final String status;
  final double total;
  final String address;
  final DateTime? created;

  Order({
    this.id,
    required this.userId,
    this.userName = '',
    this.status = 'new',
    required this.total,
    required this.address,
    this.created,
  });

  factory Order.fromRecord(RecordModel r) {
    final user = r.get<RecordModel>('expand.user');
    return Order(
      id: r.id,
      userId: r.getStringValue('user'),
      userName: user.getStringValue('name'),
      status: r.getStringValue('status'),
      total: r.getDoubleValue('total'),
      address: r.getStringValue('address'),
      created: DateTime.tryParse(r.getStringValue('created')),
    );
  }

  Map<String, dynamic> toJson() => {
        'user': userId,
        'status': status,
        'total': total,
        'address': address,
      };

  static const statuses = ['new', 'paid', 'shipped', 'done', 'cancelled'];
  static const statusLabels = {
    'new': 'Новый',
    'paid': 'Оплачен',
    'shipped': 'Отправлен',
    'done': 'Завершён',
    'cancelled': 'Отменён',
  };
}