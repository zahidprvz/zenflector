import 'package:flutter/material.dart';
import 'package:zenflector/utils/constants.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll; // Optional callback

  const SectionHeader({
    super.key,
    required this.title,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.defaultPadding / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (onViewAll != null) // Only show if callback is provided
            TextButton(
              onPressed: onViewAll,
              child: Text(
                'Voir tout', // Or "View All" in English
                style: TextStyle(color: AppColors.secondary),
              ),
            ),
        ],
      ),
    );
  }
}
