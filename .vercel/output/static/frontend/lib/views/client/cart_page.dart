import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';

class CartPage extends StatefulWidget {
  final AppState state;

  const CartPage({Key? key, required this.state}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final promoCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

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
                  color: AppColors.emeraldAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shopping_cart_outlined, color: AppColors.emeraldAccent, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shopping Cart (${state.cartCount} Items)',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'Review your selected supplements before proceeding to secure checkout.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate400),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 28),

          if (state.cart.isEmpty)
            Container(
              padding: const EdgeInsets.all(60),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.remove_shopping_cart_outlined, size: 64, color: AppColors.slate500),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is currently empty.',
                    style: GoogleFonts.inter(fontSize: 16, color: AppColors.slate300),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => state.setClientTab(0),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldAccent),
                    child: Text('Explore Supplements', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.cart.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = state.cart[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.slate800,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.slate700),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                item.product.imageUrl,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 70,
                                  height: 70,
                                  color: AppColors.slate900,
                                  child: const Icon(Icons.medication, color: AppColors.emeraldAccent),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Category: ${item.product.category}',
                                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.slate400),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${item.product.price.toStringAsFixed(2)} each',
                                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.emeraldAccent, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.slate900,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.slate700),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 16, color: Colors.white),
                                    onPressed: () => state.updateCartQuantity(item.product.id, -1),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 16, color: Colors.white),
                                    onPressed: () => state.updateCartQuantity(item.product.id, 1),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 20),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${item.subtotal.toStringAsFixed(2)}',
                                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.roseAccent, size: 20),
                                  onPressed: () => state.removeFromCart(item.product.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 32),

                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.slate800,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.slate700),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Summary',
                          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Subtotal', style: GoogleFonts.inter(color: AppColors.slate400, fontSize: 14)),
                            Text('\$${state.cartSubtotal.toStringAsFixed(2)}', style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (state.appliedDiscount == null) ...[
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: promoCtrl,
                                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                                  decoration: InputDecoration(
                                    hintText: 'Promo Code (e.g. HEALTH10)',
                                    hintStyle: GoogleFonts.inter(color: AppColors.slate500, fontSize: 12),
                                    filled: true,
                                    fillColor: AppColors.slate900,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  if (promoCtrl.text.isNotEmpty) {
                                    final ok = await state.applyPromoCode(promoCtrl.text);
                                    if (!ok && context.mounted && state.errorMessage != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.roseAccent),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.emeraldAccent,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                ),
                                child: Text('Apply', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Available demo codes: HEALTH10 (10% off), VITA20 (20% off >\$50)', style: GoogleFonts.inter(fontSize: 10, color: AppColors.emeraldAccent)),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.emeraldAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.emeraldAccent.withOpacity(0.4)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Promo Code Applied: ${state.appliedDiscount!['code']}', style: GoogleFonts.inter(color: AppColors.emeraldAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                                    Text('-\$${state.cartDiscountAmount.toStringAsFixed(2)} Savings', style: GoogleFonts.inter(color: Colors.white, fontSize: 11)),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: AppColors.roseAccent, size: 18),
                                  onPressed: () => state.removePromoCode(),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const Divider(color: AppColors.slate700, height: 28),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Estimated Total', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('\$${state.cartTotal.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.emeraldAccent)),
                          ],
                        ),

                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: () => _openCheckoutModal(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emeraldAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('Proceed to Checkout', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _openCheckoutModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CheckoutDialog(state: widget.state),
    );
  }
}

class CheckoutDialog extends StatefulWidget {
  final AppState state;

  const CheckoutDialog({Key? key, required this.state}) : super(key: key);

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  final addressCtrl = TextEditingController(text: '742 Evergreen Terrace, Springfield, OR 97477');
  final phoneCtrl = TextEditingController(text: '+1 (555) 014-4412');
  String selectedPayment = 'Cash on Delivery';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.slate900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.emeraldAccent.withOpacity(0.3)),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Checkout & Delivery Address', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                IconButton(icon: const Icon(Icons.close, color: AppColors.slate500), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: addressCtrl,
              maxLines: 2,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Delivery Address',
                labelStyle: GoogleFonts.inter(color: AppColors.slate400),
                filled: true,
                fillColor: AppColors.slate800,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: phoneCtrl,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Contact Phone Number',
                labelStyle: GoogleFonts.inter(color: AppColors.slate400),
                filled: true,
                fillColor: AppColors.slate800,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),

            Text('Payment Method:', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),

            _paymentOption('Cash on Delivery', 'Pay upon receiving shipment', Icons.local_shipping_outlined),
            _paymentOption('Credit Card', 'Instant payment verification', Icons.credit_card),
            _paymentOption('E-Wallet', 'Digital wallet transfer', Icons.account_balance_wallet_outlined),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Final Total:', style: GoogleFonts.inter(color: AppColors.slate400)),
                Text('\$${widget.state.cartTotal.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.emeraldAccent)),
              ],
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: widget.state.isLoading ? null : _submitOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emeraldAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: widget.state.isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : Text('Confirm Order Now', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentOption(String title, String subtitle, IconData icon) {
    final isSelected = selectedPayment == title;
    return InkWell(
      onTap: () => setState(() => selectedPayment = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.slate800,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.emeraldAccent : AppColors.slate700),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.emeraldAccent : AppColors.slate400, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subtitle, style: GoogleFonts.inter(color: AppColors.slate400, fontSize: 11)),
              ],
            ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.emeraldAccent, size: 18),
          ],
        ),
      ),
    );
  }

  void _submitOrder() async {
    final res = await widget.state.completeCheckout(
      shippingAddress: addressCtrl.text,
      phone: phoneCtrl.text,
      paymentMethod: selectedPayment,
    );

    if (mounted) {
      Navigator.pop(context);
      widget.state.setClientTab(3);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.slate800,
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.emeraldAccent, size: 28),
              const SizedBox(width: 10),
              Text('Order Confirmed!', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Order #${res['order']['order_number']} has been placed successfully!\nTrack live delivery status in the Orders Status portal.',
            style: GoogleFonts.inter(color: AppColors.slate300),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldAccent),
              child: Text('View Order Status', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }
}
