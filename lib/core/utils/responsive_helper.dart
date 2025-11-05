import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  /// Lấy số cột grid responsive
  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  /// Lấy padding responsive
  static double getHorizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 32;
    if (isTablet(context)) return 24;
    return 16;
  }

  /// Lấy hệ số kích thước font responsive
  static double getFontSizeMultiplier(BuildContext context) {
    if (isDesktop(context)) return 1.2;
    if (isTablet(context)) return 1.1;
    return 1.0;
  }

  /// Lấy chiều rộng card tối đa responsive
  static double getCardMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 400;
    if (isTablet(context)) return 350;
    return double.infinity;
  }

  /// Lấy chiều rộng dialog tối đa responsive
  static double getDialogMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 600;
    if (isTablet(context)) return 500;
    return MediaQuery.of(context).size.width * 0.9;
  }

  /// Lấy khoảng cách responsive
  static double getSpacing(BuildContext context, double baseSpacing) {
    if (isDesktop(context)) return baseSpacing * 1.5;
    if (isTablet(context)) return baseSpacing * 1.25;
    return baseSpacing;
  }
}

/// Widget xây dựng responsive
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  )
  builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return builder(context, isMobile, isTablet, isDesktop);
  }
}

/// Layout responsive cho các kích thước màn hình khác nhau
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 768) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
