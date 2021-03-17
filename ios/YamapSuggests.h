#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif
@import YandexMapsMobile;

@interface YamapSuggests: NSObject <RCTBridgeModule>

-(YMKSearchSuggestSession*_Nonnull) getSuggestClient;

@end
