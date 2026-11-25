import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/store_repository.dart';

abstract class ProductDetailState {
  final Product product;
  const ProductDetailState(this.product);
}
class ProductDetailLoading extends ProductDetailState {
  const ProductDetailLoading(super.product);
}
class ProductDetailReady extends ProductDetailState {
  const ProductDetailReady(super.product);
}
class ProductDetailUnavailable extends ProductDetailState {
  const ProductDetailUnavailable(super.product);
}
class ProductDetailFailure extends ProductDetailState {
  final String message;
  const ProductDetailFailure(super.product, this.message);
}

class ProductDetailCubit extends Cubit<ProductDetailState> {
  final StoreRepository repository;
  final Product initialProduct;
  ProductDetailCubit(this.repository, this.initialProduct)
      : super(ProductDetailLoading(initialProduct));

  Future<void> load() async {
    emit(ProductDetailLoading(initialProduct));
    // Contractul API este fix: /feed/details intoarce DOAR p003.
    // Pentru alte produse nu afisam detaliile lui p003 ca si cum le-ar apartine.
    if (initialProduct.id != 'p003') {
      emit(ProductDetailUnavailable(initialProduct));
      return;
    }
    try {
      final detail = await repository.fetchDetails();
      if (isClosed) return;
      if (detail.id == initialProduct.id) {
        emit(ProductDetailReady(detail));
      } else {
        emit(ProductDetailUnavailable(initialProduct));
      }
    } catch (e) {
      if (!isClosed) emit(ProductDetailFailure(initialProduct, e.toString()));
    }
  }
}
