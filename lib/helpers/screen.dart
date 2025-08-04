import 'dart:math';

import 'package:get/get.dart';

double vw(double percent) => Get.width * percent / 100;
double vh(double percent) => Get.height * percent / 100;
double vmin(double percent) => min(vw(percent), vh(percent));
double vmax(double percent) => max(vw(percent), vh(percent));
double mainImageSize() => vmin(75) * deviceFactor();
final double _rootWidth = 411.4285714;
double getFromDp(double dp) => vw(dp / _rootWidth * 100) * deviceFactor();
double deviceFactor() => (Get.context?.isTablet ?? false) ? 0.8 : 1;