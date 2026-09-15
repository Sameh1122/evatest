import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';

class ReportsPage extends StatefulWidget {
  final AppState state;

  const ReportsPage({Key? key, required this.state}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  Map<String, dynamic>? reportsData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() async {
    setState(() => isLoading = true);
    try {
      reportsData = await ApiService.fetchReportsSummary();
    } catch (e) {
      print('Error loading reports: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || reportsData == null) {
      return const Padding(
        padding: EdgeInsets.all(60),
        child: Center(child: CircularProgressIndicator(color: AppColors.emeraldAccent)),
      );
    }

    final metrics = reportsData!['metrics'] ?? {};
    final topProducts = List<Map<String, dynamic>>.from(reportsData!['top_products'] ?? []);
    final categorySales = Map<String, dynamic>.from(reportsData!['sales_by_category'] ?? {});
    final lowStock = List<Map<String, dynamic>>.from(reportsData!['low_stock_inventory'] ?? []);

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
                    'Admin Portal: Analytics & Reports Dashboard',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'Real-time overview of revenue performance, top supplements, and stock alerts.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate400),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.emeraldAccent),
                onPressed: _loadReports,
              ),
            ],
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(child: _metricCard('Total Revenue', '\$${(metrics['total_revenue'] ?? 0.0).toStringAsFixed(2)}', Icons.monetization_on_outlined, AppColors.emeraldAccent)),
              const SizedBox(width: 16),
              Expanded(child: _metricCard('Pending Revenue', '\$${(metrics['pending_revenue'] ?? 0.0).toStringAsFixed(2)}', Icons.pending_actions, AppColors.amberAccent)),
              const SizedBox(width: 16),
              Expanded(child: _metricCard('Active Clients', '${metrics['total_clients'] ?? 0}', Icons.people_outline, AppColors.cyanAccent)),
              const SizedBox(width: 16),
              Expanded(child: _metricCard('Low Stock Alerts', '${metrics['low_stock_count'] ?? 0}', Icons.warning_amber_rounded, AppColors.roseAccent)),
            ],
          ),

          const SizedBox(height: 28),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
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
                      Text('Top Selling Supplements', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 16),
                      if (topProducts.isEmpty)
                        Text('No sales data recorded yet.', style: GoogleFonts.inter(color: AppColors.slate400))
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: topProducts.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final p = topProducts[index];
                            return Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: AppColors.emeraldAccent,
                                  child: Text('${index + 1}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(p['name'], style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600))),
                                Text('${p['quantity']} Units Sold', style: GoogleFonts.inter(color: AppColors.emeraldAccent, fontWeight: FontWeight.bold)),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 24),

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
                      Text('Sales Revenue by Category', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 16),
                      ...categorySales.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key, style: GoogleFonts.inter(color: AppColors.slate300, fontSize: 13)),
                                  Text('\$${(entry.value as num).toStringAsFixed(2)}', style: GoogleFonts.inter(color: AppColors.emeraldAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: (entry.value as num) / 200.0,
                                backgroundColor: AppColors.slate900,
                                color: AppColors.emeraldAccent,
                                minHeight: 6,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          if (lowStock.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.roseAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.roseAccent.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.roseAccent),
                      const SizedBox(width: 10),
                      Text('Low Stock Inventory Warning', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.roseAccent)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: lowStock.map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.slate800,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(item['name'], style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.roseAccent, borderRadius: BorderRadius.circular(4)),
                              child: Text('${item['stock']} LEFT', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value, IconData icon, Color color) {
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
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.inter(fontSize: 12, color: AppColors.slate400)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
