import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  Timer? _debounce;

  List<Product> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  int get totalProducts => _filteredProducts.length;

  get searchProducts => null;

  Future<void> fetchProducts() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final products = await ApiService.getProducts();
      _products = products;
      _filteredProducts = products;
    } catch (e) {
      print("Error fetching products: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(Product product, double parse) async {
    await ApiService.addProduct(product);
    await fetchProducts();
  }

  Future<void> updateProduct(Product oldProduct, Product updated) async {
    await ApiService.updateProduct(oldProduct, updated);
    await fetchProducts();
  }

  Future<void> deleteProduct(int id) async {
    await ApiService.deleteProduct(id);
    await fetchProducts();
  }

  // Debounce search
  void search(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      notifyListeners();
    });
  }

  // Sort
  void sortBy(String field) {
    if (field == "price") {
      _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
    } else if (field == "stock") {
      _filteredProducts.sort((a, b) => a.stock.compareTo(b.stock));
    }
    notifyListeners();
  }

  void sortProducts(String value) {
    sortBy(value);
  }
}
