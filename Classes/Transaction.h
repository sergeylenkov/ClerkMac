#import <Cocoa/Cocoa.h>
#import <sqlite3.h>
#import "NSDate+Format.h"
#import "Account.h"

@class Account;

@interface Transaction : NSObject {
	sqlite3 *database;	
	NSInteger primaryKey;
	NSString *name;
	Account *fromAccount;
	Account *toAccount;
	NSNumber *fromAccountAmount;
	NSNumber *toAccountAmount;
	BOOL enable;
	NSDate *date;
	NSDate *updated;
}

@property (nonatomic, assign) NSInteger primaryKey;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) Account *fromAccount;
@property (nonatomic, retain) Account *toAccount;
@property (nonatomic, retain) NSNumber *fromAccountAmount;
@property (nonatomic, retain) NSNumber *toAccountAmount;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSDate *updated;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
- (void)delete;
- (void)save;

- (NSComparisonResult)compareDate:(Transaction *)transaction;

@end