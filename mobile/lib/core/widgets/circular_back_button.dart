import 'package:flutter/material.dart';

class CircularBackButton extends StatelessWidget {

  const CircularBackButton({super.key, this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    // Resolve theme colors
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Adaptive background style
    final bgColor = isDark
        ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.8)
        : theme.colorScheme.surface.withOpacity(0.9);

    final iconColor = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        // Material design container
        color: bgColor,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        type: MaterialType.transparency,
        child: Ink(
          // Custom shape decoration
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
            // Handle navigation action
            onTap: onPressed ?? () => Navigator.maybePop(context),
            customBorder: const CircleBorder(),
            child: Center(
              child: Icon(
                Icons.arrow_back_rounded,
                color: iconColor,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}