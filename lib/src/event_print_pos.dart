import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class EventPrintPos {
  static const MethodChannel channel = MethodChannel('com.clv.demo/battery');
  static const MethodChannel channelPrint = MethodChannel('com.clv.demo/print');

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
    var result = await channelPrint.invokeMethod("onPrint", _sendData);
    print(result);
    return result;
  }
}
