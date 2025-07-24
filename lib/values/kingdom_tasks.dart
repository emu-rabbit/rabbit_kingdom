enum KingdomTaskNames {
  login, heart, comment
}

class KingdomTask {
  final String text;
  final int limit;
  final int coinReward;
  final int expReward;
  const KingdomTask(this.text, { required this.limit, required this.coinReward, required this.expReward });
}

const Map<KingdomTaskNames, KingdomTask> kingdomTasks = {
  KingdomTaskNames.login: KingdomTask(
    "入境兔兔王國",
    limit: 1,
    coinReward: 150,
    expReward: 150
  ),
  KingdomTaskNames.heart: KingdomTask(
    "點擊公告愛心",
    limit: 1,
    coinReward: 100,
    expReward: 100
  ),
  KingdomTaskNames.comment: KingdomTask(
    "在公告上留言",
    limit: 1,
    coinReward: 200,
    expReward: 200
  ),
};