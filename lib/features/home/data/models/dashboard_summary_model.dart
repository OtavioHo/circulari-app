import '../../domain/entities/dashboard_summary.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.listCount,
    required super.itemCount,
    required super.totalValue,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      listCount: json['list_count'] as int,
      itemCount: json['item_count'] as int,
      totalValue: (json['total_value'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
