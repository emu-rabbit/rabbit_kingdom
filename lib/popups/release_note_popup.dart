import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/announce_controller.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
import 'package:rabbit_kingdom/widgets/r_popup.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';
import 'package:rabbit_kingdom/widgets/r_text_input.dart';

class ReleaseNotePopup extends StatelessWidget {
  const ReleaseNotePopup({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_ReleaseNote> notes = [
      _ReleaseNote(
          title: "<2025/08/02>",
          contents: [
            "調整部分畫面與文字",
            "調整了小帳冊的排版與內容",
            "調整和修改了一些國人看不到的機制",
            "更換了兔兔大帝生氣和激動的樣子",
          ]
      ),
      _ReleaseNote(
          title: "<2025/08/01>",
          contents: [
            "新增交易所新聞系統",
            "修正了王國建築物漂移的問題",
            "提升了王國景觀在不同解析度手機的呈現",
            "修正了信箱登入失敗沒有提示的問題",
            "修正了輸入框會被鍵盤擋到的問題",
            "修正了從背景喚醒時沒有觸發完成登入任務的問題",
            "調整了精華交易頁面的標頭顯示",
            "小幅調整了公告回覆區的版面",
            "提升部分功能的效能"
          ]
      ),
      _ReleaseNote(
          title: "<2025/07/31>",
          contents: [
            "支援了ios設備",
            "抓不到廣告現在有錯誤提示了",
            "修正了會自動被退回主頁的錯誤",
          ]
      ),
      _ReleaseNote(
          title: "<2025/07/30>",
          contents: [
            "調整了部分任務數值",
            "現在喝酒只要30分鐘就會醒了",
            "提升應用程式效能"
          ]
      ),
      _ReleaseNote(
          title: "<2025/07/29>",
          contents: [
            "開啟交易所，新增兔兔精華交易系統",
            "新增交易相關任務",
            "調整了背景"
          ]
      ),
      _ReleaseNote(
          title: "<2025/07/27>",
          contents: [
            "新增和調整了一些旅人看不到的功能"
          ]
      ),
      _ReleaseNote(
          title: "<2025/07/25>",
          contents: [
            "新增廣告和相關任務 (非網頁平台限定)",
            "酒館開放喝酒 (請別喝太多)",
            "任務頁的任務現在可以點擊了",
            "修正了任務沒有在台灣時間早上八點正常刷新的錯誤",
            "小兔窩現在新增了前往通知設定的按鈕",
            "小兔窩開了一個假的殺廣告功能按鈕"
          ]
      ),
      _ReleaseNote(
          title: "<2025/07/24>",
          contents: [
            "開放酒館、新增了任務系統",
            "現在若拒絕權限就不會再被詢問了(兔兔大帝不想當恐怖情兔)",
            "可以查看誰按了愛心(但入口很難點)",
            "可以查看歷史公告了",
            "啟動時有跑條頁了 (但現在他跑很快看不到)",
            "現在兔兔公務員會主動來通知更新APP"
          ]
      ),
      _ReleaseNote(
        title: "<2025/07/23>",
        contents: [
          "新增工程紀錄系統",
          "現在新公告出現時會發布通知了(曾以最新版登入後才會收到通知)",
          "調整了公告中愛心按鈕的顏色",
          "小窩中的登出按鈕改為醒目顏色",
          "現在公告頁的留言會即時的更新，不須重新進入頁面"
        ]
      )
    ];

    return RPopup(
        title: "王國工程紀錄",
        width: vw(85),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: vh(80)),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 15),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...notes.map((note) {
                  return [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RText.titleLarge(note.title, color: AppColors.onSecondary,),
                          RSpace(type: RSpaceType.small,),
                          ...note.contents.map((content) {
                            return [
                              RText.bodySmall("- $content", color: AppColors.onSecondary, maxLines: 10,),
                              RSpace(type: RSpaceType.small,)
                            ];
                          }).expand((e) => e)
                        ],
                      ),
                    ),
                    RSpace(type: RSpaceType.large,)
                  ];
                }).expand((e) => e)
              ],
            ),
          ),
        )
    );
  }
}

class _ReleaseNote {
  final String title;
  final List<String> contents;

  const _ReleaseNote({ required this.title, required this.contents });
}