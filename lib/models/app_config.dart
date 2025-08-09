import 'package:rabbit_kingdom/values/kingdom_tasks.dart';

class AppConfig {
  final String defaultName;
  final int nameMaxLength;
  final int priceModifyName;
  final int priceDrink;
  final int priceSimplePray;
  final int priceAdvancePray;
  final Map<KingdomTaskNames, KingdomTask> tasks;

  AppConfig._({
    required this.defaultName,
    required this.nameMaxLength,
    required this.priceModifyName,
    required this.priceDrink,
    required this.priceSimplePray,
    required this.priceAdvancePray,
    required this.tasks
  });

  static final defaultConfig = AppConfig._(
    defaultName: "未命名",
    nameMaxLength: 10,
    priceModifyName: 100,
    priceDrink: 75,
    priceSimplePray: 50,
    priceAdvancePray: 1,
    tasks: {}
  );

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig._(
      defaultName: (json['defaultName'] ?? "未命名") as String,
      nameMaxLength: (json['nameMaxLength'] ?? 10) as int,
      priceModifyName: (json['priceModifyName'] ?? 100) as int,
      priceDrink: (json['priceDrink'] ?? 75) as int,
      priceSimplePray: (json['priceSimplePray'] ?? 50) as int,
      priceAdvancePray: (json['priceAdvancePray'] ?? 1) as int,
      tasks: buildKingdomTasksFromJson(json['kingdomTasks'] ?? {})
    );
  }
}