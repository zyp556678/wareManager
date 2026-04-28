import 'package:flutter/material.dart';

class BentoGrid extends StatelessWidget {
  final List<BentoItem> items;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const BentoGrid({
    super.key,
    required this.items,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - (crossAxisCount - 1) * crossAxisSpacing) / crossAxisCount;
        return Wrap(
          spacing: crossAxisSpacing,
          runSpacing: mainAxisSpacing,
          children: items.map((item) {
            final span = item.span ?? 1;
            final width = itemWidth * span + (span - 1) * crossAxisSpacing;
            return SizedBox(
              width: width,
              height: item.height ?? 140,
              child: item,
            );
          }).toList(),
        );
      },
    );
  }
}

class BentoItem extends StatelessWidget {
  final Widget child;
  final int? span;
  final double? height;

  const BentoItem({
    super.key,
    required this.child,
    this.span,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
