import 'package:flutter/cupertino.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/models/kingdom_announcement.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

class RComment extends StatelessWidget {
  final AnnounceComment comment;
  const RComment(this.comment, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: vw(33),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RText.titleSmall("<${comment.group.toDisplay()}>", color: AppColors.onSurface.withAlpha(180),),
              RSpace(type: RSpaceType.small,),
              RText.titleLarge("${comment.name}：")
            ],
          ),
        ),
        RSpace(),
        SizedBox(
          width: vw(65) - 70,
          child: RText.bodyMedium(comment.message, maxLines: 4,),
        )
      ],
    );
  }
}