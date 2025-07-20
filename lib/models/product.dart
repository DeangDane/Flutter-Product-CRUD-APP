class Product {
  final int? id;
  final String name;
  final double price;
  final int stock;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['PRODUCTID'],
      name: json['PRODUCTNAME'],
      price: (json['PRICE'] as num).toDouble(),
      stock: json['STOCK'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'PRODUCTNAME': name, 'PRICE': price, 'STOCK': stock};
  }
}
