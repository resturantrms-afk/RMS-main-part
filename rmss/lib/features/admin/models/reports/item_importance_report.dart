enum ItemPerformanceStatus { highPerforming, underPerforming, normal }

class ItemImportanceReport {
  final String dishName;
  final String firstCategory;
  final int unitsSold;
  final double totalRevenue;
  final ItemPerformanceStatus status;

  ItemImportanceReport({
    required this.dishName,
    required this.firstCategory,
    required this.unitsSold,
    required this.totalRevenue,
    required this.status,
  });
}
