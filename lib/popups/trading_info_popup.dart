import 'package:flutter/cupertino.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/widgets/r_popup.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

class TradingInfoPopup extends StatelessWidget {
  const TradingInfoPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return RPopup(
      title: "歡迎來到交易所",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: vmin(13),
            child: RText.bodySmall("在這裡，你可以用兔兔幣購買兔兔精華，抑或是賣出兔兔精華獲取兔兔幣。", maxLines: 4, color: AppColors.onSecondary,),
          ),
          RSpace(),
          SizedBox(
            height: vmin(9),
            child: RText.bodySmall("交易所賣出價指的是交易所賣出兔兔精華給你的價格，反之亦然。", maxLines: 4, color: AppColors.onSecondary,),
          ),
          RSpace(),
          SizedBox(
            height: vmin(16),
            child: RText.bodySmall("兔兔精華的價格約三十分鐘會變動一次，兔兔大帝的心情更是會影響交易價格，還請注意市場最新狀態。", maxLines: 4, color: AppColors.onSecondary,),
          ),
          RSpace(),
          SizedBox(
            height: vmin(13),
            child: RText.bodySmall("精華的買賣價格是有價差的，買賣想賺價差時還請多注意手中的小帳本。", maxLines: 4, color: AppColors.onSecondary,),
          ),
          RSpace(),
        ],
      )
    );
  }
}