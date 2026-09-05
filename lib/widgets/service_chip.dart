import 'package:flutter/material.dart';
import 'package:maid_rent/config/theme.dart';

class ServiceChip extends StatelessWidget {
  final String label;
  final bool small;
  final bool isSelected;
  final VoidCallback? onTap;

  const ServiceChip({
    super.key,
    required this.label,
    this.small = false,
    this.isSelected = false,
    bool? selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: small ? 8 : 12,
          vertical: small ? 3 : 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: small ? 10 : 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}
