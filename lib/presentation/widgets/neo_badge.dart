import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class NeoBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final double borderWidth;
  final Offset shadowOffset;

  const NeoBadge({
    super.key,
    required this.text,
    this.icon,
    this.backgroundColor = AppColors.butterYellow,
    this.textColor = AppColors.textBlack,
    this.fontSize = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
    this.borderWidth = 2.0,
    this.shadowOffset = const Offset(2.0, 2.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: AppColors.borderBlack,
          width: borderWidth,
        ),
        boxShadow: shadowOffset == Offset.zero
            ? []
            : [
                BoxShadow(
                  color: AppColors.shadowBlack,
                  offset: shadowOffset,
                  blurRadius: 0,
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
