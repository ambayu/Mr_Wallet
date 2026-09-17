import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class NeoCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final double borderWidth;
  final Color borderColor;
  final double borderRadius;
  final Offset shadowOffset;
  final Color shadowColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const NeoCard({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.cardWhite,
    this.borderWidth = 2.5,
    this.borderColor = AppColors.borderBlack,
    this.borderRadius = 22.0,
    this.shadowOffset = const Offset(3.5, 4.0),
    this.shadowColor = AppColors.shadowBlack,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: shadowOffset == Offset.zero
            ? []
            : [
                BoxShadow(
                  color: shadowColor,
                  offset: shadowOffset,
                  blurRadius: 0,
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}
