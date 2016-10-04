#import <Cocoa/Cocoa.h>
#import <sqlite3.h>
#import "Account.h"

@interface Scheduler : NSObject {
	sqlite3 *database;	
	NSInteger primaryKey;
	NSString *name;
	NSInteger periodType;
	NSInteger day;
	NSInteger month;
	Account *fromAccount;
	Account *toAccount;
	NSNumber *fromAccountAmount;
	NSNumber *toAccountAmount;
	BOOL enable;
	NSDate *nextDate;
	NSDate *lastDate;
	NSDate *date;
	NSDate *lastUpdate;
}

@property (nonatomic, assign) NSInteger primaryKey;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger periodType;
@property (nonatomic, assign) NSInteger day;
@property (nonatomic, assign) NSInteger month;
@property (nonatomic, retain) Account *fromAccount;
@property (nonatomic, retain) Account *toAccount;
@property (nonatomic, retain) NSNumber *fromAccountAmount;
@property (nonatomic, retain) NSNumber *toAccountAmount;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, retain) NSDate *nextDate;
@property (nonatomic, retain) NSDate *lastDate;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSDate *lastUpdate;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
- (void)calculateNextDate;
- (void)delete;
- (void)save;

- (NSComparisonResult)compareName:(Scheduler *)scheduler;
- (NSComparisonResult)compareDate:(Scheduler *)scheduler;

@end
