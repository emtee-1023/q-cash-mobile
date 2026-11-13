import '../format.dart';

class PaymentAccount {
  const PaymentAccount({
    required this.id,
    required this.businessId,
    required this.provider,
    required this.channelType,
    this.accountReference,
    this.accountName,
    required this.status,
    this.verifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int businessId;
  final String provider;
  final String channelType;
  final String? accountReference;
  final String? accountName;
  final String status;
  final DateTime? verifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory PaymentAccount.fromJson(Map<String, dynamic> json) => PaymentAccount(
        id: toMinor(json['id']),
        businessId: toMinor(json['business_id']),
        provider: json['provider']?.toString() ?? '',
        channelType: json['channel_type']?.toString() ?? '',
        accountReference: json['account_reference']?.toString(),
        accountName: json['account_name']?.toString(),
        status: json['status']?.toString() ?? '',
        verifiedAt: parseDateTime(json['verified_at']),
        createdAt: parseDateTime(json['created_at']),
        updatedAt: parseDateTime(json['updated_at']),
      );
}
