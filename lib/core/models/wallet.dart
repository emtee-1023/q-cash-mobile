import '../format.dart';

class BusinessWallet {
  const BusinessWallet({
    required this.id,
    required this.businessId,
    required this.balanceMinor,
    required this.currency,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int businessId;
  final int balanceMinor;
  final String currency;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory BusinessWallet.fromJson(Map<String, dynamic> json) => BusinessWallet(
        id: toMinor(json['id']),
        businessId: toMinor(json['business_id']),
        balanceMinor: toMinor(json['balance_minor']),
        currency: json['currency']?.toString() ?? 'KES',
        createdAt: parseDateTime(json['created_at']),
        updatedAt: parseDateTime(json['updated_at']),
      );
}

class Withdrawal {
  const Withdrawal({
    required this.id,
    required this.businessId,
    required this.amountMinor,
    required this.currency,
    required this.recipientPhoneNumber,
    required this.status,
    required this.provider,
    this.providerReference,
    this.originatorConversationId,
    this.resultCode,
    this.resultDesc,
    this.failureReason,
    required this.requestedAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int businessId;
  final int amountMinor;
  final String currency;
  final String recipientPhoneNumber;
  final String status;
  final String provider;
  final String? providerReference;
  final String? originatorConversationId;
  final String? resultCode;
  final String? resultDesc;
  final String? failureReason;
  final DateTime requestedAt;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Withdrawal.fromJson(Map<String, dynamic> json) => Withdrawal(
        id: toMinor(json['id']),
        businessId: toMinor(json['business_id']),
        amountMinor: toMinor(json['amount_minor']),
        currency: json['currency']?.toString() ?? 'KES',
        recipientPhoneNumber: json['recipient_phone_number']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        provider: json['provider']?.toString() ?? '',
        providerReference: json['provider_reference']?.toString(),
        originatorConversationId: json['originator_conversation_id']?.toString(),
        resultCode: json['result_code']?.toString(),
        resultDesc: json['result_desc']?.toString(),
        failureReason: json['failure_reason']?.toString(),
        requestedAt: parseDateTime(json['requested_at']) ?? DateTime.now(),
        completedAt: parseDateTime(json['completed_at']),
        createdAt: parseDateTime(json['created_at']),
        updatedAt: parseDateTime(json['updated_at']),
      );
}
