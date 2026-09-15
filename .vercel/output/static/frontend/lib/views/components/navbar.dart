import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import 'auth_modal.dart';

class AppNavbar extends StatelessWidget {
  final AppState state;

  const AppNavbar({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.evaNavy,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          bottom: BorderSide(color: AppColors.limitlessGold.withOpacity(0.3), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Logo & Brand Title (Limitless by Eva Pharma)
          InkWell(
            onTap: () {
              if (state.currentRole == RoleMode.client) state.setClientTab(0);
              if (state.currentRole == RoleMode.admin) state.setAdminTab(0);
              if (state.currentRole == RoleMode.distributor) state.setDistributorTab(0);
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.limitlessGold, AppColors.limitlessAmber],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.stars_rounded, color: Colors.black, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LIMITLESS',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      'BY EVA PHARMA',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.limitlessGold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 32),

          // Nav Links
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (state.currentRole == RoleMode.client || state.currentRole == RoleMode.visitor) ...[
                    _navButton(context, 'Limitless Store', 0, state.clientTab, () => state.setClientTab(0)),
                    _navButton(context, 'AI Health Recommender', 1, state.clientTab, () => state.setClientTab(1)),
                    _navButton(context, 'Favorites', 2, state.clientTab, () => _handleAuthCheck(context, state, () => state.setClientTab(2))),
                    _navButton(context, 'Orders Status', 3, state.clientTab, () => _handleAuthCheck(context, state, () => state.setClientTab(3))),
                    _navButton(context, 'Health Profile', 4, state.clientTab, () => _handleAuthCheck(context, state, () => state.setClientTab(4))),
                  ] else if (state.currentRole == RoleMode.admin) ...[
                    _navButton(context, 'Add Limitless Item', 0, state.adminTab, () => state.setAdminTab(0)),
                    _navButton(context, 'Edit Catalog', 1, state.adminTab, () => state.setAdminTab(1)),
                    _navButton(context, 'Promo Discounts', 2, state.adminTab, () => state.setAdminTab(2)),
                    _navButton(context, 'Orders Management', 3, state.adminTab, () => state.setAdminTab(3)),
                    _navButton(context, 'Reports & Analytics', 4, state.adminTab, () => state.setAdminTab(4)),
                  ] else if (state.currentRole == RoleMode.distributor) ...[
                    _navButton(context, 'Delivery Queue', 0, state.distributorTab, () => state.setDistributorTab(0)),
                    _navButton(context, 'Stock Capacity', 1, state.distributorTab, () => state.setDistributorTab(1)),
                    _navButton(context, 'Assigned Orders', 2, state.distributorTab, () => state.setDistributorTab(2)),
                  ],
                ],
              ),
            ),
          ),

          // Role Switcher Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.slate800,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.limitlessGold.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings, color: AppColors.limitlessGold, size: 16),
                const SizedBox(width: 6),
                DropdownButton<RoleMode>(
                  value: state.currentRole,
                  dropdownColor: AppColors.slate800,
                  underline: const SizedBox(),
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
                  items: const [
                    DropdownMenuItem(value: RoleMode.visitor, child: Text('Visitor View')),
                    DropdownMenuItem(value: RoleMode.client, child: Text('Client Portal')),
                    DropdownMenuItem(value: RoleMode.admin, child: Text('Admin Portal')),
                    DropdownMenuItem(value: RoleMode.distributor, child: Text('Distributor Portal')),
                  ],
                  onChanged: (role) {
                    if (role != null) {
                      state.setRole(role);
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Device Viewport Toggle (Desktop Web vs Mobile Android)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.slate800,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.limitlessGold.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Tooltip(
                  message: 'Desktop Web View',
                  child: InkWell(
                    onTap: () => state.setViewportMode(DeviceViewport.desktopWeb),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: state.viewportMode == DeviceViewport.desktopWeb ? AppColors.limitlessGold : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.desktop_windows,
                            size: 14,
                            color: state.viewportMode == DeviceViewport.desktopWeb ? Colors.black : AppColors.slate300,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Web',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: state.viewportMode == DeviceViewport.desktopWeb ? Colors.black : AppColors.slate300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Tooltip(
                  message: 'Mobile Android View',
                  child: InkWell(
                    onTap: () => state.setViewportMode(DeviceViewport.mobileAndroid),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: state.viewportMode == DeviceViewport.mobileAndroid ? AppColors.limitlessGold : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.phone_android,
                            size: 14,
                            color: state.viewportMode == DeviceViewport.mobileAndroid ? Colors.black : AppColors.slate300,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Android',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: state.viewportMode == DeviceViewport.mobileAndroid ? Colors.black : AppColors.slate300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Cart Icon
          if (state.currentRole == RoleMode.client || state.currentRole == RoleMode.visitor)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                  onPressed: () {
                    _handleAuthCheck(context, state, () {
                      state.setClientTab(0);
                    });
                  },
                ),
                if (state.cartCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.limitlessGold,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        '${state.cartCount}',
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),

          const SizedBox(width: 12),

          // User Profile / Auth Button
          if (state.currentUser != null) ...[
            PopupMenuButton<String>(
              color: AppColors.slate800,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.limitlessGold.withOpacity(0.2),
                    radius: 16,
                    child: Text(
                      state.currentUser!.name.substring(0, 1).toUpperCase(),
                      style: GoogleFonts.outfit(color: AppColors.limitlessGold, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.currentUser!.name.split(' ')[0],
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              onSelected: (value) {
                if (value == 'logout') state.logout();
                if (value == 'profile' && state.currentRole == RoleMode.client) state.setClientTab(4);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Text('My Profile', style: GoogleFonts.inter(color: Colors.white)),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Text('Logout', style: GoogleFonts.inter(color: AppColors.roseAccent)),
                ),
              ],
            ),
          ] else
            ElevatedButton.icon(
              onPressed: () => showDialog(context: context, builder: (_) => AuthModal(state: state)),
              icon: const Icon(Icons.login, size: 16, color: Colors.black),
              label: Text('Login / Register', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.limitlessGold,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _navButton(BuildContext context, String label, int index, int currentTab, VoidCallback onTap) {
    final isActive = currentTab == index;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isActive ? AppColors.limitlessGold : AppColors.slate300,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _handleAuthCheck(BuildContext context, AppState state, VoidCallback onAllowed) {
    if (state.currentRole == RoleMode.visitor || state.currentUser == null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.slate800,
          title: Text('Account Login Required', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(
            'To access cart, favorites, profile, and orders, please log in or complete your client health profile.',
            style: GoogleFonts.inter(color: AppColors.slate300),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.slate400)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                showDialog(context: context, builder: (_) => AuthModal(state: state));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.limitlessGold),
              child: Text('Log In Now', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      onAllowed();
    }
  }
}
