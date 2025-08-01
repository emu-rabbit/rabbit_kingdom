import '../helpers/dynamic.dart';

class TradingNews {
  final DateTime createAt;
  final int originalPrice;
  final int newPrice;
  final String title;
  final String content;
  final List<String> goods; // 贊成的 uid
  final List<String> bads;  // 反對的 uid

  TradingNews._({
    required this.createAt,
    required this.originalPrice,
    required this.newPrice,
    required this.title,
    required this.content,
    required this.goods,
    required this.bads,
  });

  /// 🔥 用於 Firestore 的 JSON 轉換
  factory TradingNews.fromJson(Map<String, dynamic>? json) {
    return TradingNews._(
      createAt: toDateTime(json?['createAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      originalPrice: json?['originalPrice'] ?? 0,
      newPrice: json?['newPrice'] ?? 0,
      title: json?['title'] ?? '',
      content: json?['content'] ?? '',
      goods: List<String>.from(json?['goods'] ?? []),
      bads: List<String>.from(json?['bads'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createAt': createAt,
      'originalPrice': originalPrice,
      'newPrice': newPrice,
      'title': title,
      'content': content,
      'goods': goods,
      'bads': bads,
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
      goods: const [],
      bads: const [],
    );
  }
}

class TradingNewsWithID extends TradingNews {
  final String id;

  TradingNewsWithID._({
    required this.id,
    required super.createAt,
    required super.originalPrice,
    required super.newPrice,
    required super.title,
    required super.content,
    required super.goods,
    required super.bads,
  }) : super._();

  factory TradingNewsWithID.create(String id, TradingNews news) {
    return TradingNewsWithID._(
      id: id,
      createAt: news.createAt,
      originalPrice: news.originalPrice,
      newPrice: news.newPrice,
      title: news.title,
      content: news.content,
      goods: news.goods,
      bads: news.bads,
    );
  }
}
