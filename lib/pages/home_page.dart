import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/theme_controller.dart';
import 'package:rabbit_kingdom/controllers/user_controller.dart';
import 'package:rabbit_kingdom/extensions/get_interface.dart';
import 'package:rabbit_kingdom/helpers/ad.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/pages/building_house_page.dart';
import 'package:rabbit_kingdom/pages/building_tavern_page.dart';
import 'package:rabbit_kingdom/pages/building_town_hall_page.dart';
import 'package:rabbit_kingdom/popups/budget_popup.dart';
import 'package:rabbit_kingdom/widgets/r_ad_banner.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: _KingdomView(),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: SafeArea(child: _Header()),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(child: _AdBanner()),
        )
      ],
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return GetBuilder<UserController>(
      builder: (userController) {
        final userName = userController.user?.name ?? 'Unknown';
        final userLevel = 'Lv.${userController.user?.exp.level ?? 0}';

        return Container(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: vw(55)),
                      child: _HeaderText(userName),
                    ),
                    RSpace(type: RSpaceType.small,),
                    _HeaderText(userLevel),
                  ],
                )
              ),
              _HeaderMoney(),
            ],
          ),
        );
      }
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  final double fontSize;
  const _HeaderText(this.text, { this.fontSize = 26 });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
        builder: (themeController) {
          return Stack(
            children: [
              // 底層：描邊
              Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize,
                  fontFamily: 'JFHuninn',
                  decoration: TextDecoration.none,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = fontSize / 26 * 4
                    ..color = themeController.brightness == Brightness.light ?
                        Color(0xffe6723d)
                      : AppColors.surfaceContainerHigh,
                ),
              ),
              // 上層：填色
              Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize,
                  decoration: TextDecoration.none,
                  fontFamily: 'JFHuninn',
                  color: themeController.brightness == Brightness.light ?
                    Color(0xfff2e4df)
                  : AppColors.onSurface,
                ),
              ),
            ],
          );
        }
    );
  }
}

class _HeaderMoney extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(
      builder: (userController) {
        return GestureDetector(
          onTap: (){ Get.rPopup(BudgetPopup()); },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/images/money_bag.png',
                width: 25,
                height: 25,
              ),
              SizedBox(width: 2,),
              _HeaderText(userController.user?.budget.propertyText ?? "0", fontSize: 20,)
            ],
          ),
        );
      }
    );
  }
}

class _KingdomView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        final kingdomViewData = (
          background: (
            width: 552.0,
            height: 1288.0
          ),
          buildings: [
            (name: "TownHall", x: 275.0, y: 212.0, width: 256.0, height: 373.0, onPress: (){ Get.to(() => BuildingTownHallPage()); }),
            (name: "Trading", x: 75.0, y: 328.0, width: 150.0, height: 150.0, onPress: (){}),
            (name: "House", x: 48.0, y: 470.0, width: 175.0, height: 250.0, onPress: (){ Get.to(() => BuildingHousePage()); }),
            (name: "Tavern", x: 283.0, y: 600.0, width: 196.0, height: 260.0, onPress: (){ Get.to(() => BuildingTavernPage()); }),
            (name: "Fountain", x: 58.0, y: 780.0, width: 146.0, height: 190.0, onPress: (){}),
          ]
        );

        final phase = themeController.brightness == Brightness.light ? "day" : "night";
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
              })
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

class _AdBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return isAdSupported() ? Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RAdBanner()
      ],
    ) : SizedBox.shrink();
  }
}