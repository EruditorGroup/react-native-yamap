#import "YamapSuggests.h"

@import YandexMapsMobile;

@implementation YamapSuggests {
    YMKSearchManager *searchManager;
    YMKSearchSuggestSession *suggestClient;
}

-(id)init {
    self = [super init];
    
    searchManager = [[YMKSearch sharedInstance] createSearchManagerWithSearchManagerType:YMKSearchSearchManagerTypeOnline];
    
    return self;
}

// TODO: Этот метод можно вынести в отдельный файл утилей, но пока в этом нет необходимости.
void runOnMainQueueWithoutDeadlocking(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

-(YMKSearchSuggestSession*_Nonnull) getSuggestClient {
    if (suggestClient) {
        return suggestClient;
    }
    runOnMainQueueWithoutDeadlocking(^{
        self->suggestClient = [self->searchManager createSuggestSession];
    });
    return suggestClient;
}

RCT_EXPORT_METHOD(suggest:(nonnull NSString*) searchQuery
                resolver:(RCTPromiseResolveBlock) resolve
                rejecter:(RCTPromiseRejectBlock) reject {
    @try {
        YMKSearchSuggestSession* session = [self getSuggestClient];
        
        YMKPoint* southWestPoint = [YMKPoint pointWithLatitude:-90.0 longitude:-180.0];
        YMKPoint* northEastPoint = [YMKPoint pointWithLatitude:90.0 longitude:180.0];
        YMKBoundingBox* defaultBoundingBox = [YMKBoundingBox boundingBoxWithSouthWest:southWestPoint northEast:northEastPoint];
        YMKSuggestOptions* suggestOptions = [YMKSuggestOptions suggestOptionsWithSuggestTypes: YMKSuggestTypeGeo
                                                                                 userPosition:nil
                                                                                 suggestWords:true];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [session suggestWithText:searchQuery
                              window:defaultBoundingBox
                      suggestOptions:suggestOptions
                     responseHandler:^(NSArray<YMKSuggestItem *> * _Nullable suggestList, NSError * _Nullable error){
                if (error) {
                    reject(@"FATAL_ERROR", @"Error during suggest processing", error);
                    return;
                }
                
                NSMutableArray *suggestsToPass = [NSMutableArray new];
                for (YMKSuggestItem* suggest in suggestList) {
                    NSMutableDictionary *suggestToPass = [NSMutableDictionary new];
                    
                    [suggestToPass setValue:[[suggest title] text] forKey:@"title"];
                    [suggestToPass setValue:[[suggest subtitle] text] forKey:@"subtitle"];
                    [suggestToPass setValue:[suggest uri] forKey:@"uri"];
                    
                    [suggestsToPass addObject:suggestToPass];
                }
                
                resolve(suggestsToPass);
            }];
        });
    }
    @catch ( NSException *error ) {
        reject(@"FATAL_ERROR", @"Error during suggest recieving", nil);
    }
})

RCT_EXPORT_METHOD(resetSuggest: (NSString*) ususedParam
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject {
    @try {
        if (suggestClient) {
            [suggestClient reset];
        }
        resolve(@[]);
    }
    @catch( NSException *error ) {
        reject(@"ERROR", @"Error during reset suggestions", nil);
    }
})

RCT_EXPORT_MODULE();

@end
