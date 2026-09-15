class ProductModel {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String category;
  final double price;
  final int stockQuantity;
  final String dosageInstructions;
  final String imageUrl;
  final String healthTags;
  final String contraindications;
  final String activeIngredients;
  final bool isFeatured;
  final bool isActive;

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.category,
    required this.price,
    required this.stockQuantity,
    required this.dosageInstructions,
    required this.imageUrl,
    required this.healthTags,
    required this.contraindications,
    required this.activeIngredients,
    required this.isFeatured,
    required this.isActive,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: json['stock_quantity'] ?? 0,
      dosageInstructions: json['dosage_instructions'] ?? '',
      imageUrl: json['image_url'] ?? '',
      healthTags: json['health_tags'] ?? '',
      contraindications: json['contraindications'] ?? '',
      activeIngredients: json['active_ingredients'] ?? '',
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'category': category,
      'price': price,
      'stock_quantity': stockQuantity,
      'dosage_instructions': dosageInstructions,
      'image_url': imageUrl,
      'health_tags': healthTags,
      'contraindications': contraindications,
      'active_ingredients': activeIngredients,
      'is_featured': isFeatured ? 1 : 0,
      'is_active': isActive ? 1 : 0,
    };
  }
}

class ProductRecommendation {
  final ProductModel product;
  final int score;
  final List<String> matchReasons;
  final List<String> warnings;

  ProductRecommendation({
    required this.product,
    required this.score,
    required this.matchReasons,
    required this.warnings,
  });

  factory ProductRecommendation.fromJson(Map<String, dynamic> json) {
    return ProductRecommendation(
      product: ProductModel.fromJson(json['product'] ?? {}),
      score: json['score'] ?? 0,
      matchReasons: List<String>.from(json['matchReasons'] ?? []),
      warnings: List<String>.from(json['warnings'] ?? []),
    );
  }
}
