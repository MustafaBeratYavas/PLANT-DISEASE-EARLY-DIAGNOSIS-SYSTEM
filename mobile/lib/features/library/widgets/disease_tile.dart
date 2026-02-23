import 'package:flutter/material.dart';
import '../../../data/models/disease_model.dart';

class DiseaseTile extends StatelessWidget {

  // Component constructor
  const DiseaseTile({
    super.key,
    required this.disease,
    required this.localizedName,
    required this.onTap,
    this.backgroundColor,
  });
  final DiseaseModel disease;
  final String localizedName;
  final VoidCallback onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCustomBackground = backgroundColor != null;

    // Adaptive color styles
    final textColor = isCustomBackground 
        ? Colors.white 
        : theme.textTheme.titleMedium?.color;

    final iconColor = isCustomBackground 
        ? Colors.white 
        : const Color(0xFF2E7D32);

    final iconBoxColor = isCustomBackground 
        ? Colors.white.withOpacity(0.2) 
        : const Color(0xFF2E7D32).withOpacity(0.1);

    final arrowColor = isCustomBackground 
        ? Colors.white70 
        : theme.iconTheme.color?.withOpacity(0.5);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      // Main card container
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // Handle user tap
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              // Content layout row
              children: [
                Container(
                  // Leading icon widget
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBoxColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.eco,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  // Disease name display
                  child: Text(
                    localizedName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: arrowColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}