class OrderItemModel {
  final int id;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? 'Supplement Item',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 1,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OrderModel {
  final int id;
  final String orderNumber;
  final int userId;
  final double totalAmount;
  final double discountAmount;
  final double finalAmount;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final String shippingAddress;
  final String customerPhone;
  final String customerName;
  final String customerEmail;
  final String distributorName;
  final String createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.totalAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.shippingAddress,
    required this.customerPhone,
    required this.customerName,
    required this.customerEmail,
    required this.distributorName,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] as List? ?? [];
    List<OrderItemModel> itemsList = rawItems.map((i) => OrderItemModel.fromJson(i)).toList();

    return OrderModel(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      userId: json['user_id'] ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (json['final_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Pending',
      paymentStatus: json['payment_status'] ?? 'Pending',
      paymentMethod: json['payment_method'] ?? 'Cash on Delivery',
      shippingAddress: json['shipping_address'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      customerName: json['customer_name'] ?? 'Client',
      customerEmail: json['customer_email'] ?? '',
      distributorName: json['distributor_name'] ?? 'Unassigned',
      createdAt: json['created_at'] ?? '',
      items: itemsList,
    );
  }
}
