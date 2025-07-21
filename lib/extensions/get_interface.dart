import 'package:flutter/material.dart';
import 'package:get/get.dart';

extension RPopupExtension on GetInterface {
  Future<T?>? rPopup<T>(Widget page) {
    return dialog(
      page,
      barrierColor: Colors.transparent,
      useSafeArea: false,
      transitionDuration: Duration(milliseconds: 150),
    );
  }
}