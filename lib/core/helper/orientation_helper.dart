import 'package:flutter/services.dart';

class OrientationHelper {

  static void portrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  static void landscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  static void reset() {
    SystemChrome.setPreferredOrientations(
        DeviceOrientation.values);
  }
}