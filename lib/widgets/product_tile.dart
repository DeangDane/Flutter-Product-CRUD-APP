// Replace everything in your product_tile.dart file with this:
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../screens/edit_product_page.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class ProductTile extends StatelessWidget {
  final Product product;

  const ProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    return Card(
        elevation: 2,
        color: Colors.white,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.grey, width: 0.2),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          product.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Price: \$${product.price}   |   Stock: ${product.stock}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.deepPurple),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => EditProductPage(product: product),
                ));
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Delete Product"),
                    content: const Text("Are you sure you want to delete this product?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
                    ],
                  ),
                );
                if (confirmed == true) {
                  provider.deleteProduct(product.id!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
