/// Formats an integer amount in KES minor units (cents) into a
/// human-readable KES string, e.g. `500000` -> `KES 5,000`.
String formatMinor(int minor) {
  final whole = (minor / 100).floor();
  final hasFraction = minor % 100 != 0;
  final base = hasFraction ? (minor / 100).toStringAsFixed(2) : whole.toString();
  return 'KES ${_withCommas(base)}';
}

/// Formats minor units without the "KES" prefix.
String formatMinorAmount(int minor) {
  final whole = (minor / 100).floor();
  final hasFraction = minor % 100 != 0;
  final base = hasFraction ? (minor / 100).toStringAsFixed(2) : whole.toString();
  return _withCommas(base);
}

String _withCommas(String value) {
  final parts = value.split('.');
  final intPart = parts[0];
  final buf = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
    buf.write(intPart[i]);
  }
  if (parts.length > 1) buf.write('.${parts[1]}');
  return buf.toString();
}

/// Formats an ISO-8601 timestamp into a short date string, e.g. `3 Sep 2026`.
String formatDate(DateTime? dt, {bool withTime = false}) {
  if (dt == null) return '—';
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final d = dt.toLocal();
  final date = '${d.day} ${months[d.month - 1]} ${d.year}';
  if (!withTime) return date;
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '$date, $hh:$mm';
}

DateTime? parseDateTime(dynamic value) =>
    value == null ? null : DateTime.tryParse(value.toString());

int toMinor(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return (num.tryParse(value.toString()) ?? 0).round();
}
