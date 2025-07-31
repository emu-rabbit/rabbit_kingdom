import 'package:rabbit_kingdom/helpers/dynamic.dart';

class TradingNews {
  final DateTime createAt;
  final int originalPrice;
  final int newPrice;
  final String title;
  final String content;

  TradingNews._({
    required this.createAt,
    required this.originalPrice,
    required this.newPrice,
    required this.title,
    required this.content,
  });

  /// 🔥 用於 Firestore 的 JSON 轉換
  factory TradingNews.fromJson(Map<String, dynamic>? json) {
    return TradingNews._(
      createAt: toDateTime(json?['createAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      originalPrice: json?['originalPrice'] ?? 0,
      newPrice: json?['newPrice'] ?? 0,
      title: json?['title'] ?? '',
      content: json?['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createAt': createAt,
      'originalPrice': originalPrice,
      'newPrice': newPrice,
      'title': title,
      'content': content,
    };
  }

  /// 🐰 兔兔大帝創建用
  factory TradingNews.create({
    required int originalPrice,
    required int newPrice,
    required String title,
    required String content,
  }) {
    return TradingNews._(
      createAt: DateTime.now(),
      originalPrice: originalPrice,
      newPrice: newPrice,
      title: title,
      content: content,
    );
  }
}
