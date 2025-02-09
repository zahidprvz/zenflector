import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zenflector/models/playlist.dart';
import 'package:zenflector/utils/constants.dart';

class PlaylistItem extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;

  const PlaylistItem({
    super.key,
    required this.playlist,
    required this.onTap,
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
              // Playlist Image (optional)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.highlightColor, // Placeholder
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                  child:
                      playlist.imageUrl != null && playlist.imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: playlist.imageUrl!,
                              placeholder: (context, url) =>
                                  Container(color: AppColors.highlightColor),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.playlist_play,
                              color: Colors.white), // Fallback icon
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              // Playlist Name
              Expanded(
                child: Text(
                  playlist.name,
                  style: Theme.of(context).textTheme.displaySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
