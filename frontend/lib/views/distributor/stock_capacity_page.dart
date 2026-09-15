import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';

class StockCapacityPage extends StatefulWidget {
  final AppState state;

  const StockCapacityPage({Key? key, required this.state}) : super(key: key);

  @override
  State<StockCapacityPage> createState() => _StockCapacityPageState();
}

class _StockCapacityPageState extends State<StockCapacityPage> {
  Map<String, dynamic>? stockData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStockCapacity();
  }

  void _loadStockCapacity() async {
    setState(() => isLoading = true);
    try {
      stockData = await ApiService.fetchStockCapacity();
    } catch (e) {
      print('Error loading stock capacity: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || stockData == null) {
      return const Padding(
        padding: EdgeInsets.all(60),
        child: Center(child: CircularProgressIndicator(color: AppColors.emeraldAccent)),
      );
    }

    final summary = stockData!['summary'] ?? {};
    final inventory = List<Map<String, dynamic>>.from(stockData!['inventory'] ?? []);

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
                    'Distributor Portal: Stock Capacity & Warehouse Inventory',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'Monitor warehouse stock levels, capacity utilization, and low-inventory reorder alerts.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate400),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.emeraldAccent),
                onPressed: _loadStockCapacity,
              ),
            ],
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(child: _card('Total Stock Units', '${summary['total_stock_units']}', Icons.inventory, AppColors.emeraldAccent)),
              const SizedBox(width: 16),
              Expanded(child: _card('Low Stock Alerts', '${summary['low_stock_alerts']}', Icons.warning_amber, AppColors.amberAccent)),
              const SizedBox(width: 16),
              Expanded(child: _card('Warehouse Capacity Utilized', '${summary['warehouse_utilization_pct']}%', Icons.pie_chart_outline, AppColors.cyanAccent)),
            ],
          ),

          const SizedBox(height: 28),

          Text('Warehouse Supplement Inventory Capacity:', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360,
              childAspectRatio: 1.6,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: inventory.length,
            itemBuilder: (context, index) {
              final item = inventory[index];
              final pct = (item['capacity_percentage'] as num).toDouble() / 100.0;
              final isLow = item['stock_quantity'] <= 15;

              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.slate800,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isLow ? AppColors.amberAccent.withOpacity(0.5) : AppColors.slate700),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['name'],
                            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isLow ? AppColors.amberAccent : AppColors.emeraldDark,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item['capacity_status'],
                            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Text('Category: ${item['category']}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.slate400)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Stock Level: ${item['stock_quantity']} / ${item['max_warehouse_capacity']}', style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                        Text('${item['capacity_percentage']}% Full', style: GoogleFonts.inter(fontSize: 12, color: AppColors.emeraldAccent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    LinearProgressIndicator(
                      value: pct,
                      backgroundColor: AppColors.slate900,
                      color: isLow ? AppColors.amberAccent : AppColors.emeraldAccent,
                      minHeight: 6,
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

  Widget _card(String title, String value, IconData icon, Color color) {
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(title, style: GoogleFonts.inter(fontSize: 12, color: AppColors.slate400)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
