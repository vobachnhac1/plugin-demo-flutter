import 'dart:async';

import 'package:flutter/services.dart';
export 'src/src.dart';

class SamplePluginFlutter {
  static const MethodChannel _channel = MethodChannel('com.clv.demo/battery');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
