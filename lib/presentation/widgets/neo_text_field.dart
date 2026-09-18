import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class NeoTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final Color backgroundColor;

  const NeoTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.onChanged,
    this.validator,
    this.backgroundColor = AppColors.cardWhite,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderBlack, width: 1.8),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowBlack,
                offset: Offset(2, 2.5),
                blurRadius: 0,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLines: maxLines,
            onChanged: onChanged,
            validator: validator,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textBlack,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: AppColors.textBlack, size: 20)
                  : null,
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
