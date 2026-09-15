class DiscountModel {
  final int id;
  final String code;
  final String description;
  final String discountType;
  final double discountValue;
  final double minOrderAmount;
  final int timesUsed;
  final String expiresAt;
  final bool isActive;

  DiscountModel({
    required this.id,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minOrderAmount,
    required this.timesUsed,
    required this.expiresAt,
    required this.isActive,
  });

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      discountType: json['discount_type'] ?? 'percentage',
      discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0.0,
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble() ?? 0.0,
      timesUsed: json['times_used'] ?? 0,
      expiresAt: json['expires_at'] ?? '',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }
}
