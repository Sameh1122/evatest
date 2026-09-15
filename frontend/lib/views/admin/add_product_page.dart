import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';

class AddProductPage extends StatefulWidget {
  final AppState state;

  const AddProductPage({Key? key, required this.state}) : super(key: key);

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final stockCtrl = TextEditingController();
  final dosageCtrl = TextEditingController();
  final imageCtrl = TextEditingController();
  final tagsCtrl = TextEditingController();
  final contraCtrl = TextEditingController();
  final ingredientsCtrl = TextEditingController();

  String selectedCategory = 'Heart & Joint Health';
  bool isFeatured = false;

  final categories = [
    'Heart & Joint Health',
    'Immunity & Bone',
    'Sleep & Muscle',
    'Heart & Cellular Energy',
    'Sports Nutrition',
    'Stress & Energy',
    'Digestive Health'
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.emeraldAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_business_outlined, color: AppColors.emeraldAccent, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Portal: Add New Supplement',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'Formulate and introduce new health & dietary products to the store catalog.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate400),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.slate800,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate700),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _field('Product Name', nameCtrl, Icons.medication_outlined)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        dropdownColor: AppColors.slate900,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Supplement Category',
                          labelStyle: GoogleFonts.inter(color: AppColors.slate400),
                          filled: true,
                          fillColor: AppColors.slate900,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedCategory = val);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _field('Price (\$ USD)', priceCtrl, Icons.attach_money, isNum: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _field('Initial Stock Quantity', stockCtrl, Icons.inventory_2_outlined, isNum: true)),
                  ],
                ),

                const SizedBox(height: 16),
                _field('Image URL', imageCtrl, Icons.image_outlined),

                const SizedBox(height: 16),
                _field('Product Description', descCtrl, Icons.description_outlined, maxLines: 3),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _field('Active Ingredients (e.g. EPA 800mg, DHA 400mg)', ingredientsCtrl, Icons.science_outlined)),
                    const SizedBox(width: 16),
                    Expanded(child: _field('Dosage Instructions (e.g. 2 softgels daily)', dosageCtrl, Icons.access_time)),
                  ],
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _field('Health Tags (e.g. Heart Health, Joint Mobility)', tagsCtrl, Icons.tag)),
                    const SizedBox(width: 16),
                    Expanded(child: _field('Medical Contraindications / Warnings', contraCtrl, Icons.warning_amber_rounded)),
                  ],
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: isFeatured,
                      activeColor: AppColors.emeraldAccent,
                      checkColor: Colors.black,
                      onChanged: (val) => setState(() => isFeatured = val ?? false),
                    ),
                    Text('Highlight as Featured Supplement on Storefront', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                  ],
                ),

                const SizedBox(height: 24),

                ElevatedButton.icon(
                  onPressed: _submitProduct,
                  icon: const Icon(Icons.check_circle, color: Colors.black),
                  label: Text('Publish Product to Catalog', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emeraldAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, IconData icon, {bool isNum = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppColors.slate400),
        prefixIcon: Icon(icon, color: AppColors.slate400, size: 18),
        filled: true,
        fillColor: AppColors.slate900,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.slate700)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.emeraldAccent)),
      ),
    );
  }

  void _submitProduct() async {
    try {
      await ApiService.addProduct({
        'name': nameCtrl.text,
        'description': descCtrl.text,
        'category': selectedCategory,
        'price': double.tryParse(priceCtrl.text) ?? 29.99,
        'stock_quantity': int.tryParse(stockCtrl.text) ?? 50,
        'dosage_instructions': dosageCtrl.text,
        'image_url': imageCtrl.text.isNotEmpty
            ? imageCtrl.text
            : 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=600&auto=format&fit=crop&q=80',
        'health_tags': tagsCtrl.text,
        'contraindications': contraCtrl.text,
        'active_ingredients': ingredientsCtrl.text,
        'is_featured': isFeatured,
      });

      await widget.state.loadProducts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New supplement successfully added to catalog!'), backgroundColor: AppColors.emeraldAccent),
        );
        widget.state.setAdminTab(1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.roseAccent),
        );
      }
    }
  }
}
