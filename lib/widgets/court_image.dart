import 'package:flutter/material.dart';

/// Placeholder foto lapangan — gradasi warna + ikon padel,
/// selalu tampil tanpa ketergantungan jaringan.
/// Jika [asset] diberikan, tampilkan foto asli dari asset.
class CourtImage extends StatelessWidget {
  const CourtImage({
    super.key,
    required this.colors,
    this.asset,
    this.width,
    this.height,
    this.borderRadius = 0,
    this.iconSize = 44,
    this.fit = BoxFit.cover,
  });

  final List<Color> colors;
  final String? asset;
  final double? width;
  final double? height;
  final double borderRadius;
  final double iconSize;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (asset != null) {
      image = Image.asset(
        asset!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    } else {
      image = _placeholder();
    }

    if (borderRadius > 0) {
      return ClipRRect(borderRadius: BorderRadius.circular(borderRadius), child: image);
    }
    return image;
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.sports_tennis,
          color: Colors.white.withValues(alpha: 0.75),
          size: iconSize,
        ),
      ),
    );
  }
}
