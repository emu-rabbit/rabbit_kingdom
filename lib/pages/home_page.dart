import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';
import '../controllers/theme_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '兔兔大帝之家',
          style: TextStyle(
            color: color.onSurface
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '目前是：${themeController.themeMode.value == ThemeMode.light ? '☀️ 明亮主題' : '🌙 黑暗主題'}',
              style: TextStyle(
                fontSize: 20,
                color: color.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            RButton.primary(
              onPressed: themeController.toggleTheme,
              text: '切換(主要按鈕)',
            ),
            const SizedBox(height: 16),
            RButton.secondary(
              onPressed: themeController.toggleTheme,
              text: '切換(次要按鈕)',
            ),
            const SizedBox(height: 16),
            RButton.surface(
              onPressed: themeController.toggleTheme,
              text: '切換(平淡按鈕)',
            ),
            const SizedBox(height: 16),
            RButton.danger(
              onPressed: themeController.toggleTheme,
              text: '切換(危險按鈕)',
            ),
          ],
        ),
      ),
    );
  }
}
