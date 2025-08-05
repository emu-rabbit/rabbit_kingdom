import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/announce_controller.dart';
import 'package:rabbit_kingdom/models/kingdom_announcement.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/prices_controller.dart';
import '../models/poop_prices.dart';
import '../values/kingdom_ranks.dart';
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

  /// 清除記憶體快取與永久儲存中的資料
  Future<void> clear() async {
    // 1. 取得 SharedPreferences 實例
    final prefs = await SharedPreferences.getInstance();

    // 2. 根據子類別提供的 key，移除永久儲存中的資料
    //    由於 SharedPreferences 的操作是異步的，這裡使用 await
    await prefs.remove(_storageKey());

    // 3. 將記憶體中的快取資料設為 null，立即釋放記憶體
    _cacheData = null;
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

class RankDataCache extends AppDataCache<CachedRankData> {
  final RankName rankName;
  final RankType rankType;

  RankDataCache({
    required this.rankName,
    required this.rankType,
  });

  @override
  String _storageKey() => 'rank_data_${rankName.name}_${rankType.name}_cache';

  @override
  CachedRankData decode(String raw) {
    final Map<String, dynamic> json = jsonDecode(raw);
    return CachedRankData.fromJson(json);
  }

  @override
  String encode(CachedRankData data) {
    final json = data.toJson();
    return jsonEncode(json);
  }

  @override
  Future<CachedRankData> _fetchNewData() async {
    final rank = kingdomRanks[rankName];
    final fetchedData = await rank!.getRank(rankType);

    // 建立 CachedRankData 物件，特別注意建立時間
    return CachedRankData(
      createAt: DateTime.now().toUtc(),
      data: fetchedData,
    );
  }

  @override
  Future<bool> _isCacheExpire() async {
    final storedData = _cacheData;
    if (storedData == null) {
      return true; // 快取為空，視為過期
    }

    // 1. 將所有時間點轉換為 UTC，建立統一的比較基準
    final nowUtc = DateTime.now().toUtc();
    final cacheCreationUtc = storedData.createAt.toUtc();

    // 2. 由於伺服器是根據「台北時間」(UTC+8) 更新，我們需要找出以 UTC 時間表示的「當前台北時間」
    final nowInTaipei = nowUtc.add(const Duration(hours: 8));

    // 3. 使用台北時間來計算最近一次的更新時間點（幾點鐘）
    final lastUpdateHourInTaipei = (nowInTaipei.hour ~/ 4) * 4;

    // 4. 建立代表「最近一次更新時間」的 UTC DateTime 物件
    final lastUpdateUtc = DateTime.utc(
      nowInTaipei.year,
      nowInTaipei.month,
      nowInTaipei.day,
      lastUpdateHourInTaipei,
    ).subtract(const Duration(hours: 8));

    // 5. 在 UTC 標準下，比較快取建立時間是否早于最近一次的更新時間
    return cacheCreationUtc.isBefore(lastUpdateUtc);
  }
}
