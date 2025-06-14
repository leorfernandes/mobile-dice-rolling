import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DiceIcon extends StatelessWidget {
  final int sides;
  final double size;
  final Color fillColor;
  final Color strokeColor;

  const DiceIcon({
    super.key,
    required this.sides,
    required this.size,
    required this.fillColor,
    required this.strokeColor,
  });

  @override
  Widget build(BuildContext context) {
    String basePath = 'assets/icons';

    String getFillAsset() => '$basePath/dice-d$sides-fill.svg';
    String getStrokeAsset() => '$basePath/dice-d$sides-stroke.svg';

    return Stack(
      children: [
        SvgPicture.asset(
          getFillAsset(),
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(fillColor, BlendMode.srcIn),
        ),
        SvgPicture.asset(
          getStrokeAsset(),
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(strokeColor, BlendMode.srcIn),
        ),
      ],
    );
  }
}