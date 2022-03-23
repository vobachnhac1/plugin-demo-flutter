#import "SamplePluginFlutterPlugin.h"
#if __has_include(<sample_plugin_flutter_nhacvo/sample_plugin_flutter_nhacvo-Swift.h>)
#import <sample_plugin_flutter_nhacvo/sample_plugin_flutter_nhacvo-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "sample_plugin_flutter_nhacvo-Swift.h"
#endif

@implementation SamplePluginFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSamplePluginFlutterPlugin registerWithRegistrar:registrar];
}
@end
