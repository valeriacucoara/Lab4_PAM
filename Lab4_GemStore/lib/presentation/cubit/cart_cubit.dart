import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';

class CartItem {
  final Product product;
  final int quantity;
  const CartItem(this.product, this.quantity);
}

class CartState {
  final Map<String, CartItem> items;
  const CartState(this.items);
  int get count => items.values.fold(0, (sum, item) => sum + item.quantity);
  double get total => items.values.fold(0.0, (sum, item) => sum + item.product.price * item.quantity);
}

/// Cos demo local, fara pretentia unui endpoint POST care nu exista in API.
class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState({}));
  void add(Product product) {
    final items = Map<String, CartItem>.from(state.items);
    final old = items[product.id];
    items[product.id] = CartItem(product, (old?.quantity ?? 0) + 1);
    emit(CartState(items));
  }
  void decrease(String id) {
    final items = Map<String, CartItem>.from(state.items);
    final old = items[id];
    if (old == null) return;
    if (old.quantity <= 1) { items.remove(id); }
    else { items[id] = CartItem(old.product, old.quantity - 1); }
    emit(CartState(items));
  }
  void remove(String id) {
    final items = Map<String, CartItem>.from(state.items)..remove(id);
    emit(CartState(items));
  }
}
