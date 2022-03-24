#import "ClvNhacvoPrintPlugin.h"
#if __has_include(<clv_nhacvo_print/clv_nhacvo_print-Swift.h>)
#import <clv_nhacvo_print/clv_nhacvo_print-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "clv_nhacvo_print-Swift.h"
#endif

@implementation ClvNhacvoPrintPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftClvNhacvoPrintPlugin registerWithRegistrar:registrar];
}
@end
