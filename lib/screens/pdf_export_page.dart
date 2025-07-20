import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../providers/product_provider.dart';

class PdfExportPage extends StatefulWidget {
  const PdfExportPage({super.key, required List products});

  @override
  State<PdfExportPage> createState() => _PdfExportPageState();
}

class _PdfExportPageState extends State<PdfExportPage> {
  final TextEditingController _fileNameController = TextEditingController(
    text: "products",
  );

  Future<void> _generatePdf(BuildContext context) async {
    final products =
        Provider.of<ProductProvider>(context, listen: false).products;
    final document = PdfDocument();
    final page = document.pages.add();

    // Title
    page.graphics.drawString(
      'Product List',
      PdfStandardFont(PdfFontFamily.helvetica, 20, style: PdfFontStyle.bold),
      bounds: const Rect.fromLTWH(0, 0, 500, 30),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );

    PdfGrid grid = PdfGrid();
    grid.columns.add(count: 3);

    // Header
    grid.headers.add(1);
    final header = grid.headers[0];
    header.cells[0].value = 'Name';
    header.cells[1].value = 'Price';
    header.cells[2].value = 'Stock';

    // Styling
    header.style = PdfGridRowStyle(
      backgroundBrush: PdfBrushes.gray,
      textBrush: PdfBrushes.white,
      font: PdfStandardFont(
        PdfFontFamily.helvetica,
        12,
        style: PdfFontStyle.bold,
      ),
    );
    grid.style = PdfGridStyle(
      font: PdfStandardFont(PdfFontFamily.helvetica, 12),
      cellPadding: PdfPaddings(left: 5, right: 5, top: 5, bottom: 5),
    );

    for (var product in products) {
      final row = grid.rows.add();
      row.cells[0].value = product.name;
      row.cells[1].value = product.price.toStringAsFixed(2);
      row.cells[2].value = product.stock.toString();
    }

    // Draw below title
    grid.draw(page: page, bounds: const Rect.fromLTWH(0, 40, 500, 800));
    final bytes = await document.save();
    document.dispose();

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${_fileNameController.text.trim()}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ PDF exported as "${_fileNameController.text}.pdf"'),
      ),
    );

    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Export PDF"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              elevation: 6,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Export Products to PDF',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _fileNameController,
                      decoration: InputDecoration(
                        labelText: 'File name',
                        hintText: 'e.g. products',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.edit),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.cancel),
                            label: const Text("Cancel"),
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text("Export"),
                            onPressed: () => _generatePdf(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
