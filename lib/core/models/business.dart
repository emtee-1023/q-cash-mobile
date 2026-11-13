import '../format.dart';
import 'business_type.dart';

class Business {
  const Business({
    required this.id,
    required this.publicId,
    required this.businessName,
    this.businessTypeId,
    this.businessType,
    this.businessCategory,
    this.registrationNumber,
    this.phoneNumber,
    this.email,
    this.hasPhysicalLocation = false,
    this.countyId,
    this.subCountyId,
    this.wardId,
    this.county,
    this.town,
    this.ward,
    this.physicalAddress,
    this.operatingSince,
    required this.status,
    this.kycStatus,
    this.collectionAccountNumber,
    this.walletBalanceMinor = 0,
    this.paybillNumber,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String publicId;
  final String businessName;
  final int? businessTypeId;
  final BusinessType? businessType;
  final String? businessCategory;
  final String? registrationNumber;
  final String? phoneNumber;
  final String? email;
  final bool hasPhysicalLocation;
  final int? countyId;
  final int? subCountyId;
  final int? wardId;
  final String? county;
  final String? town;
  final String? ward;
  final String? physicalAddress;
  final DateTime? operatingSince;
  final String status;
  final String? kycStatus;
  final String? collectionAccountNumber;
  final int walletBalanceMinor;
  final String? paybillNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String? get typeName => businessType?.name ?? businessCategory;

  factory Business.fromJson(Map<String, dynamic> json) {
    final typeJson = json['business_type'];
    return Business(
      id: toMinor(json['id']),
      publicId: json['public_id']?.toString() ?? '',
      businessName: json['business_name']?.toString() ?? '',
      businessTypeId: json['business_type_id'] == null
          ? null
          : toMinor(json['business_type_id']),
      businessType: typeJson is Map
          ? BusinessType.fromJson(typeJson as Map<String, dynamic>)
          : null,
      businessCategory: json['business_category']?.toString(),
      registrationNumber: json['registration_number']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      email: json['email']?.toString(),
      hasPhysicalLocation: json['has_physical_location'] == true,
      countyId: json['county_id'] == null ? null : toMinor(json['county_id']),
      subCountyId:
          json['sub_county_id'] == null ? null : toMinor(json['sub_county_id']),
      wardId: json['ward_id'] == null ? null : toMinor(json['ward_id']),
      county: json['county']?.toString(),
      town: json['town']?.toString(),
      ward: json['ward']?.toString(),
      physicalAddress: json['physical_address']?.toString(),
      operatingSince: parseDateTime(json['operating_since']),
      status: json['status']?.toString() ?? '',
      kycStatus: json['kyc_status']?.toString(),
      collectionAccountNumber: json['collection_account_number']?.toString(),
      walletBalanceMinor: toMinor(json['wallet_balance_minor']),
      paybillNumber: json['paybill_number']?.toString(),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }
}
