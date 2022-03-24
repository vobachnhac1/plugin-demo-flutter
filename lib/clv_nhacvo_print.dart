import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class ClvNhacvoPrint {
  // static const MethodChannel _channel = MethodChannel('clv_nhacvo_print');
  static const MethodChannel channel = MethodChannel('com.clv.demo/battery');
  static const MethodChannel channelPrint = MethodChannel('com.clv.demo/print');

  static Future<String> get platformVersion async {
    final String version = await channel.invokeMethod('getPlatformVersion');
    return version;
  }

  // Get battery level.
  Future<String> getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await channel.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level: $result%.';
    } on PlatformException {
      batteryLevel = 'Failed to get battery level.';
    }
    return batteryLevel;
  }

  Future<String> getMessage() async {
    String value = "";
    try {
      value = await channelPrint.invokeMethod("getMessage");
    } catch (e) {
      print(e);
    }
    return value;
  }

  Future<dynamic> sendSignalPrint(Uint8List capturedImage) async {
    var _sendData = <String, dynamic>{
      "bitmapInput": capturedImage,
      "printerDpi": 190,
      "printerWidthMM": int.parse('80'),
      "printerNbrCharactersPerLine": 32,
      "widthMax": 580,
      "heightMax": 400,
    };
    try {
      var result = await channelPrint.invokeMethod("onPrint", _sendData);
      return result;
    } catch (e) {
      return null;
    }
  }
}
