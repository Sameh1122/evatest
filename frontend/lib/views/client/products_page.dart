import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../components/product_card.dart';
import '../components/auth_modal.dart';

class ProductsPage extends StatelessWidget {
  final AppState state;

  const ProductsPage({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Daily Multivitamins', 'Heart & Joint Health', 'Immunity Shield', 'Immunity & Bone', 'Sleep & Muscle'];
    final isMobile = MediaQuery.of(context).size.width < 600 || state.viewportMode == DeviceViewport.mobileAndroid;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Banner for Limitless by Eva Pharma
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32, vertical: isMobile ? 20 : 40),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.evaNavy,
                  AppColors.evaBlueDark,
                  AppColors.evaNavy,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(bottom: BorderSide(color: AppColors.limitlessGold.withOpacity(0.3))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.limitlessGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.limitlessGold.withOpacity(0.5)),
                  ),
                  child: Text(
                    'LIMITLESS NATURALS BY EVA PHARMA',
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.limitlessGold, letterSpacing: 1.0),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Unlock Your Full Health Potential with Limitless',
                  style: GoogleFonts.outfit(
                    fontSize: isMobile ? 24 : 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pharmaceutical-grade dietary supplements formulated by Eva Pharma to power your vitality while safeguarding against medical contraindications.',
                  style: GoogleFonts.inter(fontSize: isMobile ? 12 : 14, color: AppColors.slate300, height: 1.4),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    if (state.currentUser == null) {
                      showDialog(context: context, builder: (_) => AuthModal(state: state));
                    } else {
                      state.setClientTab(4);
                    }
                  },
                  icon: const Icon(Icons.medical_services_outlined, color: Colors.black, size: 16),
                  label: Text(
                    state.clientProfile != null ? 'Update Health Profile' : 'Set Up Health Profile',
                    style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.limitlessGold,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar & Filter Section
          Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (val) => state.setSearchQuery(val),
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search multivitamin, collagen, omega-3...',
                    hintStyle: GoogleFonts.inter(color: AppColors.slate400, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: AppColors.limitlessGold),
                    filled: true,
                    fillColor: AppColors.slate800,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.slate700),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.limitlessGold),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Category Filter Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                      final isSelected = state.selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppColors.limitlessGold,
                          backgroundColor: AppColors.slate800,
                          labelStyle: GoogleFonts.inter(
                            color: isSelected ? Colors.black : AppColors.slate300,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          onSelected: (_) => state.setCategory(cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Limitless Catalog',
                      style: GoogleFonts.outfit(fontSize: isMobile ? 18 : 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      '${state.products.length} Items',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.slate400),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (state.products.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(30),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Icon(Icons.search_off, size: 48, color: AppColors.slate500),
                        const SizedBox(height: 12),
                        Text('No Limitless supplements match your search.', style: GoogleFonts.inter(color: AppColors.slate400, fontSize: 13)),
                      ],
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 2 : 4,
                      childAspectRatio: isMobile ? 0.62 : 0.72,
                      crossAxisSpacing: isMobile ? 10 : 20,
                      mainAxisSpacing: isMobile ? 10 : 20,
                    ),
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: state.products[index], state: state);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
