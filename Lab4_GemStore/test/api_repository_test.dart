import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab4_gemstore/data/datasources/store_api_service.dart';
import 'package:lab4_gemstore/data/repositories/store_repository_impl.dart';
import 'package:lab4_gemstore/presentation/cubit/store_cubit.dart';
import 'package:lab4_gemstore/presentation/cubit/store_state.dart';

const feedJson = '''
{
 "storeName": "GemStore",
 "categories": [
   {"id":"women","name":"Women","selected":true,"iconUrl":"https://api.iconify.design/mdi/a.svg"},
   {"id":"men","name":"Men","selected":false,"iconUrl":"https://api.iconify.design/mdi/b.svg"}
 ],
 "heroBanner":{"id":"autumn","title":"Autumn Collection 2021","imageUrl":"https://example.com/hero.jpg"},
 "featureProducts":[
   {"id":"p001","name":"Turtleneck Sweater","price":39.99,"currency":"USD","imageUrl":"https://example.com/p1.jpg"},
   {"id":"p002","name":"Long Sleeve Dress","price":45,"currency":"USD","imageUrl":"https://example.com/p2.jpg"},
   {"id":"p003","name":"Sportwear Set","price":80,"currency":"USD","imageUrl":"https://example.com/p3.jpg"}
 ],
 "newCollection":{"label":"NEW COLLECTION","title":"HANG OUT & PARTY","imageUrl":"https://example.com/new.jpg"},
 "recommended":[{"id":"p004","name":"White fashion hoodie","price":29,"currency":"USD","imageUrl":"https://example.com/p4.jpg"}],
 "topCollections":[{"id":"c001","label":"Sale up to 40%","title":"FOR SLIM & BEAUTY","imageUrl":"https://example.com/top.jpg"}],
 "categoryPromos":[{"id":"cp001","category":"T-Shirts","title":"The Office Life","imageUrl":"https://example.com/cat.jpg"}]
}
''';

const detailsJson = '''
{
 "product": {
   "id":"p003", "name":"Sportwear Set", "price":80, "currency":"USD",
   "mainImageUrl":"https://example.com/p3-large.jpg",
   "rating":4.9, "ratingCount":83, "reviewCount":47,
   "description":"Sportswear is fashion today.",
   "galleryImageUrls":["https://example.com/a.jpg","https://example.com/b.jpg"],
   "availableColors":[{"id":"beige","name":"Beige","value":"#E9C5AC"}],
   "availableSizes":["S","M","L"], "selectedColor":"beige", "selectedSize":"L",
   "sizeAvailability":{"S":false,"M":false,"L":true},
   "ratingBreakdown":[{"stars":5,"percentage":80}],
   "reviews":[{"id":"r001","author":"Jennifer Rose","avatarUrl":"https://example.com/avatar.jpg","rating":5,"createdAtLabel":"5m ago","text":"Excellent!"}],
   "similarProducts":[{"id":"p006","name":"Rise Crop Hoodie","price":43,"currency":"USD","imageUrl":"https://example.com/p6.jpg"}],
   "actions":{"isFavorite":true,"canAddToCart":true,"addToCartLabel":"Add To Cart"}
 }
}
''';

void main() {
  test('GET /feed si /feed/details se fac pe HTTP, datele sunt mapate corect', () async {
    final urls = <String>[];
    final client = MockClient((request) async {
      urls.add(request.url.path);
      if (request.url.path.endsWith('/feed/details')) {
        return http.Response(detailsJson, 200, headers: {'content-type':'application/json'});
      }
      return http.Response(feedJson, 200, headers: {'content-type':'application/json'});
    });
    final repo = StoreRepositoryImpl(StoreApiService(client));
    final feed = await repo.fetchFeed();
    final product = await repo.fetchDetails();
    expect(urls, ['/lab2026/v1/feed', '/lab2026/v1/feed/details']);
    expect(feed.storeName, 'GemStore');
    expect(feed.categories.length, 2);
    expect(feed.featureProducts.length, 3);
    expect(feed.heroBanner.title, 'Autumn Collection 2021');
    expect(feed.recommended.first.price, 29);
    expect(feed.topCollections.first.label, 'Sale up to 40%');
    expect(product.id, 'p003');
    expect(product.rating, 4.9);
    expect(product.reviews.single.author, 'Jennifer Rose');
    expect(product.availableColors.single.name, 'Beige');
    expect(product.sizeAvailability['L'], isTrue);
    expect(product.similarProducts.single.id, 'p006');
    expect(product.initialFavorite, isTrue);
    repo.dispose();
  });

  test('Cubit pastreaza cautarea / filtrele / sortarea Lab3', () async {
    final client = MockClient((request) async => http.Response(
      request.url.path.endsWith('/details') ? detailsJson : feedJson, 200));
    final repo = StoreRepositoryImpl(StoreApiService(client));
    final cubit = StoreCubit(repo);
    await cubit.loadProducts();
    expect(cubit.state, isA<StoreSuccess>());
    expect((cubit.state as StoreSuccess).products.length, 5);
    cubit.searchProducts('dress');
    expect((cubit.state as StoreSuccess).products.single.id, 'p002');
    cubit.searchProducts('');
    cubit.filterByPrice(PriceFilter.under40);
    expect((cubit.state as StoreSuccess).products.every((p) => p.price < 40), isTrue);
    cubit.filterByPrice(PriceFilter.all);
    cubit.sortProducts(SortOption.priceHighToLow);
    expect((cubit.state as StoreSuccess).products.first.id, 'p003');
    cubit.toggleFavorite('p002');
    expect(cubit.isFavorite('p002'), isTrue);
    await cubit.close();
    repo.dispose();
  });

  test('Raspunsurile HTTP 503 sunt raportate, nu inlocuite cu date locale', () async {
    final repo = StoreRepositoryImpl(StoreApiService(
      MockClient((request) async => http.Response('Service Unavailable', 503))));
    await expectLater(repo.fetchFeed(), throwsA(isA<StoreApiException>()));
    repo.dispose();
  });

  test('JSON invalid este raportat corect', () async {
    final repo = StoreRepositoryImpl(StoreApiService(
      MockClient((request) async => http.Response('not json', 200))));
    await expectLater(repo.fetchFeed(), throwsA(isA<StoreApiException>()));
    repo.dispose();
  });
}
