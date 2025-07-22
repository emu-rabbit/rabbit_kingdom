import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/auth_controller.dart';
import 'package:rabbit_kingdom/controllers/user_controller.dart';
import 'package:rabbit_kingdom/extensions/dynamic.dart';

import 'kingdom_user.dart';

// 🧠 主資料結構
class KingdomAnnouncement {
  final int mood;
  final String message;
  final int poopSell;
  final int poopBuy;
  final DateTime createAt;
  final List<AnnounceHeart> hearts;
  final List<AnnounceComment> comments;

  KingdomAnnouncement._({
    required this.mood,
    required this.message,
    required this.poopSell,
    required this.poopBuy,
    required this.createAt,
    required this.hearts,
    required this.comments,
  });

  factory KingdomAnnouncement.fromJson(Map<String, dynamic> data) {
    return KingdomAnnouncement._(
      mood: data['mood'] ?? 0,
      message: data['message'] ?? '',
      poopSell: data['poopSell'] ?? 0,
      poopBuy: data['poopBuy'] ?? 0,
      createAt: data['createAt'].toDateTime() ?? DateTime.fromMillisecondsSinceEpoch(0),
      hearts: (data['hearts'] as List<dynamic>? ?? [])
          .map((c) => AnnounceHeart.fromJson(c))
          .toList(),
      comments: (data['comments'] as List<dynamic>? ?? [])
          .map((c) => AnnounceComment.fromJson(c))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'mood': mood,
    'message': message,
    'poopSell': poopSell,
    'poopBuy': poopBuy,
    'createAt': createAt, //  Firestore 會自動處理 DateTime -> Timestamp
    'hearts': hearts.map((h) => h.toJson()).toList(),
    'comments': comments.map((c) => c.toJson()).toList(),
  };
}

enum AnnounceSticker {
  happy, angry, sad, tired, excited, shy, cool;

  String get imagePath => "lib/assets/images/sticker_$name.png";
}

class AnnounceHeart {
  final String uid;
  final String name;

  AnnounceHeart._({
    required this.name,
    required this.uid
  });

  factory AnnounceHeart.fromJson(Map<String, dynamic> data) {
    return AnnounceHeart._(
      uid: data['uid'] ?? '',
      name: data['name'] ?? ''
    );
  }

  factory AnnounceHeart.create() {
    final authController = Get.find<AuthController>();
    final userController = Get.find<UserController>();

    return AnnounceHeart._(
      uid: authController.firebaseUser.value?.uid ?? "",
      name: userController.user?.name ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
  };
}

class AnnounceComment {
  final String uid;
  final String name;
  final KingdomUserGroup group;
  final String message;
  final DateTime createAt;

  AnnounceComment._({
    required this.uid,
    required this.name,
    required this.group,
    required this.message,
    required this.createAt
  });

  factory AnnounceComment.fromJson(Map<String, dynamic> data) {
    return AnnounceComment._(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      group: KingdomUserGroup.values.byName(data['group'] ?? 'unknown'),
      message: data['message'] ?? '',
      createAt: data['createAt'].toDateTime() ?? DateTime.fromMillisecondsSinceEpoch(0)
    );
  }

  factory AnnounceComment.create(String message) {
    final authController = Get.find<AuthController>();
    final userController = Get.find<UserController>();

    return AnnounceComment._(
      uid: authController.firebaseUser.value?.uid ?? "",
      name: userController.user?.name ?? "",
      group: userController.user?.group ?? KingdomUserGroup.unknown,
      message: message,
      createAt: DateTime.now()
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'group': group.name,
    'message': message,
    'createAt': createAt
  };
}
