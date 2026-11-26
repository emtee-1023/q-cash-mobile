/// Access fee charged on the requested cash advance amount (2%).
const int qcashAccessFeeBps = 200;

/// Maximum repayment window for a new advance.
const int qcashMaxRepaymentDays = 30;

/// The fee in minor units, rounded half-up to match the API.
int accessFeeMinor(int requestedAmountMinor) =>
    (requestedAmountMinor * qcashAccessFeeBps / 10000).round();

/// Caps a recommended repayment window at the product maximum.
int cappedRepaymentDays(int? recommendedDays) {
  if (recommendedDays == null) return qcashMaxRepaymentDays;
  return recommendedDays > qcashMaxRepaymentDays
      ? qcashMaxRepaymentDays
      : recommendedDays;
}
