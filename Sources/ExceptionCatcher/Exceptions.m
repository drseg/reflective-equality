#import "Exceptions.h"

@implementation Exceptions

+ (BOOL)intercept:(void(^)())tryBlock error:(__autoreleasing NSError **)error {
    @try {
        tryBlock();
        return YES;
    }
    @catch (NSException *exception) {
        *error = [[NSError alloc] initWithDomain:exception.name
                                            code:0
                                        userInfo:exception.userInfo];
        return NO;
    }
}

@end
