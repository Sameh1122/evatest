import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/discount_model.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';

enum RoleMode { visitor, client, admin, distributor }
enum DeviceViewport { desktopWeb, mobileAndroid }

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class AppState extends ChangeNotifier {
  RoleMode _currentRole = RoleMode.visitor;
  DeviceViewport _viewportMode = DeviceViewport.desktopWeb;
  UserModel? _currentUser;
  ClientProfileModel? _clientProfile;

  List<ProductModel> _products = [];
  List<ProductRecommendation> _recommendations = [];
  final Set<int> _favoriteProductIds = {};
  final List<CartItem> _cart = [];

  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _selectedHealthTag = '';

  Map<String, dynamic>? _appliedDiscount;
  bool _isLoading = false;
  String? _errorMessage;

  // Active Navigation Tab for each portal view
  int _clientTab = 0; // 0: Products, 1: Recommendations, 2: Favorites, 3: Orders, 4: Profile
  int _adminTab = 0;  // 0: Add Product, 1: Edit Products, 2: Discounts, 3: Orders, 4: Reports
  int _distributorTab = 0; // 0: Deliveries, 1: Stock Capacity, 2: Orders

  // Getters
  RoleMode get currentRole => _currentRole;
  DeviceViewport get viewportMode => _viewportMode;
  UserModel? get currentUser => _currentUser;
  ClientProfileModel? get clientProfile => _clientProfile;
  List<ProductModel> get products => _products;
  List<ProductRecommendation> get recommendations => _recommendations;
  Set<int> get favoriteProductIds => _favoriteProductIds;
  List<CartItem> get cart => _cart;

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get selectedHealthTag => _selectedHealthTag;

  Map<String, dynamic>? get appliedDiscount => _appliedDiscount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get clientTab => _clientTab;
  int get adminTab => _adminTab;
  int get distributorTab => _distributorTab;

  double get cartSubtotal => _cart.fold(0.0, (sum, item) => sum + item.subtotal);
  double get cartDiscountAmount {
    if (_appliedDiscount == null) return 0.0;
    return (_appliedDiscount!['discount_amount'] as num?)?.toDouble() ?? 0.0;
  }
  double get cartTotal => (cartSubtotal - cartDiscountAmount).clamp(0.0, double.infinity);
  int get cartCount => _cart.fold(0, (count, item) => count + item.quantity);

  AppState() {
    loadProducts();
  }

  void setRole(RoleMode role) {
    _currentRole = role;
    if (role == RoleMode.visitor) {
      _currentUser = null;
      _clientProfile = null;
      ApiService.authToken = null;
    }
    notifyListeners();
  }

  void setViewportMode(DeviceViewport mode) {
    _viewportMode = mode;
    notifyListeners();
  }

  void setClientTab(int index) {
    _clientTab = index;
    notifyListeners();
  }

  void setAdminTab(int index) {
    _adminTab = index;
    notifyListeners();
  }

  void setDistributorTab(int index) {
    _distributorTab = index;
    notifyListeners();
  }

  // --- AUTH METHODS ---
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiService.login(email, password);
      _currentUser = UserModel.fromJson(data['user']);
      if (data['profile'] != null) {
        _clientProfile = ClientProfileModel.fromJson(data['profile']);
      }

      // Map user role
      if (_currentUser!.role == 'admin') {
        _currentRole = RoleMode.admin;
      } else if (_currentUser!.role == 'distributor') {
        _currentRole = RoleMode.distributor;
      } else {
        _currentRole = RoleMode.client;
      }

      await loadRecommendations();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String role = 'client',
    String phone = '',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiService.register(
        name: name,
        email: email,
        password: password,
        role: role,
        phone: phone,
      );
      _currentUser = UserModel.fromJson(data['user']);
      if (data['profile'] != null) {
        _clientProfile = ClientProfileModel.fromJson(data['profile']);
      }
      _currentRole = role == 'admin' ? RoleMode.admin : (role == 'distributor' ? RoleMode.distributor : RoleMode.client);

      await loadRecommendations();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    _clientProfile = null;
    _currentRole = RoleMode.visitor;
    _cart.clear();
    _appliedDiscount = null;
    ApiService.authToken = null;
    notifyListeners();
  }

  Future<void> updateHealthProfile(Map<String, dynamic> body) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.updateProfile(body);
      if (data['profile'] != null) {
        _clientProfile = ClientProfileModel.fromJson(data['profile']);
      }
      await loadRecommendations();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- CATALOG METHODS ---
  Future<void> loadProducts() async {
    try {
      _products = await ApiService.fetchProducts(
        search: _searchQuery,
        category: _selectedCategory,
        healthTag: _selectedHealthTag,
      );
      notifyListeners();
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  Future<void> loadRecommendations() async {
    try {
      _recommendations = await ApiService.fetchRecommendations();
      notifyListeners();
    } catch (e) {
      print('Error loading recommendations: $e');
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadProducts();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    loadProducts();
  }

  void setHealthTag(String tag) {
    _selectedHealthTag = tag;
    loadProducts();
  }

  // --- FAVORITES & CART METHODS ---
  void toggleFavorite(int productId) {
    if (_favoriteProductIds.contains(productId)) {
      _favoriteProductIds.remove(productId);
    } else {
      _favoriteProductIds.add(productId);
    }
    notifyListeners();
  }

  bool isFavorite(int productId) => _favoriteProductIds.contains(productId);

  void addToCart(ProductModel product, {int quantity = 1}) {
    final existingIndex = _cart.indexWhere((c) => c.product.id == product.id);
    if (existingIndex != -1) {
      _cart[existingIndex].quantity += quantity;
    } else {
      _cart.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void updateCartQuantity(int productId, int delta) {
    final index = _cart.indexWhere((c) => c.product.id == productId);
    if (index != -1) {
      _cart[index].quantity += delta;
      if (_cart[index].quantity <= 0) {
        _cart.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeFromCart(int productId) {
    _cart.removeWhere((c) => c.product.id == productId);
    notifyListeners();
  }

  Future<bool> applyPromoCode(String code) async {
    try {
      _appliedDiscount = await ApiService.validateDiscount(code, cartSubtotal);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void removePromoCode() {
    _appliedDiscount = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> completeCheckout({
    required String shippingAddress,
    required String phone,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final items = _cart
          .map((c) => {
                'product_id': c.product.id,
                'quantity': c.quantity,
              })
          .toList();

      final result = await ApiService.checkout(
        items: items,
        shippingAddress: shippingAddress,
        customerPhone: phone,
        paymentMethod: paymentMethod,
        discountCode: _appliedDiscount != null ? _appliedDiscount!['code'] : null,
      );

      _cart.clear();
      _appliedDiscount = null;
      await loadProducts(); // Refresh stock
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
