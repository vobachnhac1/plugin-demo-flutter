import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:sample_plugin_flutter_nhacvo/src/batteryLevel.dart';
import 'package:sample_plugin_flutter_nhacvo/sample_plugin_flutter_nhacvo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _batteryLevel = 'Unknown';

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      batteryLevel = await BatteryLevel.getBatteryLevel();
    } on PlatformException {
      batteryLevel = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, and we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await SamplePluginFlutter.platformVersion ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                child: const Text('Get Battery Level'),
                onPressed: _getBatteryLevel,
              ),
              Text(_batteryLevel),

              /// Phần 2. Hướng dẫn tạo Widget với plugin
              SampleButton(
                text: "Sample Button",
                onPressed: () {
                  print("Sample Button Click");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
