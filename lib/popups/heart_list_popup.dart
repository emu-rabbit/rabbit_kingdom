import 'package:flutter/material.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/models/kingdom_announcement.dart';
import 'package:rabbit_kingdom/widgets/r_popup.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

class HeartListPopup extends StatelessWidget {
  final List<AnnounceHeart> hearts;
  const HeartListPopup({super.key, required this.hearts});

  @override
  Widget build(BuildContext context) {
    return RPopup(
      title: "是愛呀(${hearts.length})",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: vw(45),
            child: Divider(color: AppColors.onSecondary,),
          ),
          ...hearts.map((heart) {
            return [
              RText.titleLarge(heart.name, color: AppColors.onSecondary,)
            ];
          }).expand((e) => e)
        ],
      )
    );
  }
}