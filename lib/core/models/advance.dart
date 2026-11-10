import '../format.dart';

class Advance {
  const Advance({
    required this.id,
    required this.publicId,
    required this.offerId,
    required this.businessId,
    this.financingPartnerId,
    required this.principalAmountMinor,
    required this.feeAmountMinor,
    required this.totalRepayableMinor,
    required this.amountRepaidMinor,
    required this.outstandingBalanceMinor,
    required this.recoveryRateBps,
    required this.maximumRepaymentDays,
    this.approvedAt,
    this.disbursedAt,
    this.repaymentStartedAt,
    this.dueAt,
    this.settledAt,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String publicId;
  final int offerId;
  final int businessId;
  final int? financingPartnerId;
  final int principalAmountMinor;
  final int feeAmountMinor;
  final int totalRepayableMinor;
  final int amountRepaidMinor;
  final int outstandingBalanceMinor;
  final int recoveryRateBps;
  final int maximumRepaymentDays;
  final DateTime? approvedAt;
  final DateTime? disbursedAt;
  final DateTime? repaymentStartedAt;
  final DateTime? dueAt;
  final DateTime? settledAt;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Advance.fromJson(Map<String, dynamic> json) => Advance(
        id: toMinor(json['id']),
        publicId: json['public_id']?.toString() ?? '',
        offerId: toMinor(json['offer_id']),
        businessId: toMinor(json['business_id']),
        financingPartnerId: json['financing_partner_id'] == null ? null : toMinor(json['financing_partner_id']),
        principalAmountMinor: toMinor(json['principal_amount_minor']),
        feeAmountMinor: toMinor(json['fee_amount_minor']),
        totalRepayableMinor: toMinor(json['total_repayable_minor']),
        amountRepaidMinor: toMinor(json['amount_repaid_minor']),
        outstandingBalanceMinor: toMinor(json['outstanding_balance_minor']),
        recoveryRateBps: toMinor(json['recovery_rate_bps']),
        maximumRepaymentDays: toMinor(json['maximum_repayment_days']),
        approvedAt: parseDateTime(json['approved_at']),
        disbursedAt: parseDateTime(json['disbursed_at']),
        repaymentStartedAt: parseDateTime(json['repayment_started_at']),
        dueAt: parseDateTime(json['due_at']),
        settledAt: parseDateTime(json['settled_at']),
        status: json['status']?.toString() ?? '',
        createdAt: parseDateTime(json['created_at']),
        updatedAt: parseDateTime(json['updated_at']),
      );
}
