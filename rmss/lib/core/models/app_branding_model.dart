class AppBrandingModel {
  final String appName;
  final String appLogoUrl;
  final String brandColorHex;

  const AppBrandingModel({
    required this.appName,
    required this.appLogoUrl,
    this.brandColorHex = '#E88328', // Default to current primary Orange
  });

  factory AppBrandingModel.fromJson(Map<String, dynamic> json) {
    return AppBrandingModel(
      appName: json['appName'] ?? 'Crown Restaurant',
      appLogoUrl: json['appLogoUrl'] ?? '',
      brandColorHex: json['brandColorHex'] ?? '#E88328',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'appLogoUrl': appLogoUrl,
      'brandColorHex': brandColorHex,
    };
  }
}
