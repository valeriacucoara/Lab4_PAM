import '../../domain/entities/product.dart';
import '../../domain/entities/store_feed.dart';

/// Maparea JSON -> entitati se face exclusiv in stratul Data.
class ProductDto {
  static Product fromJson(Map<String, dynamic> json) {
    List<dynamic> listOf(String key) => (json[key] as List<dynamic>?) ?? const [];
    final actions = (json['actions'] as Map<String, dynamic>?) ?? const {};
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      imageUrl: (json['mainImageUrl'] ?? json['imageUrl'] ?? '') as String,
      rating: (json['rating'] as num?)?.toDouble(),
      ratingCount: (json['ratingCount'] as num?)?.toInt(),
      reviewCount: (json['reviewCount'] as num?)?.toInt(),
      description: json['description'] as String?,
      availableColors: listOf('availableColors').map((item) {
        final color = item as Map<String, dynamic>;
        return ProductColor(
          id: color['id'] as String,
          name: color['name'] as String,
          value: color['value'] as String,
        );
      }).toList(),
      availableSizes: listOf('availableSizes').map((s) => s.toString()).toList(),
      selectedColor: json['selectedColor'] as String?,
      selectedSize: json['selectedSize'] as String?,
      sizeAvailability: ((json['sizeAvailability'] as Map<String, dynamic>?) ?? const {})
          .map((key, value) => MapEntry(key, value == true)),
      reviews: listOf('reviews').map((item) {
        final review = item as Map<String, dynamic>;
        return ProductReview(
          id: review['id'] as String,
          author: review['author'] as String,
          avatarUrl: review['avatarUrl'] as String,
          rating: (review['rating'] as num).toDouble(),
          createdAtLabel: review['createdAtLabel'] as String,
          text: review['text'] as String,
        );
      }).toList(),
      galleryImageUrls: listOf('galleryImageUrls').map((url) => url.toString()).toList(),
      ratingBreakdown: listOf('ratingBreakdown').map((item) {
        final rating = item as Map<String, dynamic>;
        return RatingBreakdown(
          stars: (rating['stars'] as num).toInt(),
          percentage: (rating['percentage'] as num).toInt(),
        );
      }).toList(),
      similarProducts: listOf('similarProducts').map((item) =>
        fromJson(item as Map<String, dynamic>)).toList(),
      canAddToCart: actions['canAddToCart'] != false,
      addToCartLabel: actions['addToCartLabel'] as String? ?? 'Add To Cart',
      initialFavorite: actions['isFavorite'] as bool?,
    );
  }
}

class StoreFeedDto {
  static StoreFeed fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> mapOf(String key) => json[key] as Map<String, dynamic>;
    List<dynamic> listOf(String key) => json[key] as List<dynamic>;
    StoreBanner banner(Map<String, dynamic> item) => StoreBanner(
      id: item['id'] as String? ?? '',
      title: item['title'] as String,
      imageUrl: item['imageUrl'] as String,
      label: (item['label'] ?? item['category'] ?? '') as String,
      action: item['action'] as String? ?? '',
    );
    return StoreFeed(
      storeName: json['storeName'] as String,
      categories: listOf('categories').map((item) {
        final category = item as Map<String, dynamic>;
        return StoreCategory(
          id: category['id'] as String,
          name: category['name'] as String,
          iconUrl: category['iconUrl'] as String,
          selected: category['selected'] == true,
        );
      }).toList(),
      heroBanner: banner(mapOf('heroBanner')),
      featureProducts: listOf('featureProducts').map((item) =>
        ProductDto.fromJson(item as Map<String, dynamic>)).toList(),
      newCollection: banner(mapOf('newCollection')),
      recommended: listOf('recommended').map((item) =>
        ProductDto.fromJson(item as Map<String, dynamic>)).toList(),
      topCollections: listOf('topCollections').map((item) =>
        banner(item as Map<String, dynamic>)).toList(),
      categoryPromos: listOf('categoryPromos').map((item) =>
        banner(item as Map<String, dynamic>)).toList(),
    );
  }
}
