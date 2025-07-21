import 'dart:math';

import 'package:get/get.dart';

double vw(double percent) => Get.width * percent / 100;
double vh(double percent) => Get.height * percent / 100;
double vmin(double percent) => min(vw(percent), vh(percent));
double vmax(double percent) => max(vw(percent), vh(percent));
double mainImageSize() => vmin(75);