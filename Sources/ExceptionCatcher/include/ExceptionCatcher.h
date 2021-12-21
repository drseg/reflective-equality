#import <Foundation/Foundation.h>

@interface _ExceptionCatcher : NSObject

+ (BOOL)catchException:(void(^)())tryBlock error:(__autoreleasing NSError **)error;

@end
