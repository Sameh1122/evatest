import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';

class OrdersStatusPage extends StatefulWidget {
  final AppState state;

  const OrdersStatusPage({Key? key, required this.state}) : super(key: key);

  @override
  State<OrdersStatusPage> createState() => _OrdersStatusPageState();
}

class _OrdersStatusPageState extends State<OrdersStatusPage> {
  List<OrderModel> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() async {
    setState(() => isLoading = true);
    try {
      orders = await ApiService.fetchMyOrders();
    } catch (e) {
      print('Error loading orders: $e');
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
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cyanAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_shipping_outlined, color: AppColors.cyanAccent, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Orders Status & Live Tracking',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'Track live shipment status from warehouse dispatch to distributor delivery.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate400),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.emeraldAccent),
                onPressed: _loadOrders,
                tooltip: 'Refresh Orders Status',
              ),
            ],
          ),

          const SizedBox(height: 28),

          if (isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.emeraldAccent))
          else if (orders.isEmpty)
            Container(
              padding: const EdgeInsets.all(60),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.slate500),
                  const SizedBox(height: 16),
                  Text('No past orders placed yet.', style: GoogleFonts.inter(fontSize: 16, color: AppColors.slate300)),
                  const SizedBox(height: 8),
                  Text('Place your first supplement order to view live tracking status here.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate500)),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(order);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(24),
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
                      Text(
                        'Order #${order.orderNumber}',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      _statusBadge(order.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Placed on ${order.createdAt.split('T')[0]} • Payment: ${order.paymentMethod}',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.slate400),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${order.finalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.emeraldAccent),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: order.paymentStatus == 'Paid' ? AppColors.emeraldDark : AppColors.amberAccent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Payment: ${order.paymentStatus.toUpperCase()}',
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          _buildTrackingStepper(order.status),
          const Divider(color: AppColors.slate700, height: 28),

          Row(
            children: [
              Expanded(
                child: Text(
                  'Items: ${order.items.map((i) => "${i.productName} (x${i.quantity})").join(', ')}',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate300),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showReceiptModal(order),
                icon: const Icon(Icons.receipt_long, size: 16, color: AppColors.emeraldAccent),
                label: Text('View Digital Invoice', style: GoogleFonts.inter(color: Colors.white, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.slate700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStepper(String currentStatus) {
    final steps = ['Pending', 'Processing', 'Out for Delivery', 'Delivered'];
    final currentIndex = steps.indexOf(currentStatus);

    return Row(
      children: List.generate(steps.length, (index) {
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;

        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: isCompleted ? AppColors.emeraldAccent : AppColors.slate900,
                    child: Icon(
                      isCompleted ? Icons.check : Icons.circle,
                      size: 14,
                      color: isCompleted ? Colors.black : AppColors.slate500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    steps[index],
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      color: isCompleted ? AppColors.emeraldAccent : AppColors.slate500,
                    ),
                  ),
                ],
              ),
              if (index < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: index < currentIndex ? AppColors.emeraldAccent : AppColors.slate700,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _statusBadge(String status) {
    Color bg = Colors.blue.shade900;
    if (status == 'Processing') bg = Colors.purple.shade900;
    if (status == 'Out for Delivery') bg = AppColors.amberAccent;
    if (status == 'Delivered') bg = AppColors.emeraldDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  void _showReceiptModal(OrderModel order) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.slate900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 460,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Digital Invoice Receipt', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  IconButton(icon: const Icon(Icons.close, color: AppColors.slate500), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              Text('Order Number: #${order.orderNumber}', style: GoogleFonts.inter(color: AppColors.emeraldAccent, fontWeight: FontWeight.bold)),
              Text('Shipping Address: ${order.shippingAddress}', style: GoogleFonts.inter(color: AppColors.slate300, fontSize: 12)),
              const Divider(color: AppColors.slate700, height: 24),

              ListView.builder(
                shrinkWrap: true,
                itemCount: order.items.length,
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.productName} (x${item.quantity})', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                        Text('\$${item.subtotal.toStringAsFixed(2)}', style: GoogleFonts.inter(color: AppColors.emeraldAccent, fontSize: 13)),
                      ],
                    ),
                  );
                },
              ),

              const Divider(color: AppColors.slate700, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Discount Applied:', style: GoogleFonts.inter(color: AppColors.slate400)),
                  Text('-\$${order.discountAmount.toStringAsFixed(2)}', style: GoogleFonts.inter(color: AppColors.roseAccent)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Grand Total:', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('\$${order.finalAmount.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.emeraldAccent)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
