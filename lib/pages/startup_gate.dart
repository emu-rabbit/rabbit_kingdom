import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'initialize_page.dart';

class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 這時畫面已經 ready，Get.width 就會是正確的！
      Get.off(() => const InitializePage());
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator()), // 或空白畫面也行
    );
  }
}
