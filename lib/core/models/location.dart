import '../format.dart';

class County {
  const County({
    required this.id,
    required this.code,
    required this.name,
    required this.slug,
    this.capital,
    this.region,
    this.isoCode,
    this.postalCode,
  });

  final int id;
  final String code;
  final String name;
  final String slug;
  final String? capital;
  final String? region;
  final String? isoCode;
  final String? postalCode;

  @override
  bool operator ==(Object other) => other is County && other.id == id;

  @override
  int get hashCode => id.hashCode;

  factory County.fromJson(Map<String, dynamic> json) => County(
        id: toMinor(json['id']),
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        slug: json['slug']?.toString() ?? '',
        capital: json['capital']?.toString(),
        region: json['region']?.toString(),
        isoCode: json['iso_code']?.toString(),
        postalCode: json['postal_code']?.toString(),
      );
}

class SubCounty {
  const SubCounty({
    required this.id,
    required this.countyId,
    required this.code,
    required this.name,
    required this.slug,
  });

  final int id;
  final int countyId;
  final String code;
  final String name;
  final String slug;

  @override
  bool operator ==(Object other) => other is SubCounty && other.id == id;

  @override
  int get hashCode => id.hashCode;

  factory SubCounty.fromJson(Map<String, dynamic> json) => SubCounty(
        id: toMinor(json['id']),
        countyId: toMinor(json['county_id']),
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        slug: json['slug']?.toString() ?? '',
      );
}

class Ward {
  const Ward({
    required this.id,
    required this.subCountyId,
    required this.code,
    required this.name,
    required this.slug,
  });

  final int id;
  final int subCountyId;
  final String code;
  final String name;
  final String slug;

  @override
  bool operator ==(Object other) => other is Ward && other.id == id;

  @override
  int get hashCode => id.hashCode;

  factory Ward.fromJson(Map<String, dynamic> json) => Ward(
        id: toMinor(json['id']),
        subCountyId: toMinor(json['sub_county_id']),
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        slug: json['slug']?.toString() ?? '',
      );
}
