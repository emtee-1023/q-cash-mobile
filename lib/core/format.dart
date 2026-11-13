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

/// Formats a date as `dd/mm/yyyy`, e.g. `03/11/2008`.
String formatDmy(DateTime? dt) {
  if (dt == null) return '—';
  final d = dt.toLocal();
  return '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year.toString().padLeft(4, '0')}';
}

DateTime? parseDateTime(dynamic value) =>
    value == null ? null : DateTime.tryParse(value.toString());

int toMinor(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return (num.tryParse(value.toString()) ?? 0).round();
}

/// Normalizes a Kenyan phone number entered as `07XXXXXXXX` (or `01XX…`,
/// `+2547…`, `2547…`) into canonical `+254XXXXXXXXX` form, or returns `null`
/// when the input cannot be recognised as a valid number.
String? normalizeKenyanPhone(String input) {
  var v = input.trim().replaceAll(RegExp(r'[\s\-().]'), '');
  if (v.isEmpty) return null;
  if (v.startsWith('0') && v.length == 10) {
    v = '+254${v.substring(1)}';
  } else if (v.startsWith('254') && v.length == 12) {
    v = '+$v';
  } else if (v.startsWith('7') && v.length == 9) {
    v = '+254$v';
  } else if (v.startsWith('+254') && v.length == 13) {
    // already canonical
  } else if (v.startsWith('+') && v.length > 13) {
    // allow foreign numbers through as-is
  } else {
    return null;
  }
  if (v.startsWith('+254') && v.length != 13) return null;
  return v;
}

/// Formats a canonical `+254XXXXXXXXX` number for display, e.g.
/// `+254 712 345 678`.
String formatKenyanPhone(String? phone) {
  if (phone == null || phone.isEmpty) return '—';
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('254') && digits.length == 12) {
    return '+254 ${digits.substring(3, 6)} ${digits.substring(6, 9)} '
        '${digits.substring(9)}';
  }
  return phone;
}

/// Normalises any Kenyan phone input (`07xx…`, `+254…`, `254…`) to the
/// MSISDN form expected by M-Pesa APIs: `254XXXXXXXXX` (no leading `+`).
String? toKenyanMsisdn(String input) {
  final normalized = normalizeKenyanPhone(input);
  if (normalized == null) return null;
  return normalized.replaceFirst('+', '');
}

/// Formats basis points into a percentage string, e.g. `1500` -> `15%`.
String formatBps(int? bps) {
  if (bps == null) return '—';
  final value = bps / 100;
  return value == value.roundToDouble()
      ? '${value.round()}%'
      : '${value.toStringAsFixed(2)}%';
}
