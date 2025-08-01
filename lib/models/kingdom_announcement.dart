import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  final DateTime createAt;
  final List<AnnounceHeart> hearts;
  final List<AnnounceComment> comments;

  KingdomAnnouncement._({
    required this.mood,
    required this.message,
    required this.sticker,
    required this.createAt,
    required this.hearts,
    required this.comments,
  });

  factory KingdomAnnouncement.fromJson(Map<String, dynamic>? data) {
    return KingdomAnnouncement._(
      mood: data?['mood'] ?? 0,
      message: data?['message'] ?? '',
      sticker: AnnounceSticker.fromString(data?['sticker']),
      createAt: toDateTime(data?['createAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      hearts: (data?['hearts'] as List<dynamic>? ?? [])
          .map((c) => AnnounceHeart.fromJson(c))
          .toList(),
      comments: (data?['comments'] as List<dynamic>? ?? [])
          .map((c) => AnnounceComment.fromJson(c))
          .toList(),
    );
  }

  factory KingdomAnnouncement.create({
    required int mood,
    required String message,
    required AnnounceSticker sticker
  }) {
    return KingdomAnnouncement._(
      mood: mood,
      message: message,
      sticker: sticker,
      createAt: DateTime.now(),
      hearts: [],
      comments: []
    );
  }

  Map<String, dynamic> toJson() => {
    'mood': mood,
    'message': message,
    'sticker': sticker.name,
    'createAt': createAt, //  Firestore 會自動處理 DateTime -> Timestamp
    'hearts': hearts.map((h) => h.toJson()).toList(),
    'comments': comments.map((c) => c.toJson()).toList(),
  };

  /// 🆕 將這個物件編碼成 JSON 字串（for 儲存到本地）
  String encode() {
    final map = toJson();

    // 轉換 createAt 為 ISO 字串
    if (map['createAt'] is DateTime) {
      map['createAt'] = (map['createAt'] as DateTime).toIso8601String();
    }

    // 將 comments 裡每個物件轉成 encode 字串再 decode 成 Map
    map['comments'] = comments.map((c) => jsonDecode(c.encode())).toList();

    return jsonEncode(map);
  }

  /// 🆕 從 JSON 字串還原成 KingdomAnnouncement
  static KingdomAnnouncement decode(String raw) {
    final map = jsonDecode(raw);
    if (map is! Map<String, dynamic>) {
      throw FormatException('Invalid KingdomAnnouncement JSON');
    }

    // 轉換 createAt 為 Timestamp
    if (map['createAt'] is String) {
      map['createAt'] = Timestamp.fromDate(DateTime.parse(map['createAt']));
    }

    // 還原 comments
    map['comments'] = (map['comments'] as List<dynamic>? ?? []).map((e) {
      return AnnounceComment.decode(jsonEncode(e));
    }).toList();

    return KingdomAnnouncement.fromJson(map);
  }
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


  /// 🆕 將這個物件編碼成 JSON 字串（for 儲存到本地）
  String encode() {
    final map = toJson();
    if (map['createAt'] is DateTime) {
      map['createAt'] = (map['createAt'] as DateTime).toIso8601String();
    }
    return jsonEncode(map);
  }

  /// 🆕 從 JSON 字串還原成 KingdomAnnouncement
  static AnnounceComment decode(String raw) {
    final map = jsonDecode(raw);
    if (map is Map<String, dynamic>) {
      if (map['createAt'] is String) {
        map['createAt'] = Timestamp.fromDate(DateTime.parse(map['createAt']));
      }
      return AnnounceComment.fromJson(map);
    } else {
      throw FormatException('Invalid KingdomAnnouncement JSON');
    }
  }
}
