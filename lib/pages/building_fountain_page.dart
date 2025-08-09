import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/app_config_controller.dart';
import 'package:rabbit_kingdom/controllers/auth_controller.dart';
import 'package:rabbit_kingdom/controllers/theme_controller.dart';
import 'package:rabbit_kingdom/extensions/get_interface.dart';
import 'package:rabbit_kingdom/helpers/ad.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/cloud_functions.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/models/pray.dart';
import 'package:rabbit_kingdom/popups/web_notification_popup.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';
import 'package:rabbit_kingdom/widgets/r_button_group.dart';
import 'package:rabbit_kingdom/widgets/r_fade_in_column.dart';
import 'package:rabbit_kingdom/widgets/r_layout_with_header.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
import 'package:rabbit_kingdom/widgets/r_popup.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

class BuildingFountainPage extends StatelessWidget {
  const BuildingFountainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RLayoutWithHeader(
        "",
        child: SingleChildScrollView(
          child: RFadeInColumn(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RText.headlineLarge("你靠近了許願池"),
              RSpace(type: RSpaceType.small,),
              RText.bodySmall("一些兔子圍繞著許願池，向裡面投擲兔兔幣和精華"),
              RSpace(),
              Image.asset(
                "lib/assets/images/fountain_0.png",
                width: mainImageSize(),
                height: mainImageSize(),
              ),
              RSpace(type: RSpaceType.large,),
              GetBuilder<AppConfigController>(
                builder: (ac) {
                  return RButtonGroup(
                      "你看著許願池，佇足思考著",
                      [
                        RButtonData(
                            child: (color) {
                              return Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RText.bodyLarge("簡單許個願 (", color: color,),
                                  Image.asset(
                                    "lib/assets/images/rabbit_coin.png",
                                    width: vw(6),
                                    height: vw(6),
                                  ),
                                  RText.bodyLarge("-${ac.config.priceSimplePray})", color: color,),
                                ],
                              );
                            },
                            onPress: () async {
                              try {
                                RLoading.start();
                                await CloudFunctions.makePray(PrayType.simple);
                              } catch (e) {
                                RSnackBar.error("許願失敗", e.toString());
                              } finally {
                                RLoading.stop();
                              }
                            }
                        ),
                        RButtonData(
                            child: (color) {
                              return Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RText.bodyLarge("虔誠的許願 (", color: color,),
                                  Image.asset(
                                    "lib/assets/images/empire_poop.png",
                                    width: vw(6),
                                    height: vw(6),
                                  ),
                                  RText.bodyLarge("-${ac.config.priceAdvancePray})", color: color,),
                                ],
                              );
                            },
                            onPress: () async {
                              try {
                                RLoading.start();
                                await CloudFunctions.makePray(PrayType.advance);
                              } catch (e) {
                                RSnackBar.error("許願失敗", e.toString());
                              } finally {
                                RLoading.stop();
                              }
                            }
                        ),
                      ]
                  );
                }
              )
            ],
          ),
        )
    );
  }
}