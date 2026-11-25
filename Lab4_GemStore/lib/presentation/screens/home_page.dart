import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/store_cubit.dart';
import '../cubit/store_state.dart';
import '../cubit/product_detail_cubit.dart';
import '../../domain/entities/store_feed.dart';
import '../../domain/repositories/store_repository.dart';
import '../widgets/store_sections.dart';
import 'cart_page.dart';
import '../../domain/entities/product.dart';
import '../widgets/product_card.dart';
import 'product_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final StoreCubit cubit = context.watch<StoreCubit>();
    final StoreFeed? feed = cubit.feed;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 20),

              // HEADER - aceleasi controale ca in Lab3, plus acces la cosul local.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Icon(Icons.menu),
                  Text(feed?.storeName ?? 'GemStore',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.notifications_none),
                    const SizedBox(width: 7),
                    IconButton(tooltip: 'My Cart', visualDensity: VisualDensity.compact,
                      onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CartPage())),
                      icon: const Icon(Icons.shopping_bag_outlined)),
                  ]),
                ]),
              ),

              const SizedBox(height: 25),

              // Categoriile sunt citite din /feed, iconitele raman in stilul Lab3.
              Padding(padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: (feed?.categories ?? const <StoreCategory>[])
                    .map((category) => Category(
                      icon: iconForCategory(category.id), text: category.name)).toList(),
                ),
              ),

              const SizedBox(height: 25),

              // Autumn Collection: acelasi format, imagine si titlu din API.
              Padding(padding: const EdgeInsets.symmetric(horizontal: 25),
                child: feed == null
                  ? SizedBox(height: 180, child: Center(child:
                      cubit.state is StoreLoading
                        ? const CircularProgressIndicator()
                        : const Text('Unable to load the online collection.',
                            style: TextStyle(color: Colors.grey))))
                  : ApiHeroBanner(banner: feed.heroBanner),
              ),

              const SizedBox(height: 25),

              // ====================================================
              // SEARCH - NOU IN LAB 3
              // ====================================================

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextField(
                  onChanged: (value) {
                    cubit.searchProducts(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ====================================================
              // FILTER + SORT - NOI IN LAB 3
              // ====================================================

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  children: [

                    Expanded(
                      child: DropdownButtonFormField<PriceFilter>(
                        initialValue: cubit.priceFilter,
                        decoration: InputDecoration(
                          labelText: 'Filter',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: PriceFilter.all,
                            child: Text('All'),
                          ),
                          DropdownMenuItem(
                            value: PriceFilter.under40,
                            child: Text('Under \$40'),
                          ),
                          DropdownMenuItem(
                            value: PriceFilter.between40And60,
                            child: Text('\$40 - \$60'),
                          ),
                          DropdownMenuItem(
                            value: PriceFilter.over60,
                            child: Text('Over \$60'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            cubit.filterByPrice(value);
                          }
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: DropdownButtonFormField<SortOption>(
                        initialValue: cubit.sortOption,
                        decoration: InputDecoration(
                          labelText: 'Sort',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: SortOption.defaultOrder,
                            child: Text('Default'),
                          ),
                          DropdownMenuItem(
                            value: SortOption.priceLowToHigh,
                            child: Text('Price ↑'),
                          ),
                          DropdownMenuItem(
                            value: SortOption.priceHighToLow,
                            child: Text('Price ↓'),
                          ),
                          DropdownMenuItem(
                            value: SortOption.nameAZ,
                            child: Text('Name A-Z'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            cubit.sortProducts(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // FEATURE PRODUCTS
              const SectionTitle(
                title: 'Feature Products',
              ),

              const SizedBox(height: 15),

              // ====================================================
              // PRODUSELE ACUM VIN DIN JSON
              // ====================================================

              BlocBuilder<StoreCubit, StoreState>(
                builder: (context, state) {

                  // LOADING
                  if (state is StoreLoading) {
                    return const SizedBox(
                      height: 240,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Loading products...'),
                          ],
                        ),
                      ),
                    );
                  }

                  // ERROR
                  if (state is StoreError) {
                    return SizedBox(
                      height: 220,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 45,
                            ),

                            const SizedBox(height: 10),

                            Text(state.message),

                            const SizedBox(height: 10),

                            ElevatedButton(
                              onPressed: () {
                                context
                                    .read<StoreCubit>()
                                    .loadProducts();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // EMPTY
                  if (state is StoreEmpty) {
                    return const SizedBox(
                      height: 220,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No products found',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // SUCCESS
                  if (state is StoreSuccess) {
                    return SizedBox(
                      height: 265,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(
                          left: 25,
                          right: 10,
                        ),
                        itemCount: state.products.length,
                        itemBuilder: (context, index) {
                          final Product product =
                          state.products[index];

                          return ProductCard(
                            product: product,

                            isFavorite: state.favorites.contains(
                              product.id,
                            ),

                            // FAVORITE
                            onFavorite: () {
                              context
                                  .read<StoreCubit>()
                                  .toggleFavorite(
                                product.id,
                              );
                            },

                            // PRODUCT DETAILS
                            onTap: () => openProductPage(context, product),
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),

              const SizedBox(height: 25),

              // NEW COLLECTION: imaginea si textul din API, layout-ul Lab3.
              if (feed != null) ApiNewCollection(banner: feed.newCollection),

              const SizedBox(height: 30),

              const SectionTitle(title: 'Recommended'),
              const SizedBox(height: 15),
              if (feed != null) ApiRecommended(
                products: feed.recommended,
                onTap: (product) => openProductPage(context, product),
              ),

              const SizedBox(height: 30),

              const SectionTitle(title: 'Top Collection'),
              const SizedBox(height: 15),

              if (feed != null)
                ...feed.topCollections.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
                  child: ApiCollectionCard(banner: entry.value,
                    aspectRatio: entry.key == 0 ? 936 / 424 : 936 / 687),
                )),

              if (feed != null && feed.categoryPromos.isNotEmpty)
                Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ApiCategoryPromos(banners: feed.categoryPromos)),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// CATEGORIE - PASTRATA DIN LAB 2
// ===============================================================

class Category extends StatelessWidget {
  final IconData icon;
  final String text;

  const Category({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFFF5F5F5),
          child: Icon(
            icon,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

// ===============================================================
// TITLURI - PASTRAT DIN LAB 2
// ===============================================================

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Text(
            'Show all',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
// Nu punem HTTP in UI: ecranul cere datele prin repository-ul din Domain.
void openProductPage(BuildContext context, Product product) {
  final repository = context.read<StoreRepository>();
  Navigator.push(context, MaterialPageRoute(builder: (_) =>
    BlocProvider<ProductDetailCubit>(
      create: (_) => ProductDetailCubit(repository, product)..load(),
      child: ProductPage(product: product),
    ),
  ));
}

IconData iconForCategory(String id) {
  switch (id) {
    case 'women': return Icons.female;
    case 'men': return Icons.male;
    case 'accessories': return Icons.remove_red_eye_outlined;
    case 'beauty': return Icons.brush_outlined;
    default: return Icons.category_outlined;
  }
}
