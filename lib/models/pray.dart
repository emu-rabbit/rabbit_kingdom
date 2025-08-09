enum RewardType {
  coin, poop, drink, exp, unknown
}

enum PrayType {
  simple, advance
}

class PrayReward {
  final RewardType type;
  final int amount;

  PrayReward._({
    required this.type,
    required this.amount
  });

  factory PrayReward.fromJson(Map<String, dynamic> json) {
    return PrayReward._(
      type: RewardType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => RewardType.unknown,
      ),
      amount: json['amount'] is int
          ? json['amount'] as int
          : int.tryParse(json['amount'].toString()) ?? 0,
    );
  }

  String getImagePath() {
    return switch(type) {
      RewardType.coin => "lib/assets/images/rabbit_coin.png",
      RewardType.poop => "lib/assets/images/empire_poop.png",
      RewardType.drink => "lib/assets/images/drink_ticket.png",
      RewardType.exp => "lib/assets/images/exp.png",
      RewardType.unknown => "lib/assets/images/unknown.png",
    };
  }

  String toDisplayString() {
    String name = switch(type) {
      RewardType.coin => "兔兔幣",
      RewardType.poop => "兔兔精華",
      RewardType.drink => "喝酒券",
      RewardType.exp => "經驗值",
      RewardType.unknown => "未知",
    };
    return "$name+$amount";
  }
}

class PendingPrayRewards {
  final PrayReward rewardA;
  final PrayReward rewardB;

  PendingPrayRewards._({
    required this.rewardA,
    required this.rewardB,
  });

  factory PendingPrayRewards.fromJson(Map<String, dynamic> json) {
    return PendingPrayRewards._(
      rewardA: PrayReward.fromJson(json['rewardA'] as Map<String, dynamic>),
      rewardB: PrayReward.fromJson(json['rewardB'] as Map<String, dynamic>),
    );
  }
}