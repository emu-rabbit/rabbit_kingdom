import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/announce_controller.dart';
import 'package:rabbit_kingdom/models/kingdom_announcement.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/prices_controller.dart';
import '../models/poop_prices.dart';
import '../models/trading_news.dart';
import 'collection_names.dart';

abstract class AppDataCache<T> {
  T? _cacheData;
  AppDataCache({T? defaultValue}) {
    _cacheData = defaultValue;
  }

  Future<T> getData() async {
    if (_cacheData == null) {
      // 優先從永久儲存拉
      T? storedData = await _loadFromStorage();
      if (storedData != null) {
        _cacheData = storedData;
      }
    }

    if (_cacheData == null || await _isCacheExpire()) {
      // cache 是 null 或已過期，重新抓並存入
      T newData = await _fetchNewData();
      _cacheData = newData;
      await _saveToStorage(newData);
    }

    return _cacheData!;
  }

  /// 載入儲存資料：子類別需實作轉換
  Future<T?> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey());
    if (raw == null) return null;
    try {
      return decode(raw);
    } catch (_) {
      return null;
    }
  }

  /// 儲存資料：子類別需實作轉換
  Future<void> _saveToStorage(T data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey(), encode(data));
  }

  /// 每個子類要提供一個唯一的儲存 key
  String _storageKey();

  /// 子類別要實作的資料轉換器
  T decode(String raw);
  String encode(T data);

  /// 取得新資料
  Future<T> _fetchNewData();

  /// 判斷是否過期
  Future<bool> _isCacheExpire();
}

class RecentPricesCache extends AppDataCache<List<PoopPrices>> {
  RecentPricesCache() : super();

  @override
  String _storageKey() => 'recent_prices_cache';

  @override
  List<PoopPrices> decode(String raw) {
    final List decoded = jsonDecode(raw);
    // 模擬 Firestore 的 createAt 為 Timestamp（讓原本的 fromJson 能正確運作）
    return decoded.map((e) {
      final map = Map<String, dynamic>.from(e);
      final rawCreateAt = map['createAt'];
      if (rawCreateAt is String) {
        map['createAt'] = Timestamp.fromDate(DateTime.parse(rawCreateAt));
      }
      return PoopPrices.fromJson(map);
    }).toList();
  }

  @override
  String encode(List<PoopPrices> data) {
    final list = data.map((e) {
      final map = e.toJson();
      final createAt = map['createAt'];
      if (createAt is DateTime) {
        map['createAt'] = createAt.toIso8601String(); // 儲存時轉成字串
      }
      return map;
    }).toList();
    return jsonEncode(list);
  }

  @override
  Future<bool> _isCacheExpire() async {
    final pricesController = Get.find<PricesController>();
    final latestFromController = pricesController.prices;
    final latestFromCache = _cacheData?.firstOrNull;

    if (latestFromController == null || latestFromCache == null) return true;

    return latestFromController.createAt != latestFromCache.createAt;
  }

  @override
  Future<List<PoopPrices>> _fetchNewData() async {
    final currentCache = _cacheData ?? [];

    DateTime? lastTime = currentCache.isNotEmpty
        ? currentCache.first.createAt
        : null;

    // 用 lastTime 作為起點抓取新資料
    final List<PoopPrices> newData = await fetchPoopPricesAfter(
      after: lastTime,
      limit: 20,
    );

    // 合併並保留最新 20 筆
    final combined = [...newData, ...currentCache];
    final deduped = {
      for (var p in combined) p.createAt.toIso8601String(): p
    }.values.toList();

    deduped.sort((a, b) => b.createAt.compareTo(a.createAt));
    return deduped.take(20).toList();
  }

  /// 假設你有這個 async 方法可以抓資料
  Future<List<PoopPrices>> fetchPoopPricesAfter({
    required DateTime? after,
    int limit = 20,
  }) async {
    Query query = FirebaseFirestore.instance
        .collection(CollectionNames.prices)
        .orderBy('createAt', descending: true)
        .limit(limit);

    if (after != null) {
      query = query.where('createAt', isGreaterThan: Timestamp.fromDate(after));
    }

    final result = await query.get();

    return result.docs
        .map((doc) => PoopPrices.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}


class RecentAnnouncesCache extends AppDataCache<List<KingdomAnnouncement>> {
  RecentAnnouncesCache() : super();

  @override
  String _storageKey() => 'recent_announce_cache';

  @override
  List<KingdomAnnouncement> decode(String raw) {
    final List rawList = jsonDecode(raw);
    return rawList.map((e) => KingdomAnnouncement.decode(jsonEncode(e))).toList();
  }

  @override
  String encode(List<KingdomAnnouncement> data) {
    return jsonEncode(data.map((e) => jsonDecode(e.encode())).toList());
  }

  @override
  Future<bool> _isCacheExpire() async {
    final announceController = Get.find<AnnounceController>();
    final latestFromController = announceController.announcement;
    final latestFromCache = _cacheData?.firstOrNull;

    if (latestFromController == null || latestFromCache == null) return true;

    return latestFromController.createAt != latestFromCache.createAt;
  }

  @override
  Future<List<KingdomAnnouncement>> _fetchNewData() async {
    final currentCache = _cacheData ?? [];

    DateTime? lastTime = currentCache.isNotEmpty
        ? currentCache.first.createAt
        : null;

    // 用 lastTime 作為起點抓取新資料
    final List<KingdomAnnouncement> newData = await fetchAnnouncesAfter(
      after: lastTime,
      limit: 11,
    );

    // 合併並保留最新 11 筆
    final combined = [...newData, ...currentCache];
    final deduped = {
      for (var p in combined) p.createAt.toIso8601String(): p
    }.values.toList();

    deduped.sort((a, b) => b.createAt.compareTo(a.createAt));
    return deduped.take(11).toList();
  }

  /// 假設你有這個 async 方法可以抓資料
  Future<List<KingdomAnnouncement>> fetchAnnouncesAfter({
    required DateTime? after,
    int limit = 20,
  }) async {
    Query query = FirebaseFirestore.instance
        .collection(CollectionNames.announce)
        .orderBy('createAt', descending: true)
        .limit(limit);

    if (after != null) {
      query = query.where('createAt', isGreaterThan: Timestamp.fromDate(after));
    }

    final result = await query.get();

    return result.docs
        .map((doc) => KingdomAnnouncement.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
