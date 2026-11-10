import '../format.dart';

class Business {
  const Business({
    required this.id,
    required this.publicId,
    required this.businessName,
    this.businessType,
    this.businessCategory,
    this.registrationNumber,
    this.phoneNumber,
    this.email,
    this.county,
    this.town,
    this.physicalAddress,
    this.operatingSince,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String publicId;
  final String businessName;
  final String? businessType;
  final String? businessCategory;
  final String? registrationNumber;
  final String? phoneNumber;
  final String? email;
  final String? county;
  final String? town;
  final String? physicalAddress;
  final DateTime? operatingSince;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Business.fromJson(Map<String, dynamic> json) => Business(
        id: toMinor(json['id']),
        publicId: json['public_id']?.toString() ?? '',
        businessName: json['business_name']?.toString() ?? '',
        businessType: json['business_type']?.toString(),
        businessCategory: json['business_category']?.toString(),
        registrationNumber: json['registration_number']?.toString(),
        phoneNumber: json['phone_number']?.toString(),
        email: json['email']?.toString(),
        county: json['county']?.toString(),
        town: json['town']?.toString(),
        physicalAddress: json['physical_address']?.toString(),
        operatingSince: parseDateTime(json['operating_since']),
        status: json['status']?.toString() ?? '',
        createdAt: parseDateTime(json['created_at']),
        updatedAt: parseDateTime(json['updated_at']),
      );
}
