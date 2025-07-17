import 'package:flutter/widgets.dart';

enum RSpaceType { large, median, small }

class RSpace extends StatelessWidget {
  final RSpaceType type;

  const RSpace({
    this.type = RSpaceType.median,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    var size = switch(type) {
      RSpaceType.large => 20.0,
      RSpaceType.median => 10.0,
      RSpaceType.small => 5.0,
    };
    return SizedBox(
      width: size,
      height: size,
    );
  }
}