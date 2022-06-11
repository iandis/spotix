#import "SpotifyClientPlugin.h"
#if __has_include(<spotify_client/spotify_client-Swift.h>)
#import <spotify_client/spotify_client-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "spotify_client-Swift.h"
#endif

@implementation SpotifyClientPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSpotifyClientPlugin registerWithRegistrar:registrar];
}
@end
