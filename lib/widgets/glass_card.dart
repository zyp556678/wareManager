import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding,
    this.margin,
    this.blur = 10,
    this.opacity = 0.7,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassColor = isDark
        ? Colors.black.withValues(alpha: opacity)
        : Colors.white.withValues(alpha: opacity);
    final border = borderColor ??
        (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.3));

    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Border? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassColor = color ??
        (isDark
            ? Colors.black.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.7));
    final defaultBorder = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.3);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ?? Border.all(color: defaultBorder, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}