import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Header Card Neo-brutalist full-width (menempel atas, kiri, kanan)
/// dengan border bawah tebal dan shadow solid, memberikan kesan navbar kokoh dan teks sangat jelas.
class NeoHeaderCard extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final double height;
  final Color backgroundColor;

  const NeoHeaderCard({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.leading,
    this.actions,
    this.height = 68.0,
    this.backgroundColor = AppColors.cardWhite,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderBlack,
            width: 2.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlack,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 6),
              ],
              Expanded(
                child: titleWidget ??
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null)
                          Text(
                            title!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textBlack,
                              letterSpacing: -0.3,
                            ),
                          ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
              ),
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

