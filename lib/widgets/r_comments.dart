import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rabbit_kingdom/models/kingdom_announcement.dart';
import 'package:rabbit_kingdom/widgets/r_comment.dart';

import '../helpers/app_colors.dart';
import '../helpers/screen.dart';

class RComments extends StatelessWidget {
  final List<AnnounceComment> comments;
  const RComments({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) return SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow.withAlpha(180),
            border: Border.all(color: AppColors.onSurface.withAlpha(50)),
            borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        child: Column(
          children: [
            ...comments.asMap().entries.map((entry) {
              return [
                RComment(entry.value),
                entry.key != comments.length - 1 ?
                SizedBox(
                  width: vw(100) - 60,
                  child: Divider(color: AppColors.onSurface.withAlpha(50),),
                ) : SizedBox.shrink()
              ];
            }).expand((e) => e)
          ],
        ),
      ),
    );
  }
}