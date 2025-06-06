import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isOutlined;
  final IconData? icon;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isOutlined = false,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor:
            isOutlined
                ? Theme.of(context).primaryColor
                : isPrimary
                ? Colors.white
                : Colors.black,
        backgroundColor:
            isOutlined
                ? Colors.transparent
                : isPrimary
                ? Theme.of(context).primaryColor
                : Colors.grey[300],
        side:
            isOutlined
                ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
                : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        elevation: isOutlined ? 0 : 2,
      ),
      onPressed: isLoading ? null : onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 20), SizedBox(width: 8)],
          if (isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isPrimary ? Colors.white : Theme.of(context).primaryColor,
                ),
              ),
            )
          else
            Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
