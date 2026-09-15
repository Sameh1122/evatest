import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';

class EditProductsPage extends StatefulWidget {
  final AppState state;

  const EditProductsPage({Key? key, required this.state}) : super(key: key);

  @override
  State<EditProductsPage> createState() => _EditProductsPageState();
}

class _EditProductsPageState extends State<EditProductsPage> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final products = state.products.where((p) => p.name.toLowerCase().contains(search.toLowerCase())).toList();

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Portal: Edit Product Catalog',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'Adjust stock quantities, update pricing, toggle visibility, or archive items.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate400),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => state.setAdminTab(0),
                icon: const Icon(Icons.add, color: Colors.black),
                label: Text('Add New Item', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldAccent),
              ),
            ],
          ),

          const SizedBox(height: 24),

          TextField(
            onChanged: (val) => setState(() => search = val),
            style: GoogleFonts.inter(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search catalog by supplement name or category...',
              hintStyle: GoogleFonts.inter(color: AppColors.slate400),
              prefixIcon: const Icon(Icons.search, color: AppColors.emeraldAccent),
              filled: true,
              fillColor: AppColors.slate800,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),

          const SizedBox(height: 24),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(AppColors.slate800),
              dataRowColor: MaterialStateProperty.all(AppColors.slate900),
              columns: [
                DataColumn(label: Text('ID', style: GoogleFonts.inter(color: AppColors.slate400, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Supplement Name', style: GoogleFonts.inter(color: AppColors.slate400, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Category', style: GoogleFonts.inter(color: AppColors.slate400, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Price (\$)', style: GoogleFonts.inter(color: AppColors.slate400, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Stock Qty', style: GoogleFonts.inter(color: AppColors.slate400, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Status', style: GoogleFonts.inter(color: AppColors.slate400, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Actions', style: GoogleFonts.inter(color: AppColors.slate400, fontWeight: FontWeight.bold))),
              ],
              rows: products.map((p) {
                final isLow = p.stockQuantity <= 15;
                return DataRow(
                  cells: [
                    DataCell(Text('#${p.id}', style: GoogleFonts.inter(color: Colors.white))),
                    DataCell(
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(p.imageUrl, width: 36, height: 36, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 10),
                          Text(p.name, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    DataCell(Text(p.category, style: GoogleFonts.inter(color: AppColors.slate300))),
                    DataCell(Text('\$${p.price.toStringAsFixed(2)}', style: GoogleFonts.inter(color: AppColors.emeraldAccent, fontWeight: FontWeight.bold))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isLow ? AppColors.amberAccent : AppColors.slate700,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${p.stockQuantity} ${isLow ? '(LOW)' : ''}',
                          style: GoogleFonts.inter(color: isLow ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                    DataCell(
                      Switch(
                        value: p.isActive,
                        activeColor: AppColors.emeraldAccent,
                        onChanged: (val) async {
                          await ApiService.editProduct(p.id, {'is_active': val ? 1 : 0});
                          await state.loadProducts();
                        },
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppColors.cyanAccent, size: 18),
                            onPressed: () => _openQuickEditModal(p),
                          ),
                          IconButton(
                            icon: const Icon(Icons.archive_outlined, color: AppColors.roseAccent, size: 18),
                            onPressed: () async {
                              await ApiService.deleteProduct(p.id);
                              await state.loadProducts();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _openQuickEditModal(ProductModel product) {
    final priceCtrl = TextEditingController(text: product.price.toString());
    final stockCtrl = TextEditingController(text: product.stockQuantity.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.slate800,
        title: Text('Edit ${product.name}', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Price (\$ USD)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: stockCtrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Stock Quantity'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.slate400))),
          ElevatedButton(
            onPressed: () async {
              await ApiService.editProduct(product.id, {
                'price': double.tryParse(priceCtrl.text) ?? product.price,
                'stock_quantity': int.tryParse(stockCtrl.text) ?? product.stockQuantity,
              });
              await widget.state.loadProducts();
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldAccent),
            child: Text('Save Changes', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
