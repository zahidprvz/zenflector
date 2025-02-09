import 'package:flutter/material.dart';
import 'package:zenflector/models/genre.dart';
import 'package:zenflector/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import

class GenreList extends StatelessWidget {
  final List<Genre> genres;
  final Function(Genre) onGenreSelected; // Callback for selection

  const GenreList({
    super.key,
    required this.genres,
    required this.onGenreSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120, // Adjust height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          return GestureDetector(
            onTap: () => onGenreSelected(genre),
            child: Container(
              width: 100, // Adjust width as needed
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Use CachedNetworkImage for efficient image loading
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                    child: genre.imageUrl != null && genre.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: genre.imageUrl!,
                            placeholder: (context, url) => Container(
                                color: AppColors
                                    .highlightColor), // Placeholder color
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            // Fallback if no image URL
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.highlightColor,
                              borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadius),
                            ),
                            child: const Icon(Icons.music_note,
                                color: Colors.white),
                          ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    genre.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
