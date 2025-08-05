import 'package:flutter/cupertino.dart';
import 'package:rabbit_kingdom/values/caches.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';
import 'package:rabbit_kingdom/widgets/r_layout_with_header.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';

class EmpireControlPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RLayoutWithHeader(
      "控制台",
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RButton.primary(
              text: "清除排行榜快取",
              onPressed: () async {
                try {
                  RLoading.start();
                  for (final x in Caches.ranksData.values) {
                    for (final y in x.values) {
                      await y.clear();
                    }
                  }
                  RSnackBar.show("清除成功", "萬能的控制台");
                } catch (e) {
                  RSnackBar.error("清除失敗", e.toString());
                } finally {
                  RLoading.stop();
                }
              }
            )
          ],
        ),
      )
    );
  }
}