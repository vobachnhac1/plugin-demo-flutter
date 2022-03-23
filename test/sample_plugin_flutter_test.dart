import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sample_plugin_flutter_nhacvo/sample_plugin_flutter_nhacvo.dart';

void main() {
  const MethodChannel channel = MethodChannel('sample_plugin_flutter_nhacvo');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await SamplePluginFlutter.platformVersion, '42');
  });
}
