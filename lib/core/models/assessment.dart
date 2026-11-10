import '../format.dart';

class Assessment {
  const Assessment({
    required this.id,
    required this.publicId,
    required this.businessId,
    this.modelVersionId,
    this.decisionPolicyId,
    required this.assessmentStatus,
    required this.assessmentDate,
    required this.forecastPeriodDays,
    this.predictedRevenueMinor,
    this.reliabilityScore,
    this.recommendedAdvanceRateBps,
    this.recommendedAdvanceAmountMinor,
    this.recommendedRecoveryRateBps,
    this.maximumRepaymentDays,
    this.scoreBreakdown,
    this.reasonCodes,
    this.warnings,
    this.requestedByUserId,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String publicId;
  final int businessId;
  final int? modelVersionId;
  final int? decisionPolicyId;
  final String assessmentStatus;
  final DateTime assessmentDate;
  final int forecastPeriodDays;
  final int? predictedRevenueMinor;
  final String? reliabilityScore;
  final int? recommendedAdvanceRateBps;
  final int? recommendedAdvanceAmountMinor;
  final int? recommendedRecoveryRateBps;
  final int? maximumRepaymentDays;
  final List<dynamic>? scoreBreakdown;
  final List<dynamic>? reasonCodes;
  final List<dynamic>? warnings;
  final int? requestedByUserId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Assessment.fromJson(Map<String, dynamic> json) => Assessment(
        id: toMinor(json['id']),
        publicId: json['public_id']?.toString() ?? '',
        businessId: toMinor(json['business_id']),
        modelVersionId: json['model_version_id'] == null ? null : toMinor(json['model_version_id']),
        decisionPolicyId: json['decision_policy_id'] == null ? null : toMinor(json['decision_policy_id']),
        assessmentStatus: json['assessment_status']?.toString() ?? '',
        assessmentDate: parseDateTime(json['assessment_date']) ?? DateTime.now(),
        forecastPeriodDays: toMinor(json['forecast_period_days']),
        predictedRevenueMinor: json['predicted_revenue_minor'] == null ? null : toMinor(json['predicted_revenue_minor']),
        reliabilityScore: json['reliability_score']?.toString(),
        recommendedAdvanceRateBps: json['recommended_advance_rate_bps'] == null ? null : toMinor(json['recommended_advance_rate_bps']),
        recommendedAdvanceAmountMinor: json['recommended_advance_amount_minor'] == null ? null : toMinor(json['recommended_advance_amount_minor']),
        recommendedRecoveryRateBps: json['recommended_recovery_rate_bps'] == null ? null : toMinor(json['recommended_recovery_rate_bps']),
        maximumRepaymentDays: json['maximum_repayment_days'] == null ? null : toMinor(json['maximum_repayment_days']),
        scoreBreakdown: json['score_breakdown'] is List ? json['score_breakdown'] as List : null,
        reasonCodes: json['reason_codes'] is List ? json['reason_codes'] as List : null,
        warnings: json['warnings'] is List ? json['warnings'] as List : null,
        requestedByUserId: json['requested_by_user_id'] == null ? null : toMinor(json['requested_by_user_id']),
        createdAt: parseDateTime(json['created_at']),
        updatedAt: parseDateTime(json['updated_at']),
      );
}
