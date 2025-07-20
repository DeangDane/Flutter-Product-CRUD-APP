// Replace everything in your existing product_list_page.dart file with this:
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'add_product_page.dart';
import 'pdf_export_page.dart';
import 'csv_export_page.dart';
import '../widgets/product_tile.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _sortField;

  @override
  void initState() {
    super.initState();
    Provider.of<ProductProvider>(context, listen: false).fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Products', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              Provider.of<ProductProvider>(context, listen: false).fetchProducts();
            },
          )
        ],
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: provider.search,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Action Row: PDF, CSV, Sort Dropdown
            Row(
              children: [
                // Export PDF
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.deepPurple),
                    label: const Text("Export PDF", style: TextStyle(color: Colors.deepPurple)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PdfExportPage(products: [])),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      minimumSize: const Size(10, 40), // Fixed height
                    ),
                  ),
                ),

                // Export CSV
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.file_copy, color: Colors.deepPurple),
                    label: const Text("Export CSV", style: TextStyle(color: Colors.deepPurple)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CsvExportPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      minimumSize: const Size(10, 40),
                    ),
                  ),
                ),

                // Sort Dropdown (same height and white dropdown color)
                Container(
                  height: 40, // Match button height
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortField,
                      hint: Row(
                        children: const [
                          Icon(Icons.sort, color: Colors.deepPurple),
                          SizedBox(width: 8),
                          Text("Sort", style: TextStyle(color: Colors.deepPurple)),
                        ],
                      ),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Colors.black),
                      items: const [
                        DropdownMenuItem(value: 'price', child: Text('Price')),
                        DropdownMenuItem(value: 'stock', child: Text('Stock')),
                      ],
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            _sortField = value;
                          });
                          provider.sortProducts(value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Product List
            Expanded(
              child:
                  provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.products.isEmpty
                      ? const Center(child: Text("No products found"))
                      : ListView.builder(
                        itemCount: provider.products.length,
                        itemBuilder: (context, index) {
                          final product = provider.products[index];
                          return ProductTile(product: product);
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
