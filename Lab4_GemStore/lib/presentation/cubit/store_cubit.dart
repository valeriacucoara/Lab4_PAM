import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/store_feed.dart';
import '../../domain/repositories/store_repository.dart';
import 'store_state.dart';

enum PriceFilter { all, under40, between40And60, over60 }
enum SortOption { defaultOrder, priceLowToHigh, priceHighToLow, nameAZ }

/// Pastreaza cautarea, filtrarea, sortarea si favoritele din Lab3.
/// Schimba NUMAI sursa: repository-ul HTTP in locul fisierului JSON local.
class StoreCubit extends Cubit<StoreState> {
  final StoreRepository repository;
  StoreCubit(this.repository) : super(StoreLoading());

  StoreFeed? feed;
  List<Product> _allProducts = [];
  String _searchQuery = '';
  PriceFilter _priceFilter = PriceFilter.all;
  SortOption _sortOption = SortOption.defaultOrder;
  final Set<String> _favorites = {};

  String get searchQuery => _searchQuery;
  PriceFilter get priceFilter => _priceFilter;
  SortOption get sortOption => _sortOption;
  bool isFavorite(String id) => _favorites.contains(id);

  Future<void> loadProducts() async {
    emit(StoreLoading());
    try {
      final newFeed = await repository.fetchFeed();
      if (isClosed) return;
      feed = newFeed;
      _allProducts = [...newFeed.featureProducts, ...newFeed.recommended];
      _applyFilters();

      // Al doilea serviciu ofera date suplimentare doar pentru Sportwear Set.
      // Daca nu functioneaza, feed-ul deja incarcat ramane utilizabil.
      try {
        final details = await repository.fetchDetails();
        if (isClosed) return;
        final index = _allProducts.indexWhere((p) => p.id == details.id);
        if (index >= 0) _allProducts[index] = details;
        for (final similar in details.similarProducts) {
          if (!_allProducts.any((p) => p.id == similar.id)) {
            _allProducts.add(similar);
          }
        }
        if (details.initialFavorite == true) _favorites.add(details.id);
        _applyFilters();
      } catch (_) {
        // Un esec al endpointului detalii nu blocheaza prima pagina.
      }
    } catch (e) {
      if (!isClosed) emit(StoreError('Nu s-au putut incarca produsele: $e'));
    }
  }

  void searchProducts(String query) {
    _searchQuery = query;
    _applyFilters();
  }
  void filterByPrice(PriceFilter filter) {
    _priceFilter = filter;
    _applyFilters();
  }
  void sortProducts(SortOption option) {
    _sortOption = option;
    _applyFilters();
  }
  void toggleFavorite(String productId) {
    if (!_favorites.add(productId)) _favorites.remove(productId);
    _applyFilters();
  }

  void _applyFilters() {
    var result = List<Product>.from(_allProducts);
    if (_searchQuery.trim().isNotEmpty) {
      result = result.where((product) =>
        product.name.toLowerCase().contains(_searchQuery.toLowerCase().trim())).toList();
    }
    switch (_priceFilter) {
      case PriceFilter.all: break;
      case PriceFilter.under40:
        result = result.where((p) => p.price < 40).toList(); break;
      case PriceFilter.between40And60:
        result = result.where((p) => p.price >= 40 && p.price <= 60).toList(); break;
      case PriceFilter.over60:
        result = result.where((p) => p.price > 60).toList(); break;
    }
    switch (_sortOption) {
      case SortOption.defaultOrder: break;
      case SortOption.priceLowToHigh:
        result.sort((a, b) => a.price.compareTo(b.price)); break;
      case SortOption.priceHighToLow:
        result.sort((a, b) => b.price.compareTo(a.price)); break;
      case SortOption.nameAZ:
        result.sort((a, b) => a.name.compareTo(b.name)); break;
    }
    if (isClosed) return;
    if (result.isEmpty) {
      emit(StoreEmpty());
    } else {
      emit(StoreSuccess(products: result, favorites: Set<String>.of(_favorites)));
    }
  }
}
