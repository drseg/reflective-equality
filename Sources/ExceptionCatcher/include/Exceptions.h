#import <Foundation/Foundation.h>

@interface Exceptions : NSObject

+ (BOOL)intercept:(void(^)())tryBlock error:(__autoreleasing NSError **)error;

@end
