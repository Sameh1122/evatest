class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String phone;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'visitor',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
    };
  }
}

class ClientProfileModel {
  final int id;
  final int userId;
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final String activityLevel;
  final String healthGoals;
  final String chronicDiseases;
  final String allergies;
  final String medicationNotes;

  ClientProfileModel({
    required this.id,
    required this.userId,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
    required this.healthGoals,
    required this.chronicDiseases,
    required this.allergies,
    required this.medicationNotes,
  });

  factory ClientProfileModel.fromJson(Map<String, dynamic> json) {
    return ClientProfileModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      age: json['age'] ?? 25,
      gender: json['gender'] ?? 'Unspecified',
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? 170.0,
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 70.0,
      activityLevel: json['activity_level'] ?? 'Moderate',
      healthGoals: json['health_goals'] ?? '',
      chronicDiseases: json['chronic_diseases'] ?? 'None',
      allergies: json['allergies'] ?? 'None',
      medicationNotes: json['medication_notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'age': age,
      'gender': gender,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'activity_level': activityLevel,
      'health_goals': healthGoals,
      'chronic_diseases': chronicDiseases,
      'allergies': allergies,
      'medication_notes': medicationNotes,
    };
  }
}
