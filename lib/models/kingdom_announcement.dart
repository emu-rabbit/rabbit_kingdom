import 'dart:math';

import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/auth_controller.dart';
import 'package:rabbit_kingdom/controllers/user_controller.dart';
import 'package:rabbit_kingdom/helpers/dynamic.dart';

import 'kingdom_user.dart';

// 🧠 主資料結構
class KingdomAnnouncement {
  final int mood;
  final String message;
  final AnnounceSticker sticker;
  final int poopSell;
  final int poopBuy;
  final DateTime createAt;
  final List<AnnounceHeart> hearts;
  final List<AnnounceComment> comments;

  KingdomAnnouncement._({
    required this.mood,
    required this.message,
    required this.sticker,
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
      sticker: AnnounceSticker.fromString(data['sticker']),
      poopSell: data['poopSell'] ?? 0,
      poopBuy: data['poopBuy'] ?? 0,
      createAt: toDateTime(data['createAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      hearts: (data['hearts'] as List<dynamic>? ?? [])
          .map((c) => AnnounceHeart.fromJson(c))
          .toList(),
      comments: (data['comments'] as List<dynamic>? ?? [])
          .map((c) => AnnounceComment.fromJson(c))
          .toList(),
    );
  }

  factory KingdomAnnouncement.create({
    required int mood,
    required String message,
    required AnnounceSticker sticker
  }) {
    final price = PoopPrice.fromMood(mood);
    return KingdomAnnouncement._(
      mood: mood,
      message: message,
      sticker: sticker,
      poopSell: price.sellPrice,
      poopBuy: price.buyPrice,
      createAt: DateTime.now(),
      hearts: [],
      comments: []
    );
  }

  Map<String, dynamic> toJson() => {
    'mood': mood,
    'message': message,
    'sticker': sticker.name,
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

  factory AnnounceSticker.fromString(String? str) {
    return AnnounceSticker.values.firstWhere(
          (e) => e.name == (str ?? 'happy'),
      orElse: () => AnnounceSticker.happy,
    );
  }
}

class PoopPrice {
  final int buyPrice;
  final int sellPrice;

  PoopPrice(this.buyPrice, this.sellPrice);

  static PoopPrice fromMood(int mood) {
    int basePrice = (80 + (mood.clamp(0, 99) / 99.0) * 120).round(); // 80~200
    int fluctuation = [-5, -3, -2, -1, 0, 1, 2, 3, 5][Random().nextInt(9)];

    int mid = basePrice + fluctuation;
    int buy = mid - 3;
    int sell = buy + 6;

    return PoopPrice(buy, sell);
  }
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
      createAt: toDateTime(data['createAt']) ?? DateTime.fromMillisecondsSinceEpoch(0)
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
