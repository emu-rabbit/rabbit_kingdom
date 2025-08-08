import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/models/poop_prices.dart';

import '../helpers/collection_names.dart';

class PricesController extends GetxController {
  final _prices = Rxn<PoopPrices>();
  PoopPrices? get prices => _prices.value;
  Rxn<PoopPrices> get rxnPrices => _prices;

  StreamSubscription<QuerySnapshot>? _collectionListener;
  StreamSubscription<DocumentSnapshot>? _documentListener;

  Future<void> initPrices() async {
    _collectionListener?.cancel();
    _collectionListener = FirebaseFirestore.instance
        .collection(CollectionNames.prices)
        .orderBy('createAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final latestDoc = querySnapshot.docs.first;

        _prices.value = PoopPrices.fromJson(latestDoc.data());
        update();

        _documentListener?.cancel();
        _documentListener = latestDoc.reference.snapshots().listen((docSnapshot) {
          if (docSnapshot.exists) {
            _prices.value = PoopPrices.fromJson(docSnapshot.data());
            update();
          }
        });
      }
    });
  }

  void onLogout() {
    _collectionListener?.cancel();
    _documentListener?.cancel();
    _collectionListener = null;
    _documentListener = null;
    update();
  }

  @override
  void onClose() {
    onLogout();
    super.onClose();
  }
}
