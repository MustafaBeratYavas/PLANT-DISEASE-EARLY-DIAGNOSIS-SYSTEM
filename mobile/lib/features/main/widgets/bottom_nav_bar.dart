import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BottomAppBar(
      // Styled bottom bar
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      color: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 10,
      height: 55,
      padding: EdgeInsets.zero,
      child: Row(
        // Navigation items layout
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home_rounded, 0),
          _buildNavItem(context, Icons.local_florist_rounded, 1),
          // Space for FAB
          const SizedBox(width: 48), 
          _buildNavItem(context, Icons.history_rounded, 2),
          _buildNavItem(context, Icons.settings_rounded, 3),
        ],
      ),
    );
  }

  // Build single tab
  Widget _buildNavItem(BuildContext context, IconData icon, int index) {
    final isSelected = currentIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      // Handle tab selection
      onTap: () => onTap(index),
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Icon(
          icon,
          // Active state color
          color: isSelected 
              ? colorScheme.primary 
              : colorScheme.onSurface.withOpacity(0.4),
          size: 26,
        ),
      ),
    );
  }
}