import 'package:flutter/material.dart';

class CircularIconButton extends StatelessWidget {

  const CircularIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
  });
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    // Resolve theme colors
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Adaptive background color
    final bgColor = isDark
        ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.8)
        : theme.colorScheme.surface.withOpacity(0.9);

    final iconColor = theme.colorScheme.onSurface;

    // Build circular button
    Widget button = Material(
      color: bgColor,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      type: MaterialType.transparency,
      child: Ink(
        // Apply circular decoration
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
           boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.1),
               blurRadius: 4,
               offset: const Offset(0, 2),
             ),
           ],
        ),
        child: InkWell(
          // Handle tap interaction
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
        ),
      ),
    );

    // Attach optional tooltip
    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: button,
    );
  }
}