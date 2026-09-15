import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product_model.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import 'auth_modal.dart';

class ProductDetailModal extends StatelessWidget {
  final ProductModel product;
  final AppState state;

  const ProductDetailModal({
    Key? key,
    required this.product,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isFav = state.isFavorite(product.id);

    return Dialog(
      backgroundColor: AppColors.slate900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.emeraldAccent.withOpacity(0.3)),
      ),
      child: Container(
        width: 650,
        constraints: const BoxConstraints(maxHeight: 750),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: AspectRatio(
                      aspectRatio: 2.2,
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.slate900,
                          child: const Icon(Icons.medication_outlined, size: 64, color: AppColors.emeraldAccent),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.8)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.7),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldAccent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.category,
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.emeraldAccent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.description,
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.slate300, height: 1.5),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.slate800,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slate700),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _detailRow(Icons.science_outlined, 'Active Ingredients', product.activeIngredients),
                          const Divider(color: AppColors.slate700, height: 20),
                          _detailRow(Icons.access_time_filled, 'Dosage Instructions', product.dosageInstructions),
                          const Divider(color: AppColors.slate700, height: 20),
                          _detailRow(Icons.tag, 'Target Health Tags', product.healthTags),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (product.contraindications.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.amberAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.amberAccent.withOpacity(0.5)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.shield_outlined, color: AppColors.amberAccent, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MEDICAL CONTRAINDICATIONS & SAFETY WARNING',
                                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.amberAccent),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.contraindications,
                                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate300),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            if (state.currentRole == RoleMode.visitor || state.currentUser == null) {
                              showDialog(context: context, builder: (_) => AuthModal(state: state));
                            } else {
                              state.toggleFavorite(product.id);
                            }
                          },
                          icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? AppColors.roseAccent : Colors.white),
                          label: Text(isFav ? 'Saved' : 'Favorite', style: GoogleFonts.inter(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.slate700),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: product.stockQuantity <= 0
                                ? null
                                : () {
                                    if (state.currentRole == RoleMode.visitor || state.currentUser == null) {
                                      Navigator.pop(context);
                                      showDialog(context: context, builder: (_) => AuthModal(state: state));
                                    } else {
                                      state.addToCart(product);
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${product.name} added to your cart!'),
                                          backgroundColor: AppColors.emeraldAccent,
                                        ),
                                      );
                                    }
                                  },
                            icon: const Icon(Icons.add_shopping_cart, color: Colors.black),
                            label: Text(
                              product.stockQuantity <= 0 ? 'Out of Stock' : 'Add to Cart',
                              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emeraldAccent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.emeraldAccent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.slate400)),
              const SizedBox(height: 2),
              Text(value.isNotEmpty ? value : 'Standard formulation', style: GoogleFonts.inter(fontSize: 13, color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }
}
