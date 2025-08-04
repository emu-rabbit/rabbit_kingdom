import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/models/kingdom_user.dart';
import 'package:rabbit_kingdom/values/consts.dart';

import '../controllers/user_controller.dart';

class RBlurredOverlay extends StatefulWidget {
  const RBlurredOverlay({super.key});

  @override
  State<RBlurredOverlay> createState() => _RBlurredOverlayState();
}

class _RBlurredOverlayState extends State<RBlurredOverlay>
    with TickerProviderStateMixin { // 保持使用 TickerProviderStateMixin

  late AnimationController _controller;
  late Animation<double> _blurAnimation;
  Timer? _timer;
  late UserController _userController; // 儲存控制器的參考
  VoidCallback? _userListener; // 用於儲存監聽器的 dispose 回呼函式

  // 動畫參數（預設值）
  double _blurBegin = 0;
  double _blurEnd = 0;
  Duration _duration = const Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    _userController = Get.find<UserController>(); // 一次性取得控制器

    _initAnimation();
    _startTimer();

    // 關鍵修復：在 initState 中監聽 userController.user 的變化。
    // 當 userController.user 的值改變時，這個回呼函式會被觸發，
    // 進而更新動畫參數並呼叫 setState。
    _userListener = ever(_userController.userRx, (KingdomUser? newUser) {
      _updateAnimationFromUser(newUser);
    }).call;

    // 根據使用者資料進行初始更新，確保小部件首次建構時動畫參數是正確的。
    _updateAnimationFromUser(_userController.userRx.value); // 使用 .value 取得 Rx 的值
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _userListener?.call(); // 釋放 `ever` 監聽器，避免記憶體洩漏
    super.dispose();
  }

  void _initAnimation() {
    // 只在 initState 中初始化控制器一次。
    _controller = AnimationController(
      vsync: this,
      duration: _duration, // 初始持續時間，稍後會更新
    );
    _blurAnimation = Tween<double>(begin: _blurBegin, end: _blurEnd).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _startTimer() {
    // 不需要在這裡 Get.find，_userController 已經在 initState 中初始化過了
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateAnimationFromUser(_userController.userRx.value); // 使用 .value 取得 Rx 的值
    });
  }

  void _updateAnimationFromUser(KingdomUser? user) {
    if (user == null) {
      _setAnimationParams(0, 0, const Duration(seconds: 1));
      return;
    }
    final drinks = user.drinks;

    final now = DateTime.now();
    final diffMinutes = now.difference(drinks.lastAt).inMinutes;

    double maxBlur = (drinks.count * 2.5).clamp(0, 25).toDouble();
    double minBlur = (maxBlur * 0.35).clamp(0, maxBlur);

    double decayFactor = (1 -
        (diffMinutes / KingdomUserDrinks.getDrinkFullyDecay(drinks.count).inMinutes)
    ).clamp(0.0, 1.0);

    maxBlur = maxBlur * decayFactor;
    minBlur = minBlur * decayFactor;

    int durationSeconds = (1 + drinks.count).clamp(1, 5);

    _setAnimationParams(minBlur, maxBlur, Duration(seconds: durationSeconds));
  }

  void _setAnimationParams(double begin, double end, Duration duration) {
    // 優化：只有當參數確實改變，或控制器動畫狀態不符合預期時才更新。
    if (_blurBegin == begin &&
        _blurEnd == end &&
        _duration == duration &&
        _controller.isAnimating == (_blurBegin > 0 || _blurEnd > 0)) {
      return; // 無需更新
    }

    _blurBegin = begin;
    _blurEnd = end;
    _duration = duration;

    // 不在這裡創建新的 AnimationController，而是更新現有的。
    if (_controller.duration != _duration) {
      _controller.duration = _duration;
    }

    // 更新動畫的 Tween，它會使用現有的 _controller 作為父級。
    _blurAnimation = Tween<double>(begin: _blurBegin, end: _blurEnd).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // 根據模糊值決定是否啟動或停止動畫
    if (_blurBegin > 0 || _blurEnd > 0) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      // 如果不需要模糊，停止動畫並將控制器值歸零
      if (_controller.isAnimating) {
        _controller.stop();
        _controller.value = 0.0;
      }
    }
    setState(() {}); // 觸發 UI 重建以反映新的動畫參數
  }

  @override
  Widget build(BuildContext context) {
    // 關鍵修復：GetBuilder 現在只負責觀察 userController 的變化並重建 UI。
    // 動畫參數的更新邏輯已經移到 initState 中的 `ever` 監聽器。
    return GetBuilder<UserController>(
      builder: (userController) {
        // 重要：不要在這裡呼叫 _updateAnimationFromUser！
        // 否則會再次觸發「setState() called during build」錯誤。
        // 動畫參數是由 `ever` 監聽器更新的。

        // 如果動畫參數都為 0，則不顯示模糊層
        if (_blurBegin == 0 && _blurEnd == 0) {
          return const SizedBox.shrink();
        }

        return IgnorePointer(
          child: AnimatedBuilder(
            animation: _blurAnimation,
            builder: (context, child) {
              return BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _blurAnimation.value,
                  sigmaY: _blurAnimation.value,
                ),
                child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  height: double.infinity,
                ),
              );
            },
          ),
        );
      },
    );
  }
}