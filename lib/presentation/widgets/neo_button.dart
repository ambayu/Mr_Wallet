import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class NeoButton extends StatefulWidget {
  final Widget? child;
  final String? label;
  final IconData? icon;
  final Widget? trailingIcon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double? width;
  final double borderRadius;
  final double borderWidth;
  final Offset shadowOffset;
  final EdgeInsetsGeometry? padding;

  const NeoButton({
    super.key,
    this.child,
    this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.backgroundColor = AppColors.primaryYellow,
    this.textColor = AppColors.textBlack,
    this.height = 52.0,
    this.width,
    this.borderRadius = 28.0,
    this.borderWidth = 2.0,
    this.shadowOffset = const Offset(2.5, 3.0),
    this.padding,
  });

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveShadow = _isPressed ? Offset.zero : widget.shadowOffset;
    final transformOffset = _isPressed ? widget.shadowOffset : Offset.zero;

    return GestureDetector(
      onTapDown: widget.onPressed == null
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.onPressed == null
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: widget.onPressed == null
          ? null
          : () => setState(() => _isPressed = false),
      child: Transform.translate(
        offset: transformOffset,
        child: Container(
          height: widget.height,
          width: widget.width,
          padding: widget.padding ??
              (widget.height < 46
                  ? const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0)
                  : const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0)),
          decoration: BoxDecoration(
            color: widget.onPressed == null
                ? AppColors.pillGray
                : widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: AppColors.borderBlack,
              width: widget.borderWidth,
            ),
            boxShadow: effectiveShadow == Offset.zero
                ? []
                : [
                    BoxShadow(
                      color: AppColors.shadowBlack,
                      offset: effectiveShadow,
                      blurRadius: 0,
                    ),
                  ],
          ),
          child: Center(
            child: widget.child ??
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: widget.textColor,
                        size: widget.height < 46 ? 16 : 20,
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (widget.label != null)
                      Flexible(
                        child: Text(
                          widget.label!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: widget.textColor,
                            fontSize: widget.height < 46 ? 13 : 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    if (widget.trailingIcon != null) ...[
                      const SizedBox(width: 6),
                      widget.trailingIcon!,
                    ],
                  ],
                ),
          ),
        ),
      ),
    );
  }
}
