import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/user_controller.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/cloud_functions.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';
import 'package:rabbit_kingdom/widgets/r_fade_in_column.dart';
import 'package:rabbit_kingdom/widgets/r_layout_with_header.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';

import '../helpers/screen.dart';
import '../models/pray.dart';
import '../widgets/r_space.dart';
import '../widgets/r_text.dart';

class SelectPrayRewardPage extends StatelessWidget {
  const SelectPrayRewardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(_SelectPrayRewardController());

    return RLayoutWithHeader(
      "",
      child: Obx((){
        return controller.phase.value == _SelectPrayRewardPagePhase.select ?
        _PhaseSelectContent():
        _PhaseGetContent();
      })
    );
  }
}

enum _SelectPrayRewardPagePhase {
  select, get
}

class _SelectPrayRewardController extends GetxController {
  final phase = _SelectPrayRewardPagePhase.select.obs;
  final rewardsGot = Rx<List<PrayReward>>([]);
}

class _PhaseSelectContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: RFadeInColumn(
          children: [
            RText.headlineLarge("兔女神從池裡冒了出來"),
            RSpace(type: RSpaceType.small,),
            RText.bodySmall("她說：冒失的傢伙，你掉的是哪個東西呢？"),
            RSpace(),
            Image.asset(
              "lib/assets/images/pray_0.png",
              width: mainImageSize(),
              height: mainImageSize(),
            ),
            RSpace(),
            RText.bodySmall("女神的語氣溫柔而友善，她在等你做決定。"),
            RSpace(type: RSpaceType.large,),
            GetBuilder<UserController>(
                builder: (uc) {
                  if (uc.user?.pray.pending == null) {
                    return RText.titleMedium("獎品載入中");
                  }
                  final pending = uc.user!.pray.pending!;
                  return SizedBox(
                    width: vw(80) * deviceFactor(),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(child: RewardButton("A", pending.rewardA)),
                        RSpace(),
                        Expanded(child: RewardButton("B", pending.rewardB))
                      ],
                    ),
                  );
                }
            )
          ]
      ),
    );
  }
}

class RewardButton extends StatelessWidget {
  final PrayReward reward;
  final String id;
  const RewardButton(this.id, this.reward, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          RLoading.start();
          final result = await CloudFunctions.selectPrayReward(id);
          final controller = Get.find<_SelectPrayRewardController>();
          // 先取出雲端回傳的物件
          final res = result.data;
          // 檢查 data 是否為 List
          final rewardsJson = res is Map<String, dynamic> ? res['data'] : null;
          if (rewardsJson is List) {
            controller.rewardsGot.value = rewardsJson
                .map((r) => PrayReward.fromJson(Map<String, dynamic>.from(r)))
                .toList();
            controller.phase.value = _SelectPrayRewardPagePhase.get;
          } else {
            throw Exception("Result parse error");
          }
        } catch (e) {
          RSnackBar.error("選擇失敗", e.toString());
        } finally {
          RLoading.stop();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: vw(5)),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.onSurface.withAlpha(180), width: 2),
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: AppColors.surfaceContainerHigh.withAlpha(180)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              reward.getImagePath(),
              width: vw(20) * deviceFactor(),
              height: vw(20) * deviceFactor(),
            ),
            RText.titleLarge(reward.toDisplayString())
          ],
        ),
      ),
    );
  }
}

class _PhaseGetContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<_SelectPrayRewardController>();

    return Obx((){
      final rewards = controller.rewardsGot.value;
      final rewardsStr = rewards
        .map((reward) {
          return reward.toDisplayString();
        }).join(",");
      return Center(
        child: RFadeInColumn(
          mainAxisSize: MainAxisSize.min,
          children: [
            RText.headlineLarge(rewards.length == 1 ? "女神說：原來如此": "女神說：你好誠實"),
            RSpace(type: RSpaceType.small,),
            RText.bodySmall(rewards.length == 1 ? "那這個東西就給你了吧": "那這兩個都給你"),
            RSpace(type: RSpaceType.large,),
            RText.bodyLarge("你得到了：$rewardsStr"),
            RSpace(type: RSpaceType.large,),
            RButton.primary(text: "返回許願池", onPressed: (){ Get.back(); })
          ],
        ),
      );
    });
  }
}