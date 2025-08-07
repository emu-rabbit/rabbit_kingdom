class AppConfig {
  final String defaultName;
  final int nameMaxLength;
  final int priceModifyName;
  final int priceDrink;

  AppConfig._({
    required this.defaultName,
    required this.nameMaxLength,
    required this.priceModifyName,
    required this.priceDrink
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig._(
      defaultName: (json['defaultName'] ?? "未命名") as String,
      nameMaxLength: (json['nameMaxLength'] ?? 10) as int,
      priceModifyName: (json['priceModifyName'] ?? 100) as int,
      priceDrink: (json['priceDrink'] ?? 75) as int
    );
  }
}