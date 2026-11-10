import '../format.dart';

class Transaction {
  const Transaction({
    required this.id,
    required this.businessId,
    this.paymentAccountId,
    required this.provider,
    required this.providerTransactionId,
    this.transactionType,
    required this.direction,
    required this.amountMinor,
    required this.currency,
    required this.transactionTime,
    this.providerStatus,
    this.counterpartyReference,
    this.counterpartyName,
    this.ingestedAt,
    this.category,
    this.revenueEligible,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int businessId;
  final int? paymentAccountId;
  final String provider;
  final String providerTransactionId;
  final String? transactionType;
  final String direction; // inflow | outflow
  final int amountMinor;
  final String currency;
  final DateTime transactionTime;
  final String? providerStatus;
  final String? counterpartyReference;
  final String? counterpartyName;
  final DateTime? ingestedAt;
  final String? category;
  final bool? revenueEligible;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isInflow => direction == 'inflow';

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final classification = json['classification'];
    return Transaction(
      id: toMinor(json['id']),
      businessId: toMinor(json['business_id']),
      paymentAccountId: json['payment_account_id'] == null
          ? null
          : toMinor(json['payment_account_id']),
      provider: json['provider']?.toString() ?? '',
      providerTransactionId: json['provider_transaction_id']?.toString() ?? '',
      transactionType: json['transaction_type']?.toString(),
      direction: json['direction']?.toString() ?? '',
      amountMinor: toMinor(json['amount_minor']),
      currency: json['currency']?.toString() ?? 'KES',
      transactionTime: parseDateTime(json['transaction_time']) ?? DateTime.now(),
      providerStatus: json['provider_status']?.toString(),
      counterpartyReference: json['counterparty_reference']?.toString(),
      counterpartyName: json['counterparty_name']?.toString(),
      ingestedAt: parseDateTime(json['ingested_at']),
      category: classification is Map ? classification['category']?.toString() : null,
      revenueEligible: classification is Map ? classification['revenue_eligible'] as bool? : null,
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }
}
