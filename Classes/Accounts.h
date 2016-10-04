#import <Cocoa/Cocoa.h>
#import <sqlite3.h>
#import "Account.h"
#import "SmartAccount.h"

@interface Accounts : NSObject {
	sqlite3 *database;		
	NSMutableArray *deposits;
	NSMutableArray *receipts;
	NSMutableArray *expenses;
	NSMutableArray *debts;
	NSMutableArray *archive;
	NSMutableArray *smarts;
	NSMutableArray *allReceipts;
	NSMutableArray *allExpenses;
    NSMutableArray *allDeposits;
    NSMutableArray *allDebts;
}

@property (nonatomic, retain) NSMutableArray *deposits;
@property (nonatomic, retain) NSMutableArray *receipts;
@property (nonatomic, retain) NSMutableArray *expenses;
@property (nonatomic, retain) NSMutableArray *debts;
@property (nonatomic, retain) NSMutableArray *archive;
@property (nonatomic, retain) NSMutableArray *smarts;
@property (nonatomic, retain) NSMutableArray *allReceipts;
@property (nonatomic, retain) NSMutableArray *allExpenses;
@property (nonatomic, retain) NSMutableArray *allDeposits;
@property (nonatomic, retain) NSMutableArray *allDebts;

- (id)initWithDatabase:(sqlite3 *)db;
- (void)reload;

@end
