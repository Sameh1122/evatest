import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';

class AdminOrdersPage extends StatefulWidget {
  final AppState state;

  const AdminOrdersPage({Key? key, required this.state}) : super(key: key);

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  List<OrderModel> orders = [];
  bool isLoading = true;
  String selectedStatus = 'All';
  String selectedPaymentStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() async {
    setState(() => isLoading = true);
    try {
      orders = await ApiService.fetchAdminOrders(
        status: selectedStatus != 'All' ? selectedStatus : null,
        paymentStatus: selectedPaymentStatus != 'All' ? selectedPaymentStatus : null,
      );
    } catch (e) {
      print('Error loading admin orders: $e');
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
                    'Admin Portal: Orders Management Module',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'Manage order lifecycle statuses and verify/toggle payment collections.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate400),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.emeraldAccent),
                onPressed: _loadOrders,
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Text('Filter Status: ', style: GoogleFonts.inter(color: AppColors.slate400, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              _dropdownFilter(['All', 'Pending', 'Processing', 'Out for Delivery', 'Delivered', 'Cancelled'], selectedStatus, (val) {
                if (val != null) {
                  setState(() => selectedStatus = val);
                  _loadOrders();
                }
              }),
              const SizedBox(width: 24),
              Text('Payment Filter: ', style: GoogleFonts.inter(color: AppColors.slate400, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              _dropdownFilter(['All', 'Paid', 'Pending'], selectedPaymentStatus, (val) {
                if (val != null) {
                  setState(() => selectedPaymentStatus = val);
                  _loadOrders();
                }
              }),
            ],
          ),

          const SizedBox(height: 24),

          if (isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.emeraldAccent))
          else if (orders.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              alignment: Alignment.center,
              child: Text('No orders match the selected filters.', style: GoogleFonts.inter(color: AppColors.slate400)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildAdminOrderRow(order);
              },
            ),
        ],
      ),
    );
  }

  Widget _dropdownFilter(List<String> items, String current, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.slate800,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.slate700),
      ),
      child: DropdownButton<String>(
        value: current,
        dropdownColor: AppColors.slate800,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
        underline: const SizedBox(),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildAdminOrderRow(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.slate800,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Order #${order.orderNumber}', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.emeraldAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                        child: Text(order.status, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.emeraldAccent)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Customer: ${order.customerName} (${order.customerPhone})', style: GoogleFonts.inter(fontSize: 12, color: AppColors.slate300)),
                  Text('Shipping Address: ${order.shippingAddress}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.slate400)),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$${order.finalAmount.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.emeraldAccent)),
                  const SizedBox(height: 6),

                  ElevatedButton.icon(
                    onPressed: () async {
                      final newStatus = order.paymentStatus == 'Paid' ? 'Pending' : 'Paid';
                      await ApiService.toggleOrderPayment(order.id, newStatus);
                      _loadOrders();
                    },
                    icon: Icon(
                      order.paymentStatus == 'Paid' ? Icons.check_circle : Icons.pending_outlined,
                      size: 14,
                      color: Colors.black,
                    ),
                    label: Text(
                      order.paymentStatus == 'Paid' ? 'Payment Verified (PAID)' : 'Payment Pending (TOGGLE)',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: order.paymentStatus == 'Paid' ? AppColors.emeraldAccent : AppColors.amberAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Divider(color: AppColors.slate700, height: 24),

          Row(
            children: [
              Text('Update Order Lifecycle Status: ', style: GoogleFonts.inter(fontSize: 12, color: AppColors.slate400)),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: order.status,
                dropdownColor: AppColors.slate900,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                items: const [
                  DropdownMenuItem(value: 'Pending', child: Text('Pending Dispatch')),
                  DropdownMenuItem(value: 'Processing', child: Text('Processing / Packing')),
                  DropdownMenuItem(value: 'Out for Delivery', child: Text('Out for Delivery')),
                  DropdownMenuItem(value: 'Delivered', child: Text('Delivered')),
                  DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                ],
                onChanged: (newStatus) async {
                  if (newStatus != null) {
                    await ApiService.updateOrderStatus(order.id, newStatus);
                    _loadOrders();
                  }
                },
              ),
              const Spacer(),
              Text(
                'Items: ${order.items.map((i) => "${i.productName} (x${i.quantity})").join(', ')}',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.slate400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
