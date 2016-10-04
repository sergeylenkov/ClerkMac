#import "License.h"

@implementation License

+ (BOOL)checkLicenseForName:(NSString *)name andKey:(NSString *)key {
	name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
	name = [name stringByAppendingString:@"42FH7D"];
	name = [name stringByAppendingString:@"J67GB0"];
	name = [name uppercaseString];
	
	key = [key stringByReplacingOccurrencesOfString:@"-" withString:@""];
	key = [key stringByReplacingOccurrencesOfString:@" " withString:@""];
	key = [key uppercaseString];
	
	HashValue *value = [HashValue md5HashWithData:[name dataUsingEncoding:NSUTF8StringEncoding]];
	NSString *hash = [[value description] substringToIndex:25];
	hash = [hash uppercaseString];

	if ([hash isEqualToString:key]) {
		return YES;
	}
	
	return NO;
}

@end
