import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/discount_model.dart';
import '../models/order_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
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
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      authToken = data['token'];
      return data;
    } else {
      throw Exception(data['error'] ?? 'Login failed');
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String role = 'client',
    String phone = '',
  }) async {
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
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      authToken = data['token'];
      return data;
    } else {
      throw Exception(data['error'] ?? 'Registration failed');
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to fetch profile');
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/profile'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    }
    throw Exception(data['error'] ?? 'Failed to update health profile');
  }

  // --- PRODUCTS & RECOMMENDATIONS API ---
  static Future<List<ProductModel>> fetchProducts({
    String? search,
    String? category,
    String? healthTag,
  }) async {
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (category != null && category != 'All') queryParams['category'] = category;
    if (healthTag != null && healthTag.isNotEmpty) queryParams['health_tag'] = healthTag;

    final uri = Uri.parse('$baseUrl/products').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['products'] ?? [];
      return list.map((p) => ProductModel.fromJson(p)).toList();
    }
    throw Exception('Failed to load products');
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
