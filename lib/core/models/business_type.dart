import '../format.dart';

class BusinessType {
  const BusinessType({
    required this.id,
    required this.name,
    required this.slug,
    required this.category,
    this.description,
    this.averageMonthlyRevenueMinor,
    required this.isActive,
  });

  final int id;
  final String name;
  final String slug;
  final String category;
  final String? description;
  final int? averageMonthlyRevenueMinor;
  final bool isActive;

  @override
  bool operator ==(Object other) => other is BusinessType && other.id == id;

  @override
  int get hashCode => id.hashCode;

  factory BusinessType.fromJson(Map<String, dynamic> json) => BusinessType(
        id: toMinor(json['id']),
        name: json['name']?.toString() ?? '',
        slug: json['slug']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        description: json['description']?.toString(),
        averageMonthlyRevenueMinor: json['average_monthly_revenue_minor'] == null
            ? null
            : toMinor(json['average_monthly_revenue_minor']),
        isActive: json['is_active'] == true,
      );
}
