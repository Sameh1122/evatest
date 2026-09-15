import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/app_state.dart';
import 'theme/app_colors.dart';
import 'views/components/navbar.dart';
import 'views/components/auth_modal.dart';
import 'views/client/products_page.dart';
import 'views/client/profile_page.dart';
import 'views/client/favorites_page.dart';
import 'views/client/cart_page.dart';
import 'views/client/orders_status_page.dart';
import 'views/admin/add_product_page.dart';
import 'views/admin/edit_products_page.dart';
import 'views/admin/discounts_page.dart';
import 'views/admin/admin_orders_page.dart';
import 'views/admin/reports_page.dart';
import 'views/admin/notification_center_page.dart';
import 'views/distributor/delivery_management_page.dart';
import 'views/distributor/stock_capacity_page.dart';
import 'views/distributor/distributor_orders_page.dart';

void main() {
  runApp(const NutriPulseApp());
}

class NutriPulseApp extends StatefulWidget {
  const NutriPulseApp({Key? key}) : super(key: key);

  @override
  State<NutriPulseApp> createState() => _NutriPulseAppState();
}

class _NutriPulseAppState extends State<NutriPulseApp> {
  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, child) {
        final isMobileDevice = _appState.viewportMode == DeviceViewport.mobileAndroid;

        return MaterialApp(
          title: 'Limitless Naturals by Eva Pharma',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.slate900,
            colorScheme: const ColorScheme.dark(
              primary: AppColors.limitlessGold,
              secondary: AppColors.cyanAccent,
              surface: AppColors.slate800,
              background: AppColors.slate900,
            ),
            textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
            useMaterial3: true,
          ),
          home: Scaffold(
            body: Column(
              children: [
                if (!isMobileDevice) AppNavbar(state: _appState),
                Expanded(
                  child: _buildBodyLayout(context, _appState),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBodyLayout(BuildContext context, AppState state) {
    if (state.viewportMode == DeviceViewport.mobileAndroid) {
      return Container(
        color: const Color(0xFF070D18),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Top device frame badge
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.limitlessGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.limitlessGold.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone_android, color: AppColors.limitlessGold, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Limitless Android App (Pixel / Galaxy S24 Native Frame)',
                        style: GoogleFonts.inter(color: AppColors.limitlessGold, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      TextButton.icon(
                        onPressed: () => state.setViewportMode(DeviceViewport.desktopWeb),
                        icon: const Icon(Icons.desktop_windows, size: 14, color: Colors.white),
                        label: Text('Switch to Web View', style: GoogleFonts.inter(color: Colors.white, fontSize: 11)),
                      ),
                    ],
                  ),
                ),

                // Authentic Mobile Phone Frame
                Container(
                  width: 410,
                  height: 840,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(44),
                    border: Border.all(color: const Color(0xFF334155), width: 10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.limitlessGold.withOpacity(0.2),
                        blurRadius: 40,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.8),
                        blurRadius: 25,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(34),
                    child: Scaffold(
                      backgroundColor: AppColors.slate900,
                      appBar: _buildMobileAppBar(context, state),
                      body: Column(
                        children: [
                          // Mobile Content View
                          Expanded(
                            child: SingleChildScrollView(
                              child: _buildBodyContent(state),
                            ),
                          ),
                        ],
                      ),
                      bottomNavigationBar: _buildMobileBottomBar(context, state),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Default Desktop Web Layout
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBodyContent(state),
          _buildFooter(),
        ],
      ),
    );
  }

  // --- NATIVE MOBILE APP BAR ---
  PreferredSizeWidget _buildMobileAppBar(BuildContext context, AppState state) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        color: AppColors.evaNavy,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.limitlessGold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.stars_rounded, color: Colors.black, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'LIMITLESS',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'BY EVA PHARMA',
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: AppColors.limitlessGold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Row(
                children: [
                  // Role indicator & switcher modal
                  InkWell(
                    onTap: () => _showRolePickerModal(context, state),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.slate800,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.limitlessGold.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.admin_panel_settings, color: AppColors.limitlessGold, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            _getRoleLabel(state.currentRole),
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const Icon(Icons.arrow_drop_down, color: AppColors.limitlessGold, size: 16),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Cart Icon Button
                  if (state.currentRole == RoleMode.client || state.currentRole == RoleMode.visitor)
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                          onPressed: () {
                            if (state.currentUser == null) {
                              showDialog(context: context, builder: (_) => AuthModal(state: state));
                            } else {
                              state.setClientTab(0);
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  backgroundColor: AppColors.slate900,
                                  child: CartPage(state: state),
                                ),
                              );
                            }
                          },
                        ),
                        if (state.cartCount > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: AppColors.limitlessGold,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                              child: Text(
                                '${state.cartCount}',
                                style: GoogleFonts.inter(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),

                  // User Auth Avatar / Login
                  if (state.currentUser != null)
                    IconButton(
                      icon: CircleAvatar(
                        backgroundColor: AppColors.limitlessGold,
                        radius: 12,
                        child: Text(
                          state.currentUser!.name.substring(0, 1).toUpperCase(),
                          style: GoogleFonts.outfit(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      onPressed: () => state.logout(),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.login, color: AppColors.limitlessGold, size: 20),
                      onPressed: () => showDialog(context: context, builder: (_) => AuthModal(state: state)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- NATIVE MOBILE BOTTOM NAVIGATION BAR ---
  Widget _buildMobileBottomBar(BuildContext context, AppState state) {
    int currentIndex = 0;
    List<BottomNavigationBarItem> items = [];

    if (state.currentRole == RoleMode.visitor || state.currentRole == RoleMode.client) {
      currentIndex = state.clientTab.clamp(0, 4);
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'Store'),
        BottomNavigationBarItem(icon: Icon(Icons.health_and_safety_outlined), activeIcon: Icon(Icons.health_and_safety), label: 'AI Health'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), activeIcon: Icon(Icons.favorite), label: 'Favorites'),
        BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), activeIcon: Icon(Icons.local_shipping), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ];
    } else if (state.currentRole == RoleMode.admin) {
      currentIndex = state.adminTab.clamp(0, 5);
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'Add Item'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Catalog'),
        BottomNavigationBarItem(icon: Icon(Icons.discount_outlined), activeIcon: Icon(Icons.discount), label: 'Discounts'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'Reports'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_active_outlined), activeIcon: Icon(Icons.notifications_active), label: 'Alerts'),
      ];
    } else if (state.currentRole == RoleMode.distributor) {
      currentIndex = state.distributorTab.clamp(0, 2);
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), activeIcon: Icon(Icons.local_shipping), label: 'Queue'),
        BottomNavigationBarItem(icon: Icon(Icons.warehouse_outlined), activeIcon: Icon(Icons.warehouse), label: 'Capacity'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), activeIcon: Icon(Icons.list_alt), label: 'Orders'),
      ];
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.evaNavy,
        border: Border(top: BorderSide(color: AppColors.limitlessGold.withOpacity(0.3), width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: AppColors.evaNavy,
        selectedItemColor: AppColors.limitlessGold,
        unselectedItemColor: AppColors.slate400,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 10),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (state.currentRole == RoleMode.visitor || state.currentRole == RoleMode.client) {
            if (index > 1 && state.currentUser == null) {
              showDialog(context: context, builder: (_) => AuthModal(state: state));
            } else {
              state.setClientTab(index);
            }
          } else if (state.currentRole == RoleMode.admin) {
            state.setAdminTab(index);
          } else if (state.currentRole == RoleMode.distributor) {
            state.setDistributorTab(index);
          }
        },
        items: items,
      ),
    );
  }

  String _getRoleLabel(RoleMode role) {
    switch (role) {
      case RoleMode.visitor:
        return 'Visitor';
      case RoleMode.client:
        return 'Client';
      case RoleMode.admin:
        return 'Admin';
      case RoleMode.distributor:
        return 'Distributor';
    }
  }

  void _showRolePickerModal(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate800,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select App Mode / Role', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              _roleOptionTile(context, state, RoleMode.visitor, 'Visitor Mode', 'Browse catalog without login'),
              _roleOptionTile(context, state, RoleMode.client, 'Client Portal', 'Profile, AI Health Recommender, Cart, Orders'),
              _roleOptionTile(context, state, RoleMode.admin, 'Admin Dashboard', 'Add/edit products, promo discounts, reports'),
              _roleOptionTile(context, state, RoleMode.distributor, 'Distributor Logistics', 'Delivery queue, stock capacity'),
            ],
          ),
        );
      },
    );
  }

  Widget _roleOptionTile(BuildContext context, AppState state, RoleMode role, String title, String subtitle) {
    final isSelected = state.currentRole == role;
    return ListTile(
      leading: Icon(
        role == RoleMode.admin
            ? Icons.admin_panel_settings
            : role == RoleMode.distributor
                ? Icons.local_shipping
                : Icons.person,
        color: isSelected ? AppColors.limitlessGold : AppColors.slate400,
      ),
      title: Text(title, style: GoogleFonts.inter(color: isSelected ? AppColors.limitlessGold : Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(color: AppColors.slate400, fontSize: 12)),
      trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.limitlessGold) : null,
      onTap: () {
        state.setRole(role);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildBodyContent(AppState state) {
    // Visitor / Client Portal
    if (state.currentRole == RoleMode.visitor || state.currentRole == RoleMode.client) {
      switch (state.clientTab) {
        case 0:
          return ProductsPage(state: state);
        case 1:
          return ProfilePage(state: state);
        case 2:
          return FavoritesPage(state: state);
        case 3:
          return OrdersStatusPage(state: state);
        case 4:
          return ProfilePage(state: state);
        default:
          return ProductsPage(state: state);
      }
    }

    // Admin Portal
    if (state.currentRole == RoleMode.admin) {
      switch (state.adminTab) {
        case 0:
          return AddProductPage(state: state);
        case 1:
          return EditProductsPage(state: state);
        case 2:
          return DiscountsPage(state: state);
        case 3:
          return AdminOrdersPage(state: state);
        case 4:
          return ReportsPage(state: state);
        case 5:
          return NotificationCenterPage(state: state);
        default:
          return EditProductsPage(state: state);
      }
    }

    // Distributor Portal
    if (state.currentRole == RoleMode.distributor) {
      switch (state.distributorTab) {
        case 0:
          return DeliveryManagementPage(state: state);
        case 1:
          return StockCapacityPage(state: state);
        case 2:
          return DistributorOrdersPage(state: state);
        default:
          return DeliveryManagementPage(state: state);
      }
    }

    return ProductsPage(state: state);
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0B1120),
        border: Border(top: BorderSide(color: AppColors.slate700)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt, color: AppColors.emeraldAccent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Limitless Naturals by Eva Pharma',
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                '© 2026 Eva Pharma Inc. All rights reserved.',
                style: GoogleFonts.inter(color: AppColors.slate500, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Disclaimer: Statements regarding dietary supplements have not been evaluated by the FDA and are not intended to diagnose, treat, cure, or prevent any disease.',
            style: GoogleFonts.inter(color: AppColors.slate500, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
