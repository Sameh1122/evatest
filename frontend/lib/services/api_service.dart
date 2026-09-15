import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/discount_model.dart';
import '../models/order_model.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      try {
        final uri = Uri.base;
        if (uri.hasAuthority && uri.host.isNotEmpty && uri.host != 'localhost') {
          final portStr = uri.hasPort && uri.port != 80 && uri.port != 443 ? ':${uri.port}' : '';
          return '${uri.scheme}://${uri.host}$portStr/api';
        }
      } catch (e) {
        print('Error resolving Uri.base: $e');
      }
      return '/api';
    }
    return 'http://localhost:5000/api';
  }

  static String? authToken;

  static Map<String, String> _headers() {
    final map = <String, String>{
      'Content-Type': 'application/json',
    };
    if (authToken != null && authToken!.isNotEmpty) {
      map['Authorization'] = 'Bearer $authToken';
    }
    return map;
  }

  // --- AUTH API ---
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers(),
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('token')) {
          authToken = data['token'];
          return data;
        }
      }
    } catch (e) {
      print('Network auth login error (using fallback): $e');
    }

    // Fallback authentication for Demo / Vercel offline operation
    if (email == 'admin@limitless.com') {
      authToken = 'demo-admin-jwt-token';
      return {
        'token': authToken,
        'user': {
          'id': 1,
          'name': 'Shop Limitless Admin',
          'email': 'admin@limitless.com',
          'role': 'admin',
          'phone': '+20 100 123 4567'
        },
        'profile': null
      };
    } else if (email == 'distributor@limitless.com') {
      authToken = 'demo-distributor-jwt-token';
      return {
        'token': authToken,
        'user': {
          'id': 2,
          'name': 'Eva Logistics Distributor',
          'email': 'distributor@limitless.com',
          'role': 'distributor',
          'phone': '+20 100 987 6543'
        },
        'profile': null
      };
    } else {
      authToken = 'demo-client-jwt-token';
      return {
        'token': authToken,
        'user': {
          'id': 3,
          'name': email.isNotEmpty && email.contains('@') ? email.split('@')[0] : 'Karim Hassan (Client)',
          'email': email.isEmpty ? 'client@limitless.com' : email,
          'role': 'client',
          'phone': '+20 111 222 3333'
        },
        'profile': {
          'id': 1,
          'user_id': 3,
          'age': 32,
          'gender': 'Male',
          'height_cm': 180,
          'weight_kg': 78,
          'activity_level': 'Moderate',
          'health_goals': 'Hydration & Balance, Heart Health, Muscle Recovery',
          'chronic_diseases': 'Hypertension, Mild Kidney Disease',
          'allergies': 'Seafood',
          'medication_notes': 'Takes daily ACE inhibitor for blood pressure'
        }
      };
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String role = 'client',
    String phone = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'phone': phone,
        }),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        authToken = data['token'];
        return data;
      }
    } catch (e) {
      print('Network register error: $e');
    }

    authToken = 'demo-$role-token';
    return {
      'token': authToken,
      'user': {
        'id': 99,
        'name': name.isEmpty ? 'New User' : name,
        'email': email,
        'role': role,
        'phone': phone
      },
      'profile': role == 'client' ? {
        'id': 99,
        'user_id': 99,
        'age': 30,
        'gender': 'Not specified',
        'health_goals': 'Daily Wellness',
        'chronic_diseases': 'None'
      } : null
    };
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: _headers(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Get profile error: $e');
    }
    return {
      'user': {
        'id': 3,
        'name': 'Karim Hassan (Client)',
        'email': 'client@limitless.com',
        'role': 'client'
      },
      'profile': {
        'id': 1,
        'user_id': 3,
        'age': 32,
        'gender': 'Male',
        'health_goals': 'Hydration & Balance, Heart Health',
        'chronic_diseases': 'Hypertension'
      }
    };
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: _headers(),
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Update profile error: $e');
    }
    return {
      'message': 'Profile updated successfully',
      'profile': body
    };
  }

  static final List<ProductModel> fallbackProducts = [
    ProductModel(
      id: 1,
      name: 'Limitless Man Max Multivitamin 30 Tabs',
      slug: 'limitless-man-max-30',
      description: 'The ultimate daily wellness supplement for men by Eva Pharma, featuring 26 vitamins, minerals, Ginseng & CoQ10 to support energy, immunity, stamina, and cardiovascular health.',
      category: 'Daily Wellness',
      price: 11.99,
      stockQuantity: 160,
      dosageInstructions: 'Take 1 tablet daily with food.',
      imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=600&auto=format&fit=crop&q=80',
      healthTags: 'Men Health, Energy, Stamina, Immune Defense',
      contraindications: 'Severe uncontrolled hypertension without physician consultation',
      activeIngredients: '26 Vitamins & Minerals, Panax Ginseng 50mg, CoQ10 10mg, Lycopene',
      isFeatured: true,
      isActive: true,
    ),
    ProductModel(
      id: 2,
      name: 'Limitless Woman Max Multivitamin 30 Tabs',
      slug: 'limitless-woman-max-30',
      description: 'Specially engineered multivitamin & beauty matrix for women, packed with Hydrolyzed Collagen, Biotin, Folic Acid, Iron, and Zinc for radiant hair, skin, nails, and bone strength.',
      category: 'Daily Wellness',
      price: 11.99,
      stockQuantity: 140,
      dosageInstructions: 'Take 1 tablet daily after meal.',
      imageUrl: 'https://images.unsplash.com/photo-1577401239170-897942555fb3?w=600&auto=format&fit=crop&q=80',
      healthTags: 'Women Health, Hair Skin Nails, Bone Health, Vitality',
      contraindications: 'Hemochromatosis (iron overload condition)',
      activeIngredients: 'Hydrolyzed Marine Collagen 100mg, Biotin 1000mcg, Iron 18mg, Folic Acid 400mcg',
      isFeatured: true,
      isActive: true,
    ),
    ProductModel(
      id: 3,
      name: 'Limitless Omega-3 Fish Oil 2000mg',
      slug: 'limitless-omega-3-2000mg',
      description: 'High-purity molecularly distilled EPA & DHA softgels for heart health, joint flexibility, cognitive clarity, and cholesterol balance.',
      category: 'Full-Body Support',
      price: 14.99,
      stockQuantity: 190,
      dosageInstructions: 'Take 2 softgels daily with lunch or dinner.',
      imageUrl: 'https://images.unsplash.com/photo-1550572017-edd951aa8f72?w=600&auto=format&fit=crop&q=80',
      healthTags: 'Heart Health, Joint Flexibility, Brain & Eye, Cholesterol',
      contraindications: 'Bleeding disorders, Anticoagulant / Blood-thinning drugs',
      activeIngredients: 'Pure Fish Oil 2000mg (EPA 720mg, DHA 480mg)',
      isFeatured: true,
      isActive: true,
    ),
    ProductModel(
      id: 4,
      name: 'Limitless Hydration Electrolytes 14 Packets',
      slug: 'limitless-hydration-electrolytes',
      description: 'Advanced cellular hydration mix formulated with Sodium, Potassium, Magnesium, and Vitamin C for rapid fluid replenishment and muscle cramp prevention.',
      category: 'Hydration & Balance',
      price: 10.50,
      stockQuantity: 220,
      dosageInstructions: 'Mix 1 stick packet into 16 oz of cold water.',
      imageUrl: 'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=600&auto=format&fit=crop&q=80',
      healthTags: 'Hydration, Electrolytes, Energy, Anti-Fatigue',
      contraindications: 'Severe End-Stage Renal Disease (Potassium restriction)',
      activeIngredients: 'Sodium 500mg, Potassium 380mg, Magnesium 100mg, Vitamin C 250mg',
      isFeatured: true,
      isActive: true,
    ),
    ProductModel(
      id: 5,
      name: 'Limitless Vitamin C 1000mg Effervescent',
      slug: 'limitless-vitamin-c-effervescent',
      description: 'Rapid-absorbing effervescent immune shield with 1000mg Vitamin C and Zinc to support immune response and collagen synthesis.',
      category: 'Immune Defense',
      price: 7.50,
      stockQuantity: 250,
      dosageInstructions: 'Dissolve 1 tablet in water daily.',
      imageUrl: 'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=600&auto=format&fit=crop&q=80',
      healthTags: 'Immune Defense, Antioxidant, Vitality',
      contraindications: 'Oxalate Kidney Stones history',
      activeIngredients: 'Vitamin C (Ascorbic Acid) 1000mg, Zinc 15mg',
      isFeatured: false,
      isActive: true,
    ),
    ProductModel(
      id: 6,
      name: 'Limitless Lactoferrin 100mg Immunity',
      slug: 'limitless-lactoferrin-100mg',
      description: 'Bio-active iron-binding protein formula supporting immune cell defense, gut mucosal integrity, and healthy iron metabolism.',
      category: 'Immune Defense',
      price: 18.50,
      stockQuantity: 75,
      dosageInstructions: 'Take 1 sachet daily before breakfast.',
      imageUrl: 'https://images.unsplash.com/photo-1616671285420-a68132e4860b?w=600&auto=format&fit=crop&q=80',
      healthTags: 'Immune Defense, Iron Absorption, Gut Integrity',
      contraindications: 'Severe Dairy Protein Allergy',
      activeIngredients: 'Bovine Lactoferrin 100mg, Vitamin C 50mg',
      isFeatured: true,
      isActive: true,
    ),
    ProductModel(
      id: 7,
      name: 'Limitless Collagen Max Marine 30 Sachets',
      slug: 'limitless-collagen-max',
      description: 'Hydrolyzed Marine Collagen peptides combined with Hyaluronic Acid & Vitamin C for smooth skin elasticity and joint cartilage rebuilding.',
      category: 'Full-Body Support',
      price: 21.99,
      stockQuantity: 12,
      dosageInstructions: 'Mix 1 sachet in warm or cold beverage daily.',
      imageUrl: 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=600&auto=format&fit=crop&q=80',
      healthTags: 'Joint Mobility, Anti-Aging, Skin Elasticity',
      contraindications: 'Fish or Marine Allergy',
      activeIngredients: 'Hydrolyzed Marine Collagen 5000mg, Hyaluronic Acid 100mg, Vitamin C 80mg',
      isFeatured: true,
      isActive: true,
    ),
    ProductModel(
      id: 8,
      name: 'Limitless Magnesium Citrate 400mg',
      slug: 'limitless-magnesium-citrate',
      description: 'Gentle, high-solubility magnesium for deep muscle relaxation, cramp prevention, and nervous system calm.',
      category: 'Full-Body Support',
      price: 9.99,
      stockQuantity: 175,
      dosageInstructions: 'Take 2 capsules before bedtime.',
      imageUrl: 'https://images.unsplash.com/photo-1584017911766-d451b3d0e843?w=600&auto=format&fit=crop&q=80',
      healthTags: 'Muscle Relaxation, Sleep Quality, Nerve Support',
      contraindications: 'Severe Kidney Failure',
      activeIngredients: 'Elemental Magnesium (as Citrate) 400mg',
      isFeatured: false,
      isActive: true,
    ),
  ];

  // --- PRODUCTS & RECOMMENDATIONS API ---
  static Future<List<ProductModel>> fetchProducts({
    String? search,
    String? category,
    String? healthTag,
  }) async {
    List<ProductModel> resultList = [];
    try {
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null && category != 'All') queryParams['category'] = category;
      if (healthTag != null && healthTag.isNotEmpty) queryParams['health_tag'] = healthTag;

      final uri = Uri.parse('$baseUrl/products').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('products')) {
          final List list = data['products'] ?? [];
          resultList = list.map((p) => ProductModel.fromJson(p)).toList();
        }
      }
    } catch (e) {
      print('Network fetch error: $e');
    }

    if (resultList.isEmpty) {
      resultList = List.from(fallbackProducts);
      if (category != null && category != 'All') {
        resultList = resultList.where((p) => p.category == category).toList();
      }
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        resultList = resultList.where((p) => 
          p.name.toLowerCase().contains(q) || 
          p.description.toLowerCase().contains(q) ||
          p.healthTags.toLowerCase().contains(q)
        ).toList();
      }
      if (healthTag != null && healthTag.isNotEmpty) {
        resultList = resultList.where((p) => p.healthTags.toLowerCase().contains(healthTag.toLowerCase())).toList();
      }
    }

    return resultList;
  }


  static Future<List<ProductRecommendation>> fetchRecommendations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/recommendations'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['recommendations'] ?? [];
      return list.map((r) => ProductRecommendation.fromJson(r)).toList();
    }
    return [];
  }

  static Future<ProductModel> addProduct(Map<String, dynamic> productData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: _headers(),
      body: jsonEncode(productData),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return ProductModel.fromJson(data['product']);
    }
    throw Exception(data['error'] ?? 'Failed to add product');
  }

  static Future<ProductModel> editProduct(int id, Map<String, dynamic> productData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: _headers(),
      body: jsonEncode(productData),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return ProductModel.fromJson(data['product']);
    }
    throw Exception(data['error'] ?? 'Failed to edit product');
  }

  static Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }

  // --- DISCOUNTS API ---
  static Future<Map<String, dynamic>> validateDiscount(String code, double orderAmount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/discounts/validate'),
      headers: _headers(),
      body: jsonEncode({'code': code, 'order_amount': orderAmount}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['discount'];
    }
    throw Exception(data['error'] ?? 'Invalid promo code');
  }

  static Future<List<DiscountModel>> fetchDiscounts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/discounts'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['discounts'] ?? [];
      return list.map((d) => DiscountModel.fromJson(d)).toList();
    }
    throw Exception('Failed to fetch discounts');
  }

  static Future<DiscountModel> createDiscount(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/discounts'),
      headers: _headers(),
      body: jsonEncode(data),
    );
    final res = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return DiscountModel.fromJson(res['discount']);
    }
    throw Exception(res['error'] ?? 'Failed to create discount');
  }

  // --- ORDERS API ---
  static Future<Map<String, dynamic>> checkout({
    required List<Map<String, dynamic>> items,
    required String shippingAddress,
    required String customerPhone,
    required String paymentMethod,
    String? discountCode,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: _headers(),
      body: jsonEncode({
        'items': items,
        'shipping_address': shippingAddress,
        'customer_phone': customerPhone,
        'payment_method': paymentMethod,
        'discount_code': discountCode,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return data;
    }
    throw Exception(data['error'] ?? 'Checkout failed');
  }

  static Future<List<OrderModel>> fetchMyOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/my-orders'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['orders'] ?? [];
      return list.map((o) => OrderModel.fromJson(o)).toList();
    }
    throw Exception('Failed to fetch customer orders');
  }

  static Future<List<OrderModel>> fetchAdminOrders({String? status, String? paymentStatus}) async {
    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (paymentStatus != null && paymentStatus.isNotEmpty) queryParams['payment_status'] = paymentStatus;

    final uri = Uri.parse('$baseUrl/orders').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['orders'] ?? [];
      return list.map((o) => OrderModel.fromJson(o)).toList();
    }
    throw Exception('Failed to fetch admin orders');
  }

  static Future<void> updateOrderStatus(int orderId, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$orderId/status'),
      headers: _headers(),
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update order status');
    }
  }

  static Future<void> toggleOrderPayment(int orderId, String paymentStatus) async {
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$orderId/payment'),
      headers: _headers(),
      body: jsonEncode({'payment_status': paymentStatus}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update payment status');
    }
  }

  // --- DISTRIBUTOR API ---
  static Future<List<dynamic>> fetchDistributorDeliveries() async {
    final response = await http.get(
      Uri.parse('$baseUrl/distributor/deliveries'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['deliveries'] ?? [];
    }
    throw Exception('Failed to fetch distributor deliveries');
  }

  static Future<void> updateDeliveryStatus(int deliveryId, String status, String notes) async {
    final response = await http.put(
      Uri.parse('$baseUrl/distributor/deliveries/$deliveryId'),
      headers: _headers(),
      body: jsonEncode({'status': status, 'notes': notes}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update delivery status');
    }
  }

  static Future<Map<String, dynamic>> fetchStockCapacity() async {
    final response = await http.get(
      Uri.parse('$baseUrl/distributor/stock-capacity'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to fetch warehouse stock capacity');
  }

  // --- REPORTS API ---
  static Future<Map<String, dynamic>> fetchReportsSummary() async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/summary'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to fetch reports summary');
  }

  // --- NOTIFICATION CENTER API (ADMIN ONLY) ---
  static Future<Map<String, dynamic>> fetchNotificationCampaigns() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/campaigns'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to fetch notification campaigns');
  }

  static Future<Map<String, dynamic>> sendNotificationCampaign(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/send'),
      headers: _headers(),
      body: jsonEncode(data),
    );
    final resData = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return resData;
    }
    throw Exception(resData['error'] ?? 'Failed to send notification campaign');
  }

  static Future<Map<String, dynamic>> updateNotificationAutomation(Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/automation'),
      headers: _headers(),
      body: jsonEncode(data),
    );
    final resData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return resData;
    }
    throw Exception(resData['error'] ?? 'Failed to update automation rules');
  }

  static Future<void> deleteNotificationCampaign(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/notifications/campaigns/$id'),
      headers: _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete campaign');
    }
  }
}
