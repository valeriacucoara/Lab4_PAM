import '../entities/product.dart';
import '../entities/store_feed.dart';

/// Contract: stratul Presentation nu depinde de clientul HTTP.
abstract class StoreRepository {
  Future<StoreFeed> fetchFeed();
  /// Endpoint-ul /feed/details ofera detalii doar pentru produsul p003.
  Future<Product> fetchDetails();
  void dispose();
}
