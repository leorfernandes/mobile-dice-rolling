import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A widget that displays a dice icon with customizable appearance.
///
/// Renders a dice icon using SVG assets for the given number of sides.
/// The icon consists of two layers: a fill layer and a stroke layer.
class DiceIcon extends StatelessWidget {
  /// The number of sides on the dice (e.g., 6 for a standard die).
  final int sides;
  
  /// The size of the dice icon (both width and height).
  final double size;
  
  /// The fill color of the dice icon.
  final Color fillColor;
  
  /// The stroke/outline color of the dice icon.
  final Color strokeColor;

  /// Base path for the SVG assets.
  static const String _basePath = 'assets/icons';

  const DiceIcon({
    super.key,
    required this.sides,
    required this.size,
    required this.fillColor,
    required this.strokeColor,
  });

  /// Generates the asset path for the fill SVG.
  String _getFillAsset() => '$_basePath/dice-d$sides-fill.svg';

  /// Generates the asset path for the stroke SVG.
  String _getStrokeAsset() => '$_basePath/dice-d$sides-stroke.svg';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Render the fill layer of the dice
        _buildSvgLayer(_getFillAsset(), fillColor),
        
        // Render the stroke/outline layer of the dice
        _buildSvgLayer(_getStrokeAsset(), strokeColor),
      ],
    );
  }

  /// Creates an SVG layer with error handling.
  Widget _buildSvgLayer(String assetPath, Color color) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      // Add error handling for missing assets
      placeholderBuilder: (BuildContext context) => Container(
        width: size,
        height: size,
        color: Colors.transparent,
        child: Center(
          child: Icon(
            Icons.error_outline,
            color: color,
            size: size / 2,
          ),
        ),
      ),
    );
  }
}