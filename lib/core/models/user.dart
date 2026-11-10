import '../format.dart';

class User {
  const User({
    required this.id,
    required this.name,
    this.email,
    this.emailVerifiedAt,
    this.phoneNumber,
    this.phoneVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String name;
  final String? email;
  final DateTime? emailVerifiedAt;
  final String? phoneNumber;
  final DateTime? phoneVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: toMinor(json['id']),
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString(),
        emailVerifiedAt: parseDateTime(json['email_verified_at']),
        phoneNumber: json['phone_number']?.toString(),
        phoneVerifiedAt: parseDateTime(json['phone_verified_at']),
        createdAt: parseDateTime(json['created_at']),
        updatedAt: parseDateTime(json['updated_at']),
      );
}
