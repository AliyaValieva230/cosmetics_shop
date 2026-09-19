import 'package:pocketbase/pocketbase.dart';

class Review {
  final String? id;
  final String userId;
  final String userName;
  final String productId;
  final int rating;
  final String text;

  Review({
    this.id,
    required this.userId,
    this.userName = '',
    required this.productId,
    required this.rating,
    this.text = '',
  });

  factory Review.fromRecord(RecordModel r) {
    final user = r.get<RecordModel>('expand.user');
    return Review(
      id: r.id,
      userId: r.getStringValue('user'),
      userName: user.getStringValue('name'),
      productId: r.getStringValue('product'),
      rating: r.getIntValue('rating'),
      text: r.getStringValue('text'),
    );
  }

  Map<String, dynamic> toJson() => {
        'user': userId,
        'product': productId,
        'rating': rating,
        'text': text,
      };
}