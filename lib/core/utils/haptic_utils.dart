import 'package:flutter/services.dart';

class HapticUtils {
  HapticUtils._();

  static void lightTap() => HapticFeedback.lightImpact();
  static void mediumTap() => HapticFeedback.mediumImpact();
  static void heavyTap() => HapticFeedback.heavyImpact();
  static void success() => HapticFeedback.heavyImpact();
  static void selection() => HapticFeedback.selectionClick();
}
