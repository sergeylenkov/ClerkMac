#import <Cocoa/Cocoa.h>
#import <sqlite3.h>
#import "NSDate+Format.h"

@interface Currency : NSObject {
	NSInteger primaryKey;
	NSString *name;
	NSString *shortName;
    BOOL isEnabled;
}

@property (nonatomic, assign) NSInteger primaryKey;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *shortName;
@property (nonatomic, assign) BOOL isEnabled;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
- (void)delete;
- (void)save;

+ (float)convertAmount:(NSNumber *)amount fromCurrency:(Currency *)fromCurrency toCurrency:(Currency *)toCurrency onDate:(NSDate *)onDate;

@end
