import 'package:rabbit_kingdom/values/kingdom_tasks.dart';

class AppConfig {
  final String defaultName;
  final int nameMaxLength;
  final int priceModifyName;
  final int priceDrink;
  final Map<KingdomTaskNames, KingdomTask> tasks;

  AppConfig._({
    required this.defaultName,
    required this.nameMaxLength,
    required this.priceModifyName,
    required this.priceDrink,
    required this.tasks
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig._(
      defaultName: (json['defaultName'] ?? "未命名") as String,
      nameMaxLength: (json['nameMaxLength'] ?? 10) as int,
      priceModifyName: (json['priceModifyName'] ?? 100) as int,
      priceDrink: (json['priceDrink'] ?? 75) as int,
      tasks: buildKingdomTasksFromJson(json['kingdomTasks'] ?? {})
    );
  }
}