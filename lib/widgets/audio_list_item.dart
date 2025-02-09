import 'package:flutter/material.dart';
import 'package:zenflector/models/audio.dart';
import 'package:zenflector/utils/constants.dart';

class AudioListItem extends StatelessWidget {
  final Audio audio;
  final VoidCallback onTap;
  final bool isPlaying;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final VoidCallback? onRemovePressed; // Add this

  const AudioListItem({
    super.key,
    required this.audio,
    required this.onTap,
    required this.isPlaying,
    required this.isFavorite,
    required this.onFavoritePressed,
    this.onRemovePressed, // Add to constructor
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
          vertical: 4, horizontal: AppConstants.defaultPadding),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              // Play/Pause Icon (or a thumbnail)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.highlightColor, // Placeholder
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              // Title and Artist
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      audio.title,
                      style: Theme.of(context).textTheme.displaySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      audio.artist,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Favorite Icon Button
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : AppColors.textSecondary,
                ),
                onPressed: onFavoritePressed,
              ),
              // Remove Button (Conditional) -- ADDED
              if (onRemovePressed != null)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppColors.error,
                  onPressed: onRemovePressed, // Call the callback
                ),
            ],
          ),
        ),
      ),
    );
  }
}
