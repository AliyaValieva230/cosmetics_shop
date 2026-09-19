import '../models/review.dart';

abstract interface class ReviewRepository {
  Future<List<Review>> findByProduct(String productId);
  Future<Review> create(Review r);
  Future<void> delete(String id);
}