import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../components/product_card.dart';

class FavoritesPage extends StatelessWidget {
  final AppState state;

  const FavoritesPage({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favProducts = state.products.where((p) => state.isFavorite(p.id)).toList();

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.roseAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.favorite_outlined, color: AppColors.roseAccent, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bookmarked Supplements',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'Quickly access your saved supplements for routine monthly reordering.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate400),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          if (favProducts.isEmpty)
            Container(
              padding: const EdgeInsets.all(60),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.favorite_border, size: 64, color: AppColors.slate500),
                  const SizedBox(height: 16),
                  Text(
                    'No favorite supplements saved yet.',
                    style: GoogleFonts.inter(fontSize: 16, color: AppColors.slate300),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click the heart icon on any product card in the Storefront to save it here.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate500),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                childAspectRatio: 0.72,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: favProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(product: favProducts[index], state: state);
              },
            ),
        ],
      ),
    );
  }
}
