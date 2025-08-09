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