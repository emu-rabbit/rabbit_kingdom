import 'package:flutter/cupertino.dart';
import 'package:rabbit_kingdom/widgets/r_layout_with_header.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RLayoutWithHeader(
      "交易所新聞",
      child: SizedBox.shrink()
    );
  }
}