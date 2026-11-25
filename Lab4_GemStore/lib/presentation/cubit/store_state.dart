import '../../domain/entities/product.dart';

abstract class StoreState {}
class StoreLoading extends StoreState {}
class StoreSuccess extends StoreState {
  final List<Product> products;
  final Set<String> favorites;
  StoreSuccess({required this.products, required this.favorites});
}
class StoreEmpty extends StoreState {}
class StoreError extends StoreState {
  final String message;
  StoreError(this.message);
}
