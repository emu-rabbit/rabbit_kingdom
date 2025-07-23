enum KingdomTaskNames {
  login, heart, comment
}

class KingdomTask {
  final int limit;
  const KingdomTask(this.limit);
}

const Map<KingdomTaskNames, KingdomTask> kingdomTasks = {
  KingdomTaskNames.login: KingdomTask(1),
  KingdomTaskNames.heart: KingdomTask(1),
  KingdomTaskNames.comment: KingdomTask(3),
};