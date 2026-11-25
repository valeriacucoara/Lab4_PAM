import '../../domain/entities/product.dart';
import '../../domain/entities/store_feed.dart';
import '../../domain/repositories/store_repository.dart';
import '../datasources/store_api_service.dart';
import '../models/store_dto.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreApiService api;
  StoreRepositoryImpl(this.api);

  @override
  Future<StoreFeed> fetchFeed() async => StoreFeedDto.fromJson(await api.getFeed());

  @override
  Future<Product> fetchDetails() async {
    final json = await api.getDetails();
    final value = json['product'];
    if (value is! Map<String, dynamic>) {
      throw const StoreApiException('JSON-ul de detalii nu contine un produs.');
    }
    return ProductDto.fromJson(value);
  }

  @override
  void dispose() => api.client.close();
}
