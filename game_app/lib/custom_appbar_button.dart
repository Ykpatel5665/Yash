import 'package:flutter/material.dart';

/// A reusable AppBar navigation button matching the Truth/Dare cross style.
class CustomAppBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final double? size;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;

  const CustomAppBarButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size,
    this.iconSize,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;
    final double buttonSize = (width * 0.13).clamp(44, 70); // Square, responsive
    final double iconSizeValue = (width * 0.07).clamp(22, 36);
    return Padding(
      padding: padding ?? const EdgeInsets.only(left: 5, top: 15, bottom: 15),
      child: Container(
        width: size ?? buttonSize,
        height: size ?? buttonSize,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10), // Square look
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), offset: Offset(3, 3), blurRadius: 6),
            BoxShadow(color: Colors.white.withOpacity(0.4), offset: Offset(-3, -3), blurRadius: 6),
          ],
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.black, size: iconSize ?? iconSizeValue),
          tooltip: tooltip,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
