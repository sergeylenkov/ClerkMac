#import <Cocoa/Cocoa.h>
#import <sqlite3.h>
#import "NSDate+Format.h"
#import "Currency.h"
#import "Transaction.h"

@interface Account : NSObject {
	sqlite3 *database;	
	NSInteger primaryKey;
	NSString *name;
	NSInteger type;
	Currency *currency;
	NSInteger iconIndex;
	NSInteger orderIndex;
	BOOL enable;
	NSDate *created;
	NSDate *updated;
	NSNumber *amount;
	NSImage *icon;
}

@property (nonatomic, assign) NSInteger primaryKey;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, retain) Currency *currency;
@property (nonatomic, assign) NSInteger iconIndex;
@property (nonatomic, assign) NSInteger orderIndex;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, retain) NSDate *created;
@property (nonatomic, retain) NSDate *updated;
@property (nonatomic, retain) NSNumber *amount;
@property (nonatomic, retain) NSImage *icon;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
- (NSNumber *)balance;
- (NSNumber *)balanceForDate:(NSDate *)byDate;
- (NSMutableArray *)transactions;
- (NSMutableArray *)transactionsByPeriod:(NSInteger)period withFilter:(NSString *)filter;
- (NSMutableArray *)transactionsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate withFilter:(NSString *)filter;
- (NSMutableArray *)transactionNames;
- (NSDate *)minDate;
- (NSDate *)maxDate;
- (void)delete;
- (void)save;
- (NSInteger)lastOrderIndex;
- (NSComparisonResult)compareBalance:(Account *)account;

@end