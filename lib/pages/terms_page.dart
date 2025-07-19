import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/widgets/r_layout.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

import '../widgets/r_icon_button.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              height: 60,
              child: Stack(
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: RIconButton.back()
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: RText.titleLarge("兔兔王國 App 使用條款"),
                  )
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RText.titleLarge("使用條款"),
                      RSpace(),
                      RText.bodySmall("歡迎使用「兔兔王國」App，請您在使用本服務前詳閱以下條款："),
                      RSpace(type: RSpaceType.large,),
                      _ListItem("1.服務內容", "本 App 提供留言板功能，讓使用者能相互留言與交流。"),
                      _ListItem("2.用戶責任", "您在留言板發表的內容應遵守相關法律規範，禁止發布任何違法、誹謗、暴力或侵犯他人權益的言論。"),
                      _ListItem("3.資料保護", "留言內容會儲存在 Firebase Firestore，請妥善保護您的帳號資訊。"),
                      _ListItem("4.免責聲明", "本 App 對使用者在留言板發布的內容不負擔任何法律責任，但保留刪除不當內容的權利。"),
                      _ListItem("5.條款變更", "我們保留隨時修改本使用條款的權利，修改後會在 App 內公告。"),
                    ],
                  ),
                ),
              )
            )
          ],
        )
    );
  }
}

class _ListItem extends StatelessWidget {
  final String title;
  final String content;

  const _ListItem(this.title, this.content);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RText.titleLarge(title),
        RSpace(),
        Padding(
          padding: EdgeInsets.only(left: 15),
          child: RText.bodySmall(content),
        ),
        RSpace(),
      ],
    );
  }
}