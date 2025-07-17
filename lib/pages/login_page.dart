import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RText.displayLarge("兔兔王國城門"),
              RSpace(),
              _RabbitEmpireImage(),
              RSpace(),
              SizedBox(
                width: vw(60),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _LoginButton(
                      text: "用Google登入",
                      icon: FontAwesomeIcons.google,
                    ),
                    RSpace(),
                    _LoginButton(
                      text: "使用信箱登入",
                      icon: FontAwesomeIcons.envelope,
                    )
                  ],
                ),
              ),
              RSpace(type: RSpaceType.large,),
              RText.bodySmall("~今天也要很可愛的入境~"),
            ],
          ),
        )
      ),
    );
  }
}

class _RabbitEmpireImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'lib/assets/images/rabbit_empire_0.png',
      width: vmin(75),
      height: vmin(75),
      fit: BoxFit.cover,
    );
  }
}

class _LoginButton extends StatelessWidget {
  final String text;
  final IconData icon;

  const _LoginButton({
    required this.text,
    required this.icon
  });

  @override
  Widget build(BuildContext context) {
    return RButton.primary(
        onPressed: (){},
        child: (color) => Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FaIcon(icon, color: color, size: 20,),
              RSpace(type: RSpaceType.small,),
              RText.bodyLarge(
                text,
                color: color,
              )
            ],
          ),
        )
    );
  }
}