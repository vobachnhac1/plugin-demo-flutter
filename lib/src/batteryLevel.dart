import 'dart:async';

import 'package:flutter/services.dart';

class BatteryLevel {
  static const MethodChannel channel = MethodChannel('com.clv.demo/battery');

  // Get battery level.
  static Future<String> getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await channel.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level: $result%.';
    } on PlatformException {
      batteryLevel = 'Failed to get battery level.';
    }
    return batteryLevel;
  }
}
