import '../format.dart';

class RepaymentAllocation {
  const RepaymentAllocation({
    required this.id,
    required this.repaymentCollectionId,
    required this.advanceId,
    required this.amountMinor,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int repaymentCollectionId;
  final int advanceId;
  final int amountMinor;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory RepaymentAllocation.fromJson(Map<String, dynamic> json) =>
      RepaymentAllocation(
        id: toMinor(json['id']),
        repaymentCollectionId: toMinor(json['repayment_collection_id']),
        advanceId: toMinor(json['advance_id']),
        amountMinor: toMinor(json['amount_minor']),
        createdAt: parseDateTime(json['created_at']),
        updatedAt: parseDateTime(json['updated_at']),
      );
}

class RepaymentCollection {
  const RepaymentCollection({
    required this.id,
    required this.publicId,
    required this.businessId,
    this.sourceTransactionId,
    required this.collectionMethod,
    this.provider,
    this.providerReference,
    required this.amountMinor,
    required this.currency,
    required this.status,
    required this.idempotencyKey,
    this.collectedAt,
    this.processedAt,
    this.allocations = const [],
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String publicId;
  final int businessId;
  final int? sourceTransactionId;
  final String collectionMethod;
  final String? provider;
  final String? providerReference;
  final int amountMinor;
  final String currency;
  final String status;
  final String idempotencyKey;
  final DateTime? collectedAt;
  final DateTime? processedAt;
  final List<RepaymentAllocation> allocations;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory RepaymentCollection.fromJson(Map<String, dynamic> json) =>
      RepaymentCollection(
        id: toMinor(json['id']),
        publicId: json['public_id']?.toString() ?? '',
        businessId: toMinor(json['business_id']),
        sourceTransactionId: json['source_transaction_id'] == null ? null : toMinor(json['source_transaction_id']),
        collectionMethod: json['collection_method']?.toString() ?? '',
        provider: json['provider']?.toString(),
        providerReference: json['provider_reference']?.toString(),
        amountMinor: toMinor(json['amount_minor']),
        currency: json['currency']?.toString() ?? 'KES',
        status: json['status']?.toString() ?? '',
        idempotencyKey: json['idempotency_key']?.toString() ?? '',
        collectedAt: parseDateTime(json['collected_at']),
        processedAt: parseDateTime(json['processed_at']),
        allocations: json['allocations'] is List
            ? (json['allocations'] as List)
                .map((e) => RepaymentAllocation.fromJson(e as Map<String, dynamic>))
                .toList()
            : const [],
        createdAt: parseDateTime(json['created_at']),
        updatedAt: parseDateTime(json['updated_at']),
      );
}
