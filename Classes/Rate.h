#import <Cocoa/Cocoa.h>
#import <sqlite3.h>
#import "Currency.h"

@interface Rate : NSObject {
	sqlite3 *database;
	NSInteger primaryKey;
	Currency *fromCurrency;
	Currency *toCurrency;
	NSNumber *rate;
	NSDate *date;
}

@property (nonatomic, assign) NSInteger primaryKey;
@property (nonatomic, retain) Currency *fromCurrency;
@property (nonatomic, retain) Currency *toCurrency;
@property (nonatomic, retain) NSNumber *rate;
@property (nonatomic, retain) NSDate *date;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
- (void)delete;
- (void)save;

- (NSComparisonResult)compareDate:(Rate	*)rate;

@end
