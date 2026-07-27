class AppBrandingModel {
  final String appName;
  final String appLogoUrl;

  const AppBrandingModel({
    required this.appName,
    required this.appLogoUrl,
  });

  factory AppBrandingModel.fromJson(Map<String, dynamic> json) {
    return AppBrandingModel(
      appName: json['appName'] ?? 'Crown Restaurant',
      appLogoUrl: json['appLogoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'appLogoUrl': appLogoUrl,
    };
  }
}
