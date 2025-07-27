typedef KingdomRecords = Map<RecordName, Map<RecordRound, RankRecord>>;

KingdomRecords kingdomRecordsFromJson(Map<String, dynamic>? json) {
  if (json == null) return {};

  final result = <RecordName, Map<RecordRound, RankRecord>>{};

  for (final entry in json.entries) {
    final recordName = RecordName.values.firstWhere(
          (e) => e.name == entry.key,
      orElse: () => throw FormatException('Unknown RecordName: ${entry.key}'),
    );

    final roundMap = <RecordRound, RankRecord>{};
    final roundJson = entry.value as Map<String, dynamic>;

    for (final roundEntry in roundJson.entries) {
      final round = RecordRound.fromKey(roundEntry.key);
      final record = RankRecord.fromJson(roundEntry.value);
      roundMap[round] = record;
    }
    result[recordName] = roundMap;
  }
  return result;
}

enum RecordName {
  coin, poop, exp, drink
}
abstract class RecordRound {
  String toKey();
  factory RecordRound.fromKey(String key) {
    try {
      if (key == "all") {
        return AllRound();
      }
      final match = RegExp(r'^(\d{4})-(\d{1,2})$').firstMatch(key);
      if (match != null) {
        return MonthlyRound.fromKey(key);
      }
      return UnknownRound();
    } catch(e) {
      return UnknownRound();
    }
  }
}
class AllRound implements RecordRound {
  @override
  String toKey() {
    return 'all';
  }

  @override
  bool operator ==(Object other) => other is AllRound;

  @override
  int get hashCode => toKey().hashCode;
}
class MonthlyRound implements RecordRound {
  final int year;
  final int month;
  MonthlyRound._({ required this.year, required this.month });

  @override
  String toKey() {
    return "$year-${month.toString().padLeft(2, '0')}";
  }

  factory MonthlyRound.now() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 8)); // 台灣時間
    final isBeforeCutoff = now.day == 1 && now.hour < 8;

    final year = isBeforeCutoff
        ? (now.month == 1 ? now.year - 1 : now.year)
        : now.year;

    final month = isBeforeCutoff
        ? (now.month == 1 ? 12 : now.month - 1)
        : now.month;

    return MonthlyRound._(year: year, month: month);
  }

  factory MonthlyRound.fromKey(String key) {
    final match = RegExp(r'^(\d{4})-(\d{1,2})$').firstMatch(key);
    if (match == null) {
      throw FormatException("Invalid MonthlyRound key format: $key");
    }

    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    if (month < 1 || month > 12) {
      throw FormatException("Invalid month in key: $month");
    }

    return MonthlyRound._(year: year, month: month);
  }

  @override
  bool operator ==(Object other) =>
      other is MonthlyRound &&
          other.year == year &&
          other.month == month;

  @override
  int get hashCode => Object.hash(year, month);
}
class UnknownRound implements RecordRound {
  @override
  String toKey() {
    return 'unknown';
  }

  @override
  bool operator ==(Object other) => other is UnknownRound;

  @override
  int get hashCode => toKey().hashCode;
}

class RankRecord {
  final double value;
  RankRecord._({ required this.value });

  factory RankRecord.fromJson(Map<String, dynamic>? json) {
    return RankRecord._(value: json?['value'] ?? 0);
  }
}