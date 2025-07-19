enum KingdomUserGroup { empire, unknown }

class KingdomUser {
  final String name;
  final KingdomUserGroup group;

  KingdomUser({
    required this.name,
    this.group = KingdomUserGroup.unknown,
  });

  factory KingdomUser.fromJson(Map<String, dynamic> json) {
    return KingdomUser(
      name: json['name'] ?? '',
      group: KingdomUserGroup.values.firstWhere(
            (e) => e.name == (json['group'] ?? 'unknown'),
        orElse: () => KingdomUserGroup.unknown,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'group': group.name,
    };
  }
}
