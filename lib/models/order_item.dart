import 'package:pocketbase/pocketbase.dart';

class OrderItem {
  final String? id;
  final String orderId;
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    this.id,
    required this.orderId,
    required this.productId,
    this.productName = '',
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromRecord(RecordModel r) {
  final product = r.get<RecordModel>('expand.product');
  return OrderItem(
    id: r.id,
    orderId: r.getStringValue('order'),
    productId: r.getStringValue('product'),
    productName: product.getStringValue('name'),
    quantity: r.getIntValue('quantity'),
    price: r.getDoubleValue('price'),
  );
}

  Map<String, dynamic> toJson() => {
        'order': orderId,
        'product': productId,
        'quantity': quantity,
        'price': price,
      };
}