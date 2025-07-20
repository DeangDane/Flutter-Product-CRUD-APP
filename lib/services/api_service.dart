import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:3000/products';

  // ✅ Get all products without pagination
  static Future<List<Product>> getProducts({
    String search = '',
    String sort = '',
    String order = '',
  }) async {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        if (search.isNotEmpty) 'search': search,
        if (sort.isNotEmpty) 'sort': sort,
        if (order.isNotEmpty) 'order': order,
      },
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List productsJson = body['products'];
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<Product> getProductById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load product');
    }
  }

  static Future<Product> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'PRODUCTNAME': product.name,
        'PRICE': product.price,
        'STOCK': product.stock,
      }),
    );
    print('Add product response: ${response.statusCode} ${response.body}');
    if (response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add product: ${response.body}');
    }
  }

  static Future<void> updateProduct(
    Product oldProduct,
    Product newProduct,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl?id=${oldProduct.id}'), // using ?id= convention
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'PRODUCTNAME': newProduct.name,
        'PRICE': newProduct.price,
        'STOCK': newProduct.stock,
      }),
    );
    print('Update product response: ${response.statusCode} ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to update product: ${response.body}');
    }
  }

  static Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl?id=$id'));
    print('Delete product response: ${response.statusCode} ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product: ${response.body}');
    }
  }
}
