import 'package:flutter/material.dart';

class ResponsiveBreakpoints {
  const ResponsiveBreakpoints._(this.width);

  static const double compactMaxWidth = 700;
  static const double expandedMinWidth = 1100;
  static const double wideMinWidth = 1400;

  final double width;

  static ResponsiveBreakpoints of(BuildContext context) {
    return ResponsiveBreakpoints._(MediaQuery.sizeOf(context).width);
  }

  bool get isCompact => width < compactMaxWidth;
  bool get isMedium => width >= compactMaxWidth && width < expandedMinWidth;
  bool get isExpanded => width >= expandedMinWidth;
  bool get isWide => width >= wideMinWidth;

  double get pagePadding => isCompact ? 16 : 24;
}

class ResponsiveScaffoldBody extends StatelessWidget {
  const ResponsiveScaffoldBody({
    super.key,
    required this.child,
    this.maxWidth = 960,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.topCenter,
    this.useSafeArea = false,
    this.fillHeight = true,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;
  final bool useSafeArea;
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    final constrained = LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : maxWidth;
        final width = availableWidth > maxWidth ? maxWidth : availableWidth;

        return Align(
          alignment: alignment,
          child: SizedBox(
            width: width,
            height: fillHeight && constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : null,
            child: Padding(padding: padding, child: child),
          ),
        );
      },
    );

    if (!useSafeArea) return constrained;
    return SafeArea(child: constrained);
  }
}

class ResponsiveListConstraints extends StatelessWidget {
  const ResponsiveListConstraints({
    super.key,
    required this.child,
    this.maxWidth = 960,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffoldBody(maxWidth: maxWidth, child: child);
  }
}

class ResponsiveTwoColumn extends StatelessWidget {
  const ResponsiveTwoColumn({
    super.key,
    required this.leading,
    required this.trailing,
    this.spacing = 16,
    this.leadingFlex = 1,
    this.trailingFlex = 1,
    this.breakpoint = ResponsiveBreakpoints.expandedMinWidth,
  });

  final Widget leading;
  final Widget trailing;
  final double spacing;
  final int leadingFlex;
  final int trailingFlex;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < breakpoint) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          leading,
          SizedBox(height: spacing),
          trailing,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: leadingFlex, child: leading),
        SizedBox(width: spacing),
        Expanded(flex: trailingFlex, child: trailing),
      ],
    );
  }
}
