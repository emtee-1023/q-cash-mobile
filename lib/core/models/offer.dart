import '../format.dart';

class Offer {
  const Offer({
    required this.id,
    required this.publicId,
    required this.assessmentId,
    required this.businessId,
    required this.offeredAmountMinor,
    required this.feeAmountMinor,
    required this.totalRepayableMinor,
    required this.recoveryRateBps,
    required this.maximumRepaymentDays,
    this.offerTerms,
    required this.status,
    required this.offeredAt,
    this.expiresAt,
    this.acceptedAt,
    this.rejectedAt,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String publicId;
  final int assessmentId;
  final int businessId;
  final int offeredAmountMinor;
  final int feeAmountMinor;
  final int totalRepayableMinor;
  final int recoveryRateBps;
  final int maximumRepaymentDays;
  final List<dynamic>? offerTerms;
  final String status;
  final DateTime offeredAt;
  final DateTime? expiresAt;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Offer.fromJson(Map<String, dynamic> json) => Offer(
        id: toMinor(json['id']),
        publicId: json['public_id']?.toString() ?? '',
        assessmentId: toMinor(json['assessment_id']),
        businessId: toMinor(json['business_id']),
        offeredAmountMinor: toMinor(json['offered_amount_minor']),
        feeAmountMinor: toMinor(json['fee_amount_minor']),
        totalRepayableMinor: toMinor(json['total_repayable_minor']),
        recoveryRateBps: toMinor(json['recovery_rate_bps']),
        maximumRepaymentDays: toMinor(json['maximum_repayment_days']),
        offerTerms: json['offer_terms'] is List ? json['offer_terms'] as List : null,
        status: json['status']?.toString() ?? '',
        offeredAt: parseDateTime(json['offered_at']) ?? DateTime.now(),
        expiresAt: parseDateTime(json['expires_at']),
        acceptedAt: parseDateTime(json['accepted_at']),
        rejectedAt: parseDateTime(json['rejected_at']),
        createdAt: parseDateTime(json['created_at']),
        updatedAt: parseDateTime(json['updated_at']),
      );
}
