import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/store_feed.dart';

/// Componenta UI reutilizabila. Sursa imaginii si textului este feed-ul HTTP.
class ApiImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? assetFallback;
  const ApiImage({super.key, required this.url, this.width, this.height,
    this.fit = BoxFit.cover, this.assetFallback});

  @override
  Widget build(BuildContext context) {
    Widget fallback() => assetFallback == null
      ? Container(width: width, height: height, color: Colors.grey.shade100,
          alignment: Alignment.center, child: const Icon(Icons.image_outlined, color: Colors.grey))
      : Image.asset(assetFallback!, width: width, height: height, fit: fit);
    return Image.network(url, width: width, height: height, fit: fit,
      loadingBuilder: (context, child, progress) => progress == null ? child : fallback(),
      errorBuilder: (context, error, stack) => fallback());
  }
}

class ApiHeroBanner extends StatelessWidget {
  final StoreBanner banner;
  const ApiHeroBanner({super.key, required this.banner});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(15),
    child: AspectRatio(aspectRatio: 312 / 168, child: Stack(fit: StackFit.expand,
      children: [
        ApiImage(url: banner.imageUrl, assetFallback: 'assets/images/1.png'),
        const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.centerLeft, end: Alignment.centerRight,
          colors: [Colors.transparent, Color(0x88000000)],
        ))),
        Positioned(right: 15, top: 25, child: SizedBox(width: 145, child: Text(
          banner.title.replaceAll(' ', '\n'), textAlign: TextAlign.right,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ))),
      ],
    )),
  );
}

class ApiNewCollection extends StatelessWidget {
  final StoreBanner banner;
  const ApiNewCollection({super.key, required this.banner});
  @override
  Widget build(BuildContext context) => AspectRatio(aspectRatio: 375 / 158,
    child: Row(children: [
      Expanded(flex: 5, child: Padding(padding: const EdgeInsets.only(left: 25, top: 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('|  ${banner.label}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 14),
          Text(banner.title.replaceAll(' & ', '\n& '), style: const TextStyle(fontSize: 20, color: Color(0xFF34343A))),
        ]))),
      Expanded(flex: 5, child: ApiImage(url: banner.imageUrl, assetFallback: 'assets/images/3.png')),
    ]));
}

class ApiRecommended extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onTap;
  const ApiRecommended({super.key, required this.products, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(children: products.map((product) => Expanded(child: InkWell(
      onTap: () => onTap(product),
      child: Padding(padding: const EdgeInsets.only(right: 10), child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(5), child: ApiImage(
          url: product.imageUrl, width: 58, height: 78)),
        const SizedBox(width: 7),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text('\$ ${product.price.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ])),
      ])),
    ))).toList()),
  );
}

class ApiCollectionCard extends StatelessWidget {
  final StoreBanner banner;
  final double aspectRatio;
  const ApiCollectionCard({super.key, required this.banner, required this.aspectRatio});
  @override
  Widget build(BuildContext context) => AspectRatio(aspectRatio: aspectRatio,
    child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Row(children: [
      Expanded(flex: 5, child: Container(color: const Color(0xFFF8F8F8),
        padding: const EdgeInsets.all(14),
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('|  ${banner.label}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 12),
          Text(banner.title, style: const TextStyle(fontSize: 18, color: Color(0xFF34343A))),
        ]))),
      Expanded(flex: 5, child: ApiImage(url: banner.imageUrl)),
    ])));
}

class ApiCategoryPromos extends StatelessWidget {
  final List<StoreBanner> banners;
  const ApiCategoryPromos({super.key, required this.banners});
  @override
  Widget build(BuildContext context) => Row(children: banners.map((b) =>
    Expanded(child: AspectRatio(aspectRatio: 158 / 194, child: Stack(fit: StackFit.expand,
      children: [
        ApiImage(url: b.imageUrl),
        Positioned(left: 3, right: 3, bottom: 0, child: Container(
          color: Colors.white.withValues(alpha: 0.85), padding: const EdgeInsets.all(7),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(b.label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 3),
            Text(b.title, style: const TextStyle(fontSize: 12)),
          ]),
        )),
      ],
    )))
  ).toList());
}

/// Aceleasi valori statistice ca in design, citite din /feed/details.
class ApiRatingBreakdown extends StatelessWidget {
  final Product product;
  const ApiRatingBreakdown({super.key, required this.product});
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Text(product.rating?.toStringAsFixed(1) ?? '-',
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const Text('OUT OF 5', style: TextStyle(fontSize: 8, color: Colors.grey)),
        const SizedBox(height: 4),
        Text('${product.reviewCount ?? 0} reviews',
          style: const TextStyle(fontSize: 9, color: Colors.grey)),
      ]),
      const SizedBox(width: 18),
      Expanded(child: Column(children: product.ratingBreakdown.map((item) =>
        Padding(padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            SizedBox(width: 18, child: Text('${item.stars}★', style: const TextStyle(fontSize: 10))),
            const SizedBox(width: 8),
            Expanded(child: LinearProgressIndicator(value: item.percentage / 100,
              minHeight: 5, backgroundColor: Colors.grey.shade200,
              color: const Color(0xFF4E8E82))),
            const SizedBox(width: 7),
            SizedBox(width: 25, child: Text('${item.percentage}%',
              style: const TextStyle(fontSize: 9))),
          ]),
        )).toList())),
    ],
  );
}

class ApiSimilarProducts extends StatelessWidget {
  final List<Product> products;
  const ApiSimilarProducts({super.key, required this.products});
  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const Text('No products provided by API.',
      style: TextStyle(color: Colors.grey, fontSize: 12));
    return SizedBox(height: 205, child: ListView.builder(
      scrollDirection: Axis.horizontal, itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        return SizedBox(width: 120, child: Padding(
          padding: const EdgeInsets.only(right: 12), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(borderRadius: BorderRadius.circular(6),
                child: ApiImage(url: p.imageUrl, height: 140, width: 110)),
              const SizedBox(height: 6),
              Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11)),
              Text('\$ ${p.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ));
      },
    ));
  }
}
