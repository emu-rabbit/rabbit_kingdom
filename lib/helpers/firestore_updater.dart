import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class FirestoreUpdater {
  final Rxn<DocumentReference<Map<String, dynamic>>> docRef;
  final Duration delay;

  final Map<String, dynamic> _buffer = {};
  Timer? _debounce;

  final List<Completer<void>> _pendingCompleters = [];

  FirestoreUpdater({required this.docRef, this.delay = const Duration(milliseconds: 150)});

  /// 更新單一欄位
  Future<void> update(String field, dynamic value) {
    return updateJson({field: value});
  }

  /// 更新多個欄位
  Future<void> updateJson(Map<String, dynamic> data) {
    _buffer.addAll(data);

    final completer = Completer<void>();
    _pendingCompleters.add(completer);

    _debounce?.cancel();
    _debounce = Timer(delay, _flush);

    return completer.future;
  }

  Future<void> _flush() async {
    if (_buffer.isEmpty) return;

    final dataToWrite = Map<String, dynamic>.from(_buffer);
    _buffer.clear();

    final pending = List<Completer<void>>.from(_pendingCompleters);
    _pendingCompleters.clear();

    try {
      if (docRef.value == null) throw Exception("doc ref not exist");
      await docRef.value!.update(dataToWrite);
      for (final completer in pending) {
        if (!completer.isCompleted) completer.complete();
      }
      print("Wrote $dataToWrite");
    } catch (e) {
      for (final completer in pending) {
        if (!completer.isCompleted) completer.completeError(e);
      }
    }
  }

  void flushNow() {
    _debounce?.cancel();
    _flush();
  }
}
