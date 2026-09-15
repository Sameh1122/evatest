import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';

class DeliveryManagementPage extends StatefulWidget {
  final AppState state;

  const DeliveryManagementPage({Key? key, required this.state}) : super(key: key);

  @override
  State<DeliveryManagementPage> createState() => _DeliveryManagementPageState();
}

class _DeliveryManagementPageState extends State<DeliveryManagementPage> {
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
      print('Error loading deliveries: $e');
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
                    'Distributor Portal: Delivery Management Queue',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'Manage assigned shipments and advance live delivery milestones.',
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
              padding: const EdgeInsets.all(60),
              alignment: Alignment.center,
              child: Text('No shipments currently assigned to your distributor account.', style: GoogleFonts.inter(color: AppColors.slate400)),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('Order #${d['order_number']}', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: AppColors.emeraldAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                                child: Text(d['status'], style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.emeraldAccent)),
                              ),
                            ],
                          ),
                          Text('\$${d['final_amount']}', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.emeraldAccent)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Customer: ${d['customer_name']} (${d['customer_phone']})', style: GoogleFonts.inter(color: AppColors.slate300, fontSize: 13)),
                      Text('Delivery Destination: ${d['delivery_address']}', style: GoogleFonts.inter(color: AppColors.slate400, fontSize: 12)),
                      if (d['notes'] != null && d['notes'].toString().isNotEmpty)
                        Text('Note: ${d['notes']}', style: GoogleFonts.inter(color: AppColors.amberAccent, fontSize: 11)),

                      const Divider(color: AppColors.slate700, height: 24),

                      Row(
                        children: [
                          Text('Advance Delivery State:', style: GoogleFonts.inter(fontSize: 12, color: AppColors.slate400)),
                          const SizedBox(width: 12),
                          _actionBtn(d['id'], 'Assigned', Colors.blue),
                          const SizedBox(width: 8),
                          _actionBtn(d['id'], 'Processing', Colors.purple),
                          const SizedBox(width: 8),
                          _actionBtn(d['id'], 'Out for Delivery', Colors.amber),
                          const SizedBox(width: 8),
                          _actionBtn(d['id'], 'Delivered', Colors.teal),
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

  Widget _actionBtn(int deliveryId, String status, MaterialColor color) {
    return ElevatedButton(
      onPressed: () async {
        await ApiService.updateDeliveryStatus(deliveryId, status, 'Updated by distributor');
        _loadDeliveries();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      child: Text(status, style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
