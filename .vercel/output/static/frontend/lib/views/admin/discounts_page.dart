import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import '../../models/discount_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';

class DiscountsPage extends StatefulWidget {
  final AppState state;

  const DiscountsPage({Key? key, required this.state}) : super(key: key);

  @override
  State<DiscountsPage> createState() => _DiscountsPageState();
}

class _DiscountsPageState extends State<DiscountsPage> {
  List<DiscountModel> discounts = [];
  bool isLoading = true;

  final codeCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final valueCtrl = TextEditingController();
  final minOrderCtrl = TextEditingController();
  String discountType = 'percentage';

  @override
  void initState() {
    super.initState();
    _loadDiscounts();
  }

  void _loadDiscounts() async {
    setState(() => isLoading = true);
    try {
      discounts = await ApiService.fetchDiscounts();
    } catch (e) {
      print('Error loading discounts: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    'Admin Portal: Discount & Promotion Module',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'Create and manage promotional discount coupons for wellness campaigns.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate400),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _openAddDiscountModal,
                icon: const Icon(Icons.confirmation_number_outlined, color: Colors.black),
                label: Text('Create Coupon Code', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldAccent),
              ),
            ],
          ),

          const SizedBox(height: 28),

          if (isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.emeraldAccent))
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 360,
                childAspectRatio: 1.4,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: discounts.length,
              itemBuilder: (context, index) {
                final d = discounts[index];
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.slate800,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.emeraldAccent.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.emeraldAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              d.code,
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.emeraldAccent),
                            ),
                          ),
                          Switch(
                            value: d.isActive,
                            activeColor: AppColors.emeraldAccent,
                            onChanged: (val) async {
                              await ApiService.createDiscount({
                                'code': d.code,
                                'is_active': val ? 1 : 0,
                              });
                              _loadDiscounts();
                            },
                          ),
                        ],
                      ),
                      Text(d.description, style: GoogleFonts.inter(fontSize: 12, color: AppColors.slate300)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            d.discountType == 'percentage' ? '${d.discountValue}% OFF' : '\$${d.discountValue} OFF',
                            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text('Min Spend: \$${d.minOrderAmount}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.slate400)),
                        ],
                      ),
                      Text('Redeemed: ${d.timesUsed} times', style: GoogleFonts.inter(fontSize: 11, color: AppColors.slate400)),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _openAddDiscountModal() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          backgroundColor: AppColors.slate900,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create Promo Discount', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                TextField(
                  controller: codeCtrl,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Coupon Code (e.g. VITA30)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: discountType,
                        dropdownColor: AppColors.slate800,
                        style: GoogleFonts.inter(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: const [
                          DropdownMenuItem(value: 'percentage', child: Text('Percentage %')),
                          DropdownMenuItem(value: 'fixed', child: Text('Fixed Amount \$')),
                        ],
                        onChanged: (val) {
                          if (val != null) setModalState(() => discountType = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: valueCtrl,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.inter(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Discount Value'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: minOrderCtrl,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Minimum Order Spend (\$)'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await ApiService.createDiscount({
                      'code': codeCtrl.text,
                      'description': descCtrl.text,
                      'discount_type': discountType,
                      'discount_value': double.tryParse(valueCtrl.text) ?? 10.0,
                      'min_order_amount': double.tryParse(minOrderCtrl.text) ?? 0.0,
                    });
                    _loadDiscounts();
                    if (mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldAccent, minimumSize: const Size.fromHeight(48)),
                  child: Text('Create Coupon', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
