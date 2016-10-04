#import <Cocoa/Cocoa.h>
#import <sqlite3.h>
#import "Currency.h"
#import "Transaction.h"

@interface SmartAccount : NSObject {
	sqlite3 *database;	
	NSInteger primaryKey;
	NSString *name;
	NSInteger type;
	Currency *currency;
	NSInteger orderIndex;
	BOOL enable;
	NSDate *date;
	NSDate *lastUpdate;
	NSNumber *amount;
	NSMutableArray *filters;
}

@property (nonatomic, assign) NSInteger primaryKey;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, retain) Currency *currency;
@property (nonatomic, assign) NSInteger orderIndex;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSDate *lastUpdate;
@property (nonatomic, retain) NSNumber *amount;
@property (nonatomic, retain) NSMutableArray *filters;

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

@end
