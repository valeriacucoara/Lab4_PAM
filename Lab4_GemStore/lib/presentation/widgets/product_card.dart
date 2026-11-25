import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // IMAGINE PRODUS
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product.imageUrl,
                    width: 160,
                    height: 200,
                    fit: BoxFit.cover,

                    // Daca imaginea se incarca
                    loadingBuilder: (
                        context,
                        child,
                        loadingProgress,
                        ) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return Container(
                        width: 160,
                        height: 200,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },

                    // Daca URL-ul imaginii da eroare
                    errorBuilder: (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return Container(
                        width: 160,
                        height: 200,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 40,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),

                // FAVORITE
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavorite,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: isFavorite
                            ? Colors.redAccent
                            : Colors.grey.shade700,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // NUME PRODUS
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 5),

            // PRET
            Text(
              '\$ ${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}