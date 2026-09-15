import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product_model.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import 'product_detail_modal.dart';
import 'auth_modal.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final AppState state;

  const ProductCard({
    Key? key,
    required this.product,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isFav = state.isFavorite(product.id);
    final isLowStock = product.stockQuantity <= 15 && product.stockQuantity > 0;
    final isOutOfStock = product.stockQuantity <= 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.slate800,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate700),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => ProductDetailModal(product: product, state: state),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Stack
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 1.3,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.slate900,
                        child: const Icon(Icons.medication_outlined, size: 48, color: AppColors.emeraldAccent),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.emeraldAccent.withOpacity(0.4)),
                    ),
                    child: Text(
                      product.category,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.emeraldAccent,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.6),
                    radius: 16,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? AppColors.roseAccent : Colors.white,
                        size: 18,
                      ),
                      onPressed: () {
                        if (state.currentRole == RoleMode.visitor || state.currentUser == null) {
                          showDialog(context: context, builder: (_) => AuthModal(state: state));
                        } else {
                          state.toggleFavorite(product.id);
                        }
                      },
                    ),
                  ),
                ),
                if (isOutOfStock || isLowStock)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isOutOfStock ? AppColors.roseAccent : AppColors.amberAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isOutOfStock ? 'OUT OF STOCK' : 'ONLY ${product.stockQuantity} LEFT',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          product.dosageInstructions,
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.slate400),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        if (product.contraindications.isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 13, color: AppColors.amberAccent),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Caution: ${product.contraindications}',
                                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.amberAccent),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.emeraldAccent,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: isOutOfStock
                              ? null
                              : () {
                                  if (state.currentRole == RoleMode.visitor || state.currentUser == null) {
                                    showDialog(context: context, builder: (_) => AuthModal(state: state));
                                  } else {
                                    state.addToCart(product);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${product.name} added to cart!'),
                                        backgroundColor: AppColors.emeraldAccent,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                          icon: const Icon(Icons.add_shopping_cart, size: 14, color: Colors.black),
                          label: Text(
                            'Add',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emeraldAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
