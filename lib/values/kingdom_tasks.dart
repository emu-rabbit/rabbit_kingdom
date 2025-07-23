enum KingdomTaskNames {
  login, heart, comment
}

class KingdomTask {
  const KingdomTask();
}

const Map<KingdomTaskNames, KingdomTask> kingdomTasks = {
  KingdomTaskNames.login: KingdomTask(),
  KingdomTaskNames.heart: KingdomTask(),
  KingdomTaskNames.comment: KingdomTask(),
};