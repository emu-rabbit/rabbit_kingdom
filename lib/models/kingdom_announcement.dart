import 'kingdom_user.dart';

// 🧠 主資料結構
class KingdomAnnouncement {
  final int mood;
  final String message;
  final int poopSell;
  final int poopBuy;
  final List<AnnounceComment> comments;

  KingdomAnnouncement._({
    required this.mood,
    required this.message,
    required this.poopSell,
    required this.poopBuy,
    required this.comments,
  });

  factory KingdomAnnouncement.fromJson(Map<String, dynamic> data) {
    return KingdomAnnouncement._(
      mood: data['mood'] ?? 0,
      message: data['message'] ?? '',
      poopSell: data['poopSell'] ?? 0,
      poopBuy: data['poopBuy'] ?? 0,
      comments: (data['comments'] as List<dynamic>? ?? [])
          .map((c) => AnnounceComment.fromJson(c))
          .toList(),
    );
  }
}

class AnnounceComment {
  final String name;
  final KingdomUserGroup group;
  final String message;

  AnnounceComment._({
    required this.name,
    required this.group,
    required this.message,
  });

  factory AnnounceComment.fromJson(Map<String, dynamic> data) {
    return AnnounceComment._(
      name: data['name'] ?? '',
      group: KingdomUserGroup.values.byName(data['group'] ?? 'unknown'),
      message: data['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'group': group.name,
    'message': message,
  };
}
