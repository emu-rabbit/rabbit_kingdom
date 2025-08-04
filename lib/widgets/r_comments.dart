import 'package:flutter/material.dart';
import 'package:rabbit_kingdom/models/kingdom_announcement.dart';
import 'package:rabbit_kingdom/widgets/r_comment.dart';

import '../helpers/app_colors.dart';
import '../helpers/screen.dart';

class RComments extends StatelessWidget {
  final List<AnnounceComment> comments;
  final bool isScrollable; // 新增的參數，用於決定是否啟用滾動

  const RComments({
    super.key,
    required this.comments,
    this.isScrollable = true, // 預設為 true，讓它自己滾動
  });

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow.withAlpha(180),
          border: Border.all(color: AppColors.onSurface.withAlpha(50)),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: ListView.separated(
          // 根據 isScrollable 參數來決定是否啟用 shrinkWrap 和 physics
          shrinkWrap: !isScrollable,
          physics: isScrollable ? null : const NeverScrollableScrollPhysics(),

          itemCount: comments.length,
          itemBuilder: (context, index) {
            return RComment(comments[index]);
          },
          separatorBuilder: (context, index) {
            return SizedBox(
              width: vw(100) * deviceFactor() - 60,
              child: Divider(color: AppColors.onSurface.withAlpha(50)),
            );
          },
        ),
      ),
    );
  }
}