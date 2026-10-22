import 'package:flutter/material.dart';

/// Wrapper section landing page — konten terpusat dengan lebar maksimum
/// agar tetap rapi di layar desktop/web lebar.
class SectionContainer extends StatelessWidget {
  const SectionContainer({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.maxWidth = 1140,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color,
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
          child: child,
        ),
      ),
    );
  }
}
