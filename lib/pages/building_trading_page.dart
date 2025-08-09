import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/extensions/get_interface.dart';
import 'package:rabbit_kingdom/pages/news_page.dart';
import 'package:rabbit_kingdom/pages/trading_page.dart';
import 'package:rabbit_kingdom/popups/trading_info_popup.dart';
import 'package:rabbit_kingdom/popups/trading_note_popup.dart';
import 'package:rabbit_kingdom/widgets/r_button_group.dart';
import 'package:rabbit_kingdom/widgets/r_fade_in_column.dart';
import 'package:rabbit_kingdom/widgets/r_icon_button.dart';

import '../helpers/screen.dart';
import '../widgets/r_layout_with_header.dart';
import '../widgets/r_space.dart';
import '../widgets/r_text.dart';

class BuildingTradingPage extends StatelessWidget {
  const BuildingTradingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RLayoutWithHeader(
        "",
        topRight: RIconButton(
          icon: FontAwesomeIcons.circleQuestion,
          onPress: (){ Get.rPopup(TradingInfoPopup()); }
        ),
        child: SingleChildScrollView(
          child: RFadeInColumn(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RText.headlineLarge("你靠近了一個巨大的水晶"),
              RSpace(type: RSpaceType.small,),
              RText.bodySmall("交易所裡喧嘩聲此起彼落，有人笑著也有人失落"),
              RSpace(),
              Image.asset(
                "lib/assets/images/trading_0.png",
                width: mainImageSize(),
                height: mainImageSize(),
              ),
              RSpace(type: RSpaceType.large,),
              RButtonGroup(
                  "你看著那個高聳的水晶",
                  [
                    RButtonData(text: "交易兔兔精華", onPress: (){ Get.to(() => TradingPage()); }),
                    RButtonData(text: "瀏覽最近的新聞", onPress: (){ Get.to(() => NewsPage()); }),
                  ]
              ),
              RSpace(type: RSpaceType.large,),
              RButtonGroup(
                  "你手中捏著一張小紙條",
                  [
                    RButtonData(text: "查看買賣小帳本", onPress: (){ Get.rPopup(TradingNotePopup()); })
                  ]
              ),
            ],
          ),
        )
    );
  }
}