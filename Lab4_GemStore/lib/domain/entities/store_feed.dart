import 'product.dart';

class StoreCategory {
  final String id;
  final String name;
  final String iconUrl;
  final bool selected;
  const StoreCategory({required this.id, required this.name, required this.iconUrl, required this.selected});
}

class StoreBanner {
  final String id;
  final String title;
  final String imageUrl;
  final String label;
  final String action;
  const StoreBanner({
    required this.id, required this.title, required this.imageUrl,
    this.label = '', this.action = '',
  });
}

class StoreFeed {
  final String storeName;
  final List<StoreCategory> categories;
  final StoreBanner heroBanner;
  final List<Product> featureProducts;
  final StoreBanner newCollection;
  final List<Product> recommended;
  final List<StoreBanner> topCollections;
  final List<StoreBanner> categoryPromos;
  const StoreFeed({
    required this.storeName, required this.categories,
    required this.heroBanner, required this.featureProducts,
    required this.newCollection, required this.recommended,
    required this.topCollections, required this.categoryPromos,
  });
}
