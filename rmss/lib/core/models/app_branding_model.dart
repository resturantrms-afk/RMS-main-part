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
      appName: json['appName'] ?? 'Restaurant Management',
      appLogoUrl: json['appLogoUrl'] ?? 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
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
