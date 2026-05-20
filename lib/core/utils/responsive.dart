import 'package:flutter/material.dart';

class Responsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double safeAreaHorizontal;
  static late double safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late bool isMobile;
  static late bool isTablet;
  static late bool isDesktop;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;

    isMobile = screenWidth < 600;
    isTablet = screenWidth >= 600 && screenWidth < 1200;
    isDesktop = screenWidth >= 1200;
  }

  // Responsive width
  static double w(double percentage) => blockSizeHorizontal * percentage;
  
  // Responsive height
  static double h(double percentage) => blockSizeVertical * percentage;
  
  // Responsive font size
  static double sp(double size) {
    double scaleFactor = screenWidth / 375; // Base width (iPhone X)
    return size * scaleFactor.clamp(0.8, 1.3);
  }

  // Responsive padding
  static EdgeInsets padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    if (all != null) {
      return EdgeInsets.all(w(all));
    }
    return EdgeInsets.only(
      left: left != null ? w(left) : (horizontal != null ? w(horizontal) : 0),
      right: right != null ? w(right) : (horizontal != null ? w(horizontal) : 0),
      top: top != null ? h(top) : (vertical != null ? h(vertical) : 0),
      bottom: bottom != null ? h(bottom) : (vertical != null ? h(vertical) : 0),
    );
  }

  // Get responsive value based on screen size
  static T value<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  // Grid cross axis count based on screen size
  static int gridCount({int mobile = 2, int tablet = 3, int desktop = 4}) {
    return value(mobile: mobile, tablet: tablet, desktop: desktop);
  }
}

// Extension for easy access
extension ResponsiveExtension on num {
  double get w => Responsive.w(toDouble());
  double get h => Responsive.h(toDouble());
  double get sp => Responsive.sp(toDouble());
}
