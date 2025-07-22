import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/auth_controller.dart';
import 'package:rabbit_kingdom/controllers/user_controller.dart';

import 'kingdom_user.dart';

// 🧠 主資料結構
class KingdomAnnouncement {
  final int mood;
  final String message;
  final int poopSell;
  final int poopBuy;
  final List<AnnounceHeart> hearts;
  final List<AnnounceComment> comments;

  KingdomAnnouncement._({
    required this.mood,
    required this.message,
    required this.poopSell,
    required this.poopBuy,
    required this.hearts,
    required this.comments,
  });

  factory KingdomAnnouncement.fromJson(Map<String, dynamic> data) {
    return KingdomAnnouncement._(
      mood: data['mood'] ?? 0,
      message: data['message'] ?? '',
      poopSell: data['poopSell'] ?? 0,
      poopBuy: data['poopBuy'] ?? 0,
      hearts: (data['hearts'] as List<dynamic>? ?? [])
          .map((c) => AnnounceHeart.fromJson(c))
          .toList(),
      comments: (data['comments'] as List<dynamic>? ?? [])
          .map((c) => AnnounceComment.fromJson(c))
          .toList(),
    );
  }
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
}

class AnnounceComment {
  final String uid;
  final String name;
  final KingdomUserGroup group;
  final String message;

  AnnounceComment._({
    required this.uid,
    required this.name,
    required this.group,
    required this.message,
  });

  factory AnnounceComment.fromJson(Map<String, dynamic> data) {
    return AnnounceComment._(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      group: KingdomUserGroup.values.byName(data['group'] ?? 'unknown'),
      message: data['message'] ?? '',
    );
  }

  factory AnnounceComment.create(String message) {
    final authController = Get.find<AuthController>();
    final userController = Get.find<UserController>();

    return AnnounceComment._(
      uid: authController.firebaseUser.value?.uid ?? "",
      name: userController.user?.name ?? "",
      group: userController.user?.group ?? KingdomUserGroup.unknown,
      message: message
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'group': group.name,
    'message': message,
  };
}
