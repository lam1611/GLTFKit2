
#import <Foundation/Foundation.h>
#import <GLTFKit2/GLTFAsset.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFAssetReader : NSObject

+ (void)loadAssetWithURL:(NSURL *)url
         cacheAnimations:(NSURL *)cacheAnimations
           overrideCache:(BOOL)overrideCache
                 options:(NSDictionary<GLTFAssetLoadingOption, id> *)options
                 handler:(nullable GLTFAssetLoadingHandler)handler;

+ (void)loadAssetWithData:(NSData *)data
                  options:(NSDictionary<GLTFAssetLoadingOption, id> *)options
                  handler:(nullable GLTFAssetLoadingHandler)handler;

@end

NS_ASSUME_NONNULL_END
