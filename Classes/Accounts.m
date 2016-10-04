#import "Accounts.h"

@implementation Accounts

@synthesize deposits;
@synthesize receipts;
@synthesize expenses;
@synthesize debts;
@synthesize archive;
@synthesize smarts;
@synthesize allReceipts;
@synthesize allExpenses;
@synthesize allDeposits;
@synthesize allDebts;

- (id)initWithDatabase:(sqlite3 *)db {
	if (self == [super init]) {	
		database = db;
		
		deposits = [[NSMutableArray alloc] init];
		receipts = [[NSMutableArray alloc] init];
		expenses = [[NSMutableArray alloc] init];
		debts = [[NSMutableArray alloc] init];
		archive = [[NSMutableArray alloc] init];
		smarts = [[NSMutableArray alloc] init];
		allReceipts = [[NSMutableArray alloc] init];
		allExpenses = [[NSMutableArray alloc] init];
        allDeposits = [[NSMutableArray alloc] init];
        allDebts = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)reload {
	[deposits removeAllObjects];
	[receipts removeAllObjects];
	[expenses removeAllObjects];
	[debts removeAllObjects];
	[archive removeAllObjects];
	[smarts removeAllObjects];
	[allReceipts removeAllObjects];
	[allExpenses removeAllObjects];
	[allDeposits removeAllObjects];
    [allDebts removeAllObjects];
    
	NSString *sql = @"SELECT id FROM accounts WHERE type_id = ? AND enable = ? ORDER BY order_id";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, 1);
		sqlite3_bind_int(statement, 2, YES);
	
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Account *account = [[[Account alloc] initWithPrimaryKey:sqlite3_column_int(statement, 0) database:database] autorelease];
			[deposits addObject:[account retain]];
		}
	}
	
	sqlite3_reset(statement);

	sql = @"SELECT id FROM accounts WHERE type_id = ? AND enable = ? ORDER BY order_id";
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, 0);
		sqlite3_bind_int(statement, 2, YES);
	
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Account *account = [[[Account alloc] initWithPrimaryKey:sqlite3_column_int(statement, 0) database:database] autorelease];
			[receipts addObject:[account retain]];
		}
	}
	
	sqlite3_reset(statement);
	
	sql = @"SELECT id FROM accounts WHERE type_id = ? AND enable = ? ORDER BY order_id";
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, 2);
		sqlite3_bind_int(statement, 2, YES);
	
		while (sqlite3_step(statement) == SQLITE_ROW) {	
			Account *account = [[[Account alloc] initWithPrimaryKey:sqlite3_column_int(statement, 0) database:database] autorelease];
			[expenses addObject:[account retain]];
		}
	}
	
	sqlite3_reset(statement);
	
	sql = @"SELECT id FROM accounts WHERE type_id = ? AND enable = ? ORDER BY order_id";
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, 3);
		sqlite3_bind_int(statement, 2, YES);
	
		while (sqlite3_step(statement) == SQLITE_ROW) {				
			Account *account = [[[Account alloc] initWithPrimaryKey:sqlite3_column_int(statement, 0) database:database] autorelease];
			[debts addObject:[account retain]];
		}
	}
	
	sqlite3_reset(statement);
	
	sql = @"SELECT id FROM accounts WHERE enable = ? ORDER BY order_id";
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, NO);
	
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Account *account = [[[Account alloc] initWithPrimaryKey:sqlite3_column_int(statement, 0) database:database] autorelease];
			[archive addObject:[account retain]];	
		}
	}
	
	sqlite3_reset(statement);
	
	sql = @"SELECT id FROM smart_accounts WHERE enable = ? ORDER BY order_id";
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, YES);
	
		while (sqlite3_step(statement) == SQLITE_ROW) {
			SmartAccount *account = [[[SmartAccount alloc] initWithPrimaryKey:sqlite3_column_int(statement, 0) database:database] autorelease];
			[smarts addObject:[account retain]];
		}
	}
	
	sqlite3_reset(statement);
	
	sql = @"SELECT id FROM accounts WHERE type_id = ? ORDER BY order_id";
		
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, 0);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Account *account = [[[Account alloc] initWithPrimaryKey:sqlite3_column_int(statement, 0) database:database] autorelease];
			[allReceipts addObject:[account retain]];
		}
	}
	
	sqlite3_reset(statement);
	
	sql = @"SELECT id FROM accounts WHERE type_id = ? ORDER BY order_id";
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, 2);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {	
			Account *account = [[[Account alloc] initWithPrimaryKey:sqlite3_column_int(statement, 0) database:database] autorelease];
			[allExpenses addObject:[account retain]];
		}
	}
	
    sqlite3_reset(statement);
    
    sql = @"SELECT id FROM accounts WHERE type_id = ? ORDER BY order_id";
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, 1);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {	
			Account *account = [[[Account alloc] initWithPrimaryKey:sqlite3_column_int(statement, 0) database:database] autorelease];
			[allDeposits addObject:[account retain]];
		}
	}

    sqlite3_reset(statement);
    
    sql = @"SELECT id FROM accounts WHERE type_id = ? ORDER BY order_id";
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, 4);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {	
			Account *account = [[[Account alloc] initWithPrimaryKey:sqlite3_column_int(statement, 0) database:database] autorelease];
			[allDebts addObject:[account retain]];
		}
	}
	
	sqlite3_finalize(statement);
}

- (void)dealloc {
	[deposits release];
	[receipts release];
	[expenses release];
	[debts release];
	[archive release];
	[smarts release];
	[allReceipts release];
	[allExpenses release];
    [allDeposits release];
    [allDebts release];
	[super dealloc];
}

@end
