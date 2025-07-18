import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/widgets/r_layout.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

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
                  child: GestureDetector(
                    onTap: Get.back,
                    child: FaIcon(
                      FontAwesomeIcons.arrowLeft,
                      color: AppColors.onSurface,
                    )
                  )
                ),
                Align(
                  alignment: Alignment.center,
                  child: RText.titleLarge("兔兔王國 App 隱私權政策"),
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
                    RText.titleLarge("隱私權政策"),
                    RSpace(),
                    RText.bodySmall("歡迎使用「兔兔王國」App，我們重視您的隱私，以下說明我們的隱私政策："),
                    RSpace(type: RSpaceType.large,),
                    _ListItem("1.收集資訊", "本 App 不會主動收集您的個人資料。登入功能使用 Firebase 提供的 Google 與郵件登入，登入資料由 Firebase 管理。"),
                    _ListItem("2.資料使用", "我們不會用您的資料進行任何廣告或行銷用途。 App 中的留言板功能會將您所輸入的留言存放於 Firebase Firestore。"),
                    _ListItem("3.第三方服務", "本 App 使用 Firebase Firestore 來儲存留言板資料，並使用 Firebase Authentication 作為登入驗證。我們不使用 Firebase Analytics 或其他追蹤工具。"),
                    _ListItem("4.資料安全", "我們會盡力保護您的資料安全，避免未經授權的存取、修改或洩漏。"),
                    _ListItem("5.隱私權政策更新", "若有政策變更，會在此公告並提示使用者。"),
                    RSpace(),
                    RText.titleLarge("聯絡方式"),
                    RSpace(),
                    RText.bodySmall("如有隱私權相關疑問，歡迎聯絡我們：mausu2526@gmail.com"),
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