/// Entitati ale domeniului: nu cunosc HTTP, JSON sau widget-uri Flutter.
class ProductColor {
  final String id;
  final String name;
  final String value;
  const ProductColor({required this.id, required this.name, required this.value});
}

class ProductReview {
  final String id;
  final String author;
  final String avatarUrl;
  final double rating;
  final String createdAtLabel;
  final String text;
  const ProductReview({
    required this.id, required this.author, required this.avatarUrl,
    required this.rating, required this.createdAtLabel, required this.text,
  });
}

class RatingBreakdown {
  final int stars;
  final int percentage;
  const RatingBreakdown({required this.stars, required this.percentage});
}

class Product {
  final String id;
  final String name;
  final double price;
  final String currency;
  final String imageUrl;
  final double? rating;
  final int? ratingCount;
  final int? reviewCount;
  final String? description;
  final List<ProductColor> availableColors;
  final List<String> availableSizes;
  final String? selectedColor;
  final String? selectedSize;
  final Map<String, bool> sizeAvailability;
  final List<ProductReview> reviews;
  final List<Product> similarProducts;
  final List<String> galleryImageUrls;
  final List<RatingBreakdown> ratingBreakdown;
  final bool canAddToCart;
  final String addToCartLabel;
  final bool? initialFavorite;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.imageUrl,
    this.rating,
    this.ratingCount,
    this.reviewCount,
    this.description,
    this.availableColors = const [],
    this.availableSizes = const [],
    this.selectedColor,
    this.selectedSize,
    this.sizeAvailability = const {},
    this.reviews = const [],
    this.similarProducts = const [],
    this.galleryImageUrls = const [],
    this.ratingBreakdown = const [],
    this.canAddToCart = true,
    this.addToCartLabel = 'Add To Cart',
    this.initialFavorite,
  });
}
