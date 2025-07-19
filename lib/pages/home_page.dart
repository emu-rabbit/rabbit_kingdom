import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/theme_controller.dart';
import 'package:rabbit_kingdom/widgets/r_blurred_overlay.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _KingdomView(),
    );
  }
}

class _KingdomView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        final themeController = Get.find<ThemeController>();
        final mode = themeController.themeMode.value;
        final brightness = () {
          if (mode == ThemeMode.system) {
            return MediaQuery.platformBrightnessOf(Get.context!);
          }
          return mode == ThemeMode.dark ? Brightness.dark : Brightness.light;
        }();
        final phase = brightness == Brightness.light ? "day" : "night";

        final screenWidth = MediaQuery.of(context).size.width;

        // 根據原始背景比例換算高度
        final backgroundAspectRatio =
            kingdomViewData.background.width / kingdomViewData.background.height;
        final scaledHeight = screenWidth / backgroundAspectRatio;

        return SizedBox(
          width: screenWidth,
          height: scaledHeight,
          child: Stack(
            children: [
              // 背景圖
              Positioned.fill(
                child: Image.asset(
                  'lib/assets/images/kingdom_$phase.png',
                  fit: BoxFit.fill,
                ),
              ),

              // 建築物們
              ...kingdomViewData.buildings.map((building) {
                final scaleX = screenWidth / kingdomViewData.background.width;
                final scaleY = scaledHeight / kingdomViewData.background.height;

                final left = building.x * scaleX;
                final top = building.y * scaleY;

                return Positioned(
                  left: left,
                  top: top,
                  child: _KingdomViewBuilding(
                    name: building.name,
                    onTap: building.onPress,
                    phase: phase,
                    width: building.width * scaleX,
                    height: building.height * scaleY,
                  ),
                );
              }),
              // Align(
              //   alignment: Alignment.topLeft,
              //   child: RButton.primary(
              //       onPressed: () { themeController.setThemeMode(themeController.themeMode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark); },
              //       child: (color) => Text("aa")
              //   ),
              // ),
            ],
          ),
        );
      });
  }
}


class _KingdomViewBuilding extends StatefulWidget {
  final String name;
  final String phase;
  final double width;
  final double height;
  final VoidCallback onTap;

  const _KingdomViewBuilding({
    super.key,
    required this.name,
    required this.onTap,
    required this.phase,
    required this.width,
    required this.height,
  });

  @override
  State<_KingdomViewBuilding> createState() => _KingdomViewBuildingState();
}

class _KingdomViewBuildingState extends State<_KingdomViewBuilding>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.85,
      upperBound: 1.0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.value = 1.0;
  }

  void _handleTap() async {
    await _controller.reverse();
    await _controller.forward();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: _handleTap,
        child: Image.asset(
          'lib/assets/images/building_${widget.name.toLowerCase()}_${widget.phase}.png', // 建築物圖片需放在 assets/images 下
          width: widget.width, // 可以視情況調整
          height: widget.height,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}


final kingdomViewData = (
  background: (
    width: 552.0,
    height: 1288.0
  ),
  buildings: [
    (name: "TownHall", x: 275.0, y: 212.0, width: 256.0, height: 373.0, onPress: (){}),
    (name: "Trading", x: 75.0, y: 328.0, width: 150.0, height: 150.0, onPress: (){}),
    (name: "Home", x: 48.0, y: 470.0, width: 175.0, height: 250.0, onPress: (){}),
    (name: "Tavern", x: 283.0, y: 600.0, width: 196.0, height: 260.0, onPress: (){}),
    (name: "Fountain", x: 58.0, y: 780.0, width: 146.0, height: 190.0, onPress: (){}),
  ]
);