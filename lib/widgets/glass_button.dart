import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final bool isSelected;

  const GlassButton({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 16,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.isSelected = false,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ??
        (widget.isSelected
            ? colorScheme.primary.withValues(alpha: 0.9)
            : (isDark
                ? Colors.white.withValues(alpha: 0.1)
                : colorScheme.onSurface.withValues(alpha: 0.08)));

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.isSelected
                ? null
                : Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              color: widget.isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class GlassIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color? iconColor;
  final bool isSelected;

  const GlassIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 44,
    this.iconColor,
    this.isSelected = false,
  });

  @override
  State<GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<GlassIconButton> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = widget.isSelected
        ? colorScheme.primary.withValues(alpha: 0.9)
        : colorScheme.onSurface.withValues(alpha: 0.1);
    final iColor = widget.iconColor ??
        (widget.isSelected ? colorScheme.onPrimary : colorScheme.onSurface);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.icon,
          color: iColor,
          size: widget.size * 0.5,
        ),
      ),
    );
  }
}