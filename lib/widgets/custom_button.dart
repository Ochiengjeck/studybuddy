import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isOutlined;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor; // New optional parameter
  final Color? foregroundColor; // New optional parameter
  final double? borderRadius; // New optional parameter
  final EdgeInsetsGeometry? padding; // New optional parameter
  final double? elevation; // New optional parameter
  final TextStyle? textStyle; // New optional parameter
  final double? iconSize; // New optional parameter
  final bool centerAligned; // New optional parameter

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isOutlined = false,
    this.icon,
    this.isLoading = false,
    this.backgroundColor, // Added new parameter
    this.foregroundColor, // Added new parameter
    this.borderRadius, // Added new parameter
    this.padding, // Added new parameter
    this.elevation, // Added new parameter
    this.textStyle, // Added new parameter
    this.iconSize = 20, // Added new parameter with default
    this.centerAligned = true, // Added new parameter with default
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor:
            foregroundColor ??
            (isOutlined
                ? theme.primaryColor
                : isPrimary
                ? Colors.white
                : Colors.black),
        backgroundColor:
            backgroundColor ??
            (isOutlined
                ? Colors.transparent
                : isPrimary
                ? theme.primaryColor
                : Colors.grey[300]),
        side:
            isOutlined ? BorderSide(color: theme.primaryColor, width: 2) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
        ),
        padding:
            padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        elevation: elevation ?? (isOutlined ? 0 : 2),
      ),
      onPressed: isLoading ? null : onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            centerAligned ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: iconSize,
              color:
                  foregroundColor ??
                  (isOutlined
                      ? theme.primaryColor
                      : isPrimary
                      ? Colors.white
                      : Colors.black),
            ),
            const SizedBox(width: 8),
          ],
          if (isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  foregroundColor ??
                      (isPrimary ? Colors.white : theme.primaryColor),
                ),
              ),
            )
          else
            Text(
              text,
              style:
                  textStyle ??
                  TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        foregroundColor ??
                        (isOutlined
                            ? theme.primaryColor
                            : isPrimary
                            ? Colors.white
                            : Colors.black),
                  ),
            ),
        ],
      ),
    );
  }
}
