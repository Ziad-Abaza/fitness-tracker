import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class ExerciseImage extends StatelessWidget {
  final String gifPath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ExerciseImage({
    super.key,
    required this.gifPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (gifPath.isEmpty) {
      return _buildPlaceholder(width, height);
    }

    final bool isAsset = gifPath.startsWith('assets/');

    if (isAsset) {
      return Image.asset(
        gifPath,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: 300, // Optimize memory for thumbnails
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Image.asset error ($gifPath): $error');
          return _buildPlaceholder(width, height);
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return frame == null ? _buildLoading(width, height) : child;
        },
      );
    } else {
      return Image.file(
        File(gifPath),
        width: width,
        height: height,
        fit: fit,
        cacheWidth: 300,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Image.file error ($gifPath): $error');
          return _buildPlaceholder(width, height);
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return frame == null ? _buildLoading(width, height) : child;
        },
      );
    }
  }

  static Widget _buildPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.fitness_center, color: AppTheme.textSecondary, size: 24),
      ),
    );
  }

  static Widget _buildLoading(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: AppTheme.surface.withOpacity(0.5),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
        ),
      ),
    );
  }
}
