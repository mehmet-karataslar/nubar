import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NubarAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String? fallbackText;
  final VoidCallback? onTap;

  const NubarAvatar({
    super.key,
    this.imageUrl,
    this.radius = 24,
    this.fallbackText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                placeholder: (context, url) => Icon(
                  Icons.person,
                  size: radius,
                  color: Theme.of(context).colorScheme.primary,
                ),
                errorWidget: (context, url, error) => _fallbackWidget(context),
              ),
            )
          : _fallbackWidget(context),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }

  Widget _fallbackWidget(BuildContext context) {
    if (fallbackText != null && fallbackText!.isNotEmpty) {
      return Text(
        fallbackText![0].toUpperCase(),
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
    return Icon(
      Icons.person,
      size: radius,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
