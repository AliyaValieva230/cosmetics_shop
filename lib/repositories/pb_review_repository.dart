import '../core/api_client.dart';
import '../models/review.dart';
import 'review_repository.dart';

class PbReviewRepository implements ReviewRepository {
  @override
  Future<List<Review>> findByProduct(String productId) async {
    final r = await pb.collection('reviews').getFullList(
          filter: 'product = "$productId"',
          sort: '-created',
          expand: 'user',
        );
    return r.map((e) => Review.fromRecord(e)).toList();
  }

  @override
  Future<Review> create(Review rev) async {
    final r = await pb.collection('reviews').create(body: rev.toJson());
    return Review.fromRecord(r);
  }

  @override
  Future<void> delete(String id) async {
    await pb.collection('reviews').delete(id);
  }
}