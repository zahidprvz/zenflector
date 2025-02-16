import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zenflector/models/audio.dart';
import 'package:zenflector/utils/constants.dart';

class AudioCard extends StatelessWidget {
  final Audio audio;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final VoidCallback? onRemovePressed; // For playlist removal

  const AudioCard({
    super.key,
    required this.audio,
    required this.onTap,
    required this.isFavorite,
    required this.onFavoritePressed,
    this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDarkMode ? Colors.white : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppConstants.borderRadius)),
                child: CachedNetworkImage(
                  imageUrl: audio.imageUrl ?? '',
                  placeholder: (context, url) =>
                      Container(color: AppColors.highlightColor),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          audio.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? Colors.red
                              : Theme.of(context)
                                  .iconTheme
                                  .color, // Uses theme's icon color
                        ),
                        onPressed: onFavoritePressed,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                      if (onRemovePressed != null)
                        IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: onRemovePressed,
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: iconColor,
                            ))
                    ],
                  ),
                  Text(
                    audio.artist,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (audio.description != null &&
                      audio.description!.isNotEmpty) // Check for null or empty
                    Text(
                      audio.description!.length > 50 // Limit to 50 characters
                          ? '${audio.description!.substring(0, 50)}...'
                          : audio.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2, // Limit to two lines
                      overflow: TextOverflow.ellipsis, // Handle overflow
                    ),
                  Text(
                    '${audio.duration ~/ 60}m',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
