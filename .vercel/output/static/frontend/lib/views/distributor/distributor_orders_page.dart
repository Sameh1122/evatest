import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';

class DistributorOrdersPage extends StatefulWidget {
  final AppState state;

  const DistributorOrdersPage({Key? key, required this.state}) : super(key: key);

  @override
  State<DistributorOrdersPage> createState() => _DistributorOrdersPageState();
}

class _DistributorOrdersPageState extends State<DistributorOrdersPage> {
  List<dynamic> deliveries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  void _loadDeliveries() async {
    setState(() => isLoading = true);
    try {
      deliveries = await ApiService.fetchDistributorDeliveries();
    } catch (e) {
      print('Error loading distributor orders: $e');
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
                    'Distributor Portal: Orders Logistics Module',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'Order route detail, customer contact details, and payment collection status.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate400),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.emeraldAccent),
                onPressed: _loadDeliveries,
              ),
            ],
          ),

          const SizedBox(height: 28),

          if (isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.emeraldAccent))
          else if (deliveries.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              alignment: Alignment.center,
              child: Text('No order deliveries assigned.', style: GoogleFonts.inter(color: AppColors.slate400)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: deliveries.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final d = deliveries[index];
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.slate800,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.slate700),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order #${d['order_number']}', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('Customer: ${d['customer_name']} • ${d['customer_phone']}', style: GoogleFonts.inter(color: AppColors.slate300, fontSize: 13)),
                          Text('Address: ${d['delivery_address']}', style: GoogleFonts.inter(color: AppColors.slate400, fontSize: 12)),
                          const SizedBox(height: 6),
                          Text('Payment Method: ${d['payment_method']} (${d['payment_status']})', style: GoogleFonts.inter(color: AppColors.emeraldAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${d['final_amount']}', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.emeraldAccent)),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              _showAddNoteDialog(d['id']);
                            },
                            icon: const Icon(Icons.note_add_outlined, size: 14, color: Colors.black),
                            label: Text('Log Delivery Note', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldAccent),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(int deliveryId) {
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.slate800,
        title: Text('Log Delivery Note', style: GoogleFonts.outfit(color: Colors.white)),
        content: TextField(
          controller: noteCtrl,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: const InputDecoration(labelText: 'Delivery notes (e.g. Left at doorstep)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.slate400))),
          ElevatedButton(
            onPressed: () async {
              await ApiService.updateDeliveryStatus(deliveryId, 'Out for Delivery', noteCtrl.text);
              _loadDeliveries();
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldAccent),
            child: Text('Save Note', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
