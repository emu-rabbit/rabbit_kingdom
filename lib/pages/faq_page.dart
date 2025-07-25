import 'package:flutter/cupertino.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/widgets/r_collapsiable.dart';
import 'package:rabbit_kingdom/widgets/r_layout_with_header.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';

import '../widgets/r_text.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final faqData = [
      (
        title: "什麼是兔兔王國？",
        content: "兔兔王國是兔兔大帝利用智慧科技一手創造的王國，目前僅開放兔兔大帝的好友們入境參觀與遊玩。未來是否會再進一步擴大入境資格，兔兔大帝還在觀察中。"
      ),
      (
        title: "在兔兔王國會使用到境外的貨幣嗎？",
        content: "在兔兔王國內，只會用到兔兔王國的貨幣，目前沒有規畫收任何其他的貨幣唷。"
      ),
      (
        title: "什麼是兔兔幣？",
        content: "兔兔幣是兔兔王國法定流通的貨幣，可以主要透過酒館的任務獲得，在兔兔王國生活主要的花費都會用到它唷！"
      ),
      (
        title: "什麼是兔兔精華？",
        content: "兔兔精華是由兔兔大帝生產的，像是黃金一樣的東西。在交易所內，會公告當前的賣出價格與收購價格，你可以在那邊進行交易。請注意，兔兔精華的現價會因兔兔大帝的心情而有所浮動。"
      ),
      (
        title: "個人資產是如何計算的？",
        content: "個人資產以兔兔幣為單位，除了你擁有的兔兔幣以外，還會將你擁有的兔兔精華以當前交易所收購價格做計價，總和就是你的資產。畫面右上顯示的圖示可以點擊看詳細唷。"
      ),
      (
        title: "兔兔大帝的心情？",
        content: "兔兔王國的所有居民都關心兔兔大帝的心情，大帝的心情也影響了交易所的兔兔精華現價。心情指數越高，則代表兔兔大帝越開心，反之則是心情不好。而不管大帝傷心或是開心，都推薦留言給她唷！"
      ),
      (
        title: "為何兔兔王國要通知權限？",
        content: "通知是為了讓你在第一時間收到兔兔大帝發布的公告，倘若你之前拒絕，後面又想接收的話，請自行去裝置設定業重新打開唷。(部分網頁板不支援此功能)"
      ),
      (
        title: "任務系統？",
        content: "每日任務會在台灣時間的早上八點刷新，觸發相關動作後任務會自動完成，每個任務都有每天能完成的次數上限，超過了就算完成也沒有獎勵唷！"
      ),
      (
        title: "經驗值是？",
        content: "經驗值主要靠任務獲得，經驗值越高，在許願池許願時取得較好的獎勵機率會越高唷！"
      ),
      (
        title: "酒可以一直喝嗎？",
        content: "只要有錢，當然可以一直喝囉，但提醒您不要過量飲酒唷！暈的效果大概要一個半小時才會完全消退，請注意如果還沒酒退就再喝的話會更暈唷！"
      )
    ];
    return RLayoutWithHeader(
      "",
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RText.titleLarge("兔兔公務員正等待你發問"),
            RSpace(type: RSpaceType.large,),
            SizedBox(
              width: vw(75),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...faqData.map((data) {
                    return Column(
                      children: [
                        RCollapsible(title: data.title, content: data.content),
                        RSpace()
                      ],
                    );
                  })
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}
