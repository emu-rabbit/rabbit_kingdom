import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return ColoredBox(
      color: color.surface,
      child: SafeArea(
        child: Center(
          child: Text("Login"),
        )
      ),
    );
  }
}