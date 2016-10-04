#import <CommonCrypto/CommonDigest.h>
#import "HashValue.h"

@interface License : NSObject {
}

+ (BOOL)checkLicenseForName:(NSString *)name andKey:(NSString *)key;

@end