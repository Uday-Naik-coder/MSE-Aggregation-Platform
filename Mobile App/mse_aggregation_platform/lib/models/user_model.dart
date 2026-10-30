class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? businessName;
  final String? registrationId;
  final bool isApproved;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.businessName,
    this.registrationId,
    required this.isApproved,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isMse   => role == 'mse';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:             json['_id']?.toString() ?? json['id']?.toString() ?? '',
      email:          json['email'] as String? ?? '',
      name:           json['name']  as String? ?? '',
      role:           json['role']  as String? ?? '',
      businessName:   json['businessName'] as String?,
      registrationId: json['registrationId'] as String?,
      isApproved:     json['isApproved'] as bool? ?? false,
      createdAt:      json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role,
    'businessName': businessName,
    'registrationId': registrationId,
    'isApproved': isApproved,
    'createdAt': createdAt.toIso8601String(),
  };

  UserModel copyWith({
    String? id, String? email, String? name, String? role,
    String? businessName, String? registrationId,
    bool? isApproved, DateTime? createdAt,
  }) => UserModel(
    id:             id             ?? this.id,
    email:          email          ?? this.email,
    name:           name           ?? this.name,
    role:           role           ?? this.role,
    businessName:   businessName   ?? this.businessName,
    registrationId: registrationId ?? this.registrationId,
    isApproved:     isApproved     ?? this.isApproved,
    createdAt:      createdAt      ?? this.createdAt,
  );
}
