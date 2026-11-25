import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/store_cubit.dart';
import '../cubit/product_detail_cubit.dart';
import '../cubit/cart_cubit.dart';
import '../widgets/store_sections.dart';
import 'cart_page.dart';
import '../../domain/entities/product.dart';

class ProductPage extends StatelessWidget {
  final Product product;

  const ProductPage({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final detailState = context.watch<ProductDetailCubit>().state;
    final Product viewProduct = detailState.product;
    final bool favorite = context.watch<StoreCubit>().isFavorite(viewProduct.id);

    // /feed/details livreaza exclusiv p003. Pentru celelalte produse
    // nu inventam descrieri, variante, recenzii ori ratinguri.
    final bool useJsonDetails = viewProduct.id == 'p003' && viewProduct.description != null;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (detailState is ProductDetailLoading)
                const LinearProgressIndicator(minHeight: 2, color: Color(0xFF4E8E82)),
              if (detailState is ProductDetailFailure)
                Padding(padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(children: [
                    const Expanded(child: Text('Details unavailable. Please retry.',
                      style: TextStyle(fontSize: 12, color: Colors.redAccent))),
                    TextButton(onPressed: () => context.read<ProductDetailCubit>().load(),
                      child: const Text('Retry')),
                  ])),

              // Imaginea mare
              SizedBox(
                height: 420,
                child: Stack(
                  alignment: Alignment.center,
                  children: [

                    Container(
                      width: 260,
                      height: 260,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF1EC),
                        shape: BoxShape.circle,
                      ),
                    ),

                    // Pentru Sportwear Set pastram imaginea din Lab 2
                    viewProduct.id == 'p003'
                        ? ApiImage(
                      url: viewProduct.imageUrl,
                      assetFallback: 'assets/images/8.png',
                      height: 400, width: 260, fit: BoxFit.contain,
                    )
                        : Image.network(
                      viewProduct.imageUrl,
                      height: 330,
                      width: 260,
                      fit: BoxFit.cover,

                      loadingBuilder: (
                          context,
                          child,
                          loadingProgress,
                          ) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return const SizedBox(
                          height: 330,
                          width: 260,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },

                      errorBuilder: (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return Container(
                          height: 330,
                          width: 260,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),

                    // Buton inapoi
                    Positioned(
                      top: 15,
                      left: 20,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // Favorite
                    Positioned(
                      top: 15,
                      right: 20,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          onPressed: () {
                            context
                                .read<StoreCubit>()
                                .toggleFavorite(viewProduct.id);
                          },
                          icon: Icon(
                            favorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: favorite
                                ? Colors.redAccent
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Detaliile produsului
              Container(
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Nume si pret
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Expanded(
                          child: Text(
                            viewProduct.name,
                            style: const TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ),

                        const SizedBox(width: 15),

                        Text(
                          '\$ ${viewProduct.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Rating
                    useJsonDetails
                        ? Row(
                      children: [
                        const Text(
                          '★★★★★',
                          style: TextStyle(
                            color: Color(0xFF4E8E82),
                          ),
                        ),

                        const SizedBox(width: 5),

                        Text(
                          '(${viewProduct.ratingCount ?? 83})',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),

                        const Spacer(),

                        Text(
                          viewProduct.rating?.toStringAsFixed(1) ?? '4.9',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                        : const Text(
                      'Rating not provided by API',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                    const SizedBox(height: 25),

                    const Divider(),

                    // Color si Size
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Color'),
                        Text('Size'),
                      ],
                    ),

                    const SizedBox(height: 20),

                    useJsonDetails
                        ? Row(
                      children: [

                        // Culorile din JSON
                        ...viewProduct.availableColors.map(
                              (productColor) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                right: 12,
                              ),
                              child: circleColor(
                                hexToColor(productColor.value),
                                selected:
                                viewProduct.selectedColor ==
                                    productColor.id,
                              ),
                            );
                          },
                        ),

                        const Spacer(),

                        // Marimile din JSON
                        ...viewProduct.availableSizes.map(
                              (size) {
                            return sizeCircle(
                              size,
                              selected: viewProduct.selectedSize == size,
                              available: viewProduct.sizeAvailability[size] ?? true,
                            );
                          },
                        ),
                      ],
                    )
                        : const Text('Variants not provided by API for this product.',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),

                    const SizedBox(height: 30),

                    const Divider(),

                    // Description
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Text(
                      viewProduct.description ??
                        'Description not provided by API for this product.',
                      style: const TextStyle(
                        color: Colors.grey, height: 1.5, fontSize: 12),
                    ),

                    const SizedBox(height: 25),

                    const Divider(),

                    // Reviews
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Reviews'),
                        Icon(
                          Icons.keyboard_arrow_down,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Aceeasi sectiune de rating, dar procentele sunt din API.
                    if (useJsonDetails)
                      ApiRatingBreakdown(product: viewProduct)
                    else
                      const Text('Ratings not provided by API.',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),

                    const SizedBox(height: 30),

                    // Pentru Sportwear Set review-urile vin din JSON
                    if (useJsonDetails)
                      ...viewProduct.reviews.map(
                            (productReview) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: 30,
                            ),
                            child: reviewFromJson(
                              productReview,
                            ),
                          );
                        },
                      )
                    else
                      const Text('No reviews provided by API for this product.',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),

                    const SizedBox(height: 30),

                    const Divider(),

                    // Similar Product
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Similar Product',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    ApiSimilarProducts(products: useJsonDetails
                      ? viewProduct.similarProducts
                      : (context.read<StoreCubit>().feed?.recommended ?? const [])),

                    const SizedBox(height: 25),

                    // Add To Cart
                    InkWell(
                      onTap: viewProduct.canAddToCart ? () {
                        context.read<CartCubit>().add(viewProduct);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('${viewProduct.name} added to cart'),
                          action: SnackBarAction(label: 'View Cart', onPressed: () {
                            Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const CartPage()));
                          }),
                        ));
                      } : null,
                      child: Image.asset('assets/images/13.png', width: double.infinity),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Creeaza cercurile pentru culori
Widget circleColor(
    Color color, {
      bool selected = false,
    }) {
  return Container(
    width: 32,
    height: 32,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: selected
          ? Border.all(
        color: Colors.grey.shade500,
        width: 2,
      )
          : null,
      boxShadow: selected
          ? [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 5,
        ),
      ]
          : null,
    ),
    child: Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    ),
  );
}

// Transforma culoarea din JSON in Color
Color hexToColor(String hex) {
  String value = hex.replaceAll('#', '');

  if (value.length == 6) {
    value = 'FF$value';
  }

  return Color(
    int.parse(value, radix: 16),
  );
}

// Creeaza cercurile pentru marimi
Widget sizeCircle(
    String text, {
      bool selected = false,
      bool available = true,
    }) {
  return Opacity(opacity: available ? 1 : 0.35, child: Container(
    margin: const EdgeInsets.only(left: 8),
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      color: selected
          ? Colors.grey.shade700
          : Colors.grey.shade100,
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Text(
        text,
        style: TextStyle(
          color: selected
              ? Colors.white
              : Colors.grey,
        ),
      ),
    ),
  ));
}

// Review folosit pentru produsele care pastreaza designul din Lab 2
Widget review(
    String image,
    String name,
    String time,
    String description,
    ) {
  return Column(
    children: [

      Row(
        children: [

          ClipOval(
            child: Image.asset(
              image,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Text(
                  '★★★★★',
                  style: TextStyle(
                    color: Color(0xFF4E8E82),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Text(
            time,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),

      const SizedBox(height: 12),

      Text(
        description,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11,
          height: 1.5,
        ),
      ),
    ],
  );
}

// Review citit din JSON
Widget reviewFromJson(ProductReview review) {
  return Column(
    children: [

      Row(
        children: [

          ClipOval(
            child: Image.network(
              review.avatarUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,

              errorBuilder: (
                  context,
                  error,
                  stackTrace,
                  ) {
                return Container(
                  width: 40,
                  height: 40,
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.person,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  review.author,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),

                Text(
                  createStars(review.rating),
                  style: const TextStyle(
                    color: Color(0xFF4E8E82),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Text(
            review.createdAtLabel,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),

      const SizedBox(height: 12),

      Text(
        review.text,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11,
          height: 1.5,
        ),
      ),
    ],
  );
}

// Creeaza stelele in functie de rating
String createStars(double rating) {
  final int starCount = rating.round();

  return List.generate(
    5,
        (index) => index < starCount ? '★' : '☆',
  ).join();
}