import 'package:rabbit_kingdom/extensions/string.dart';

class KingdomUser {
  final String name;
  final KingdomUserGroup group;
  final KingdomUserExp exp;
  final KingdomUserBudget budget;

  KingdomUser._({
    required this.name,
    required this.group,
    required this.exp,
    required this.budget
  });

  factory KingdomUser.fromJson(Map<String, dynamic> json) {
    return KingdomUser._(
      name: json['name'] ?? '',
      group: KingdomUserGroup.fromString(json['group']),
      exp: KingdomUserExp.fromInt(json['exp']), 
      budget: KingdomUserBudget.fromJson(json['budget'])
    );
  }

  factory KingdomUser.newUser(String name) {
    return KingdomUser._(
      name: name,
      group: KingdomUserGroup.unknown,
      exp: KingdomUserExp.fromInt(0),
      budget: KingdomUserBudget.fromJson(null)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'group': group.name,
      'exp': exp.raw,
      'budget': budget.toJson()
    };
  }
}

enum KingdomUserGroup {
  empire, unknown;

  factory KingdomUserGroup.fromString(String? str) {
    return KingdomUserGroup.values.firstWhere(
          (e) => e.name == (str ?? 'unknown'),
      orElse: () => KingdomUserGroup.unknown,
    );
  }
}

class KingdomUserExp {
  int _raw;
  int get raw => _raw;
  int get level => _calculateLevel(raw);

  KingdomUserExp._(this._raw);

  KingdomUserExp add(int raw) {
    _raw += raw;
    return this;
  }

  int _calculateLevel(int exp) {
    int level = 0;
    int required = 100;
    int totalNeeded = 0;

    while (exp >= totalNeeded + required) {
      totalNeeded += required;
      required += 100; // 每級比前一級多 100
      level++;
    }

    return level + 1; // Lv.1 從 0 exp 開始
  }

  factory KingdomUserExp.fromInt(int? raw) {
    return KingdomUserExp._(raw ?? 0);
  }
}

class KingdomUserBudget {
  int coin;
  int poop;
  int get property => 0;
  String get propertyText => property.toRDisplayString();
  
  KingdomUserBudget._({ this.coin = 0, this.poop = 0 });
  
  factory KingdomUserBudget.fromJson(Map<String, dynamic>? json) {
    return KingdomUserBudget._(
      coin: json?['coin'] ?? 0,
      poop: json?['poop'] ?? 0
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'coin': coin,
      'poop': poop
    };
  }
}