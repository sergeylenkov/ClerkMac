#import "Transaction.h"
#import "Account.h"

@implementation Transaction

@synthesize primaryKey;
@synthesize name;
@synthesize fromAccount;
@synthesize toAccount;
@synthesize fromAccountAmount;
@synthesize toAccountAmount;
@synthesize enable;
@synthesize date;
@synthesize updated;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db {
	if (self == [super init]) {	
		database = db;
		primaryKey = pk;
				
		if (primaryKey == -1) {	
			self.name = @"";
			self.fromAccountAmount = [NSNumber numberWithInt:0];
			self.toAccountAmount = [NSNumber numberWithInt:0];
			self.enable = YES;
			self.date = [NSDate date];
			self.updated = [NSDate date];
		} else	{
			NSString *sql = @"SELECT name, from_account_id, to_account_id, from_account_amount, to_account_amount, enable, date, updated_at FROM transactions WHERE id = ?";
			sqlite3_stmt *statement;
		
			if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {				
				sqlite3_bind_int(statement, 1, primaryKey);
			
				if (sqlite3_step(statement) == SQLITE_ROW) {
					self.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
					self.fromAccount = [[[Account alloc] initWithPrimaryKey:sqlite3_column_int(statement, 1) database:database] autorelease];
					self.toAccount = [[[Account alloc] initWithPrimaryKey:sqlite3_column_int(statement, 2) database:database] autorelease];
					self.fromAccountAmount = [NSNumber numberWithDouble:sqlite3_column_double(statement, 3)];
					self.toAccountAmount = [NSNumber numberWithDouble:sqlite3_column_double(statement, 4)];
					self.enable = sqlite3_column_int(statement, 5);
					self.date = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 6)];
					self.updated = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 7)];
				}
			}
			
			sqlite3_finalize(statement);
		}
	}
		
	return self;
}

- (void)delete {
	NSString *sql = @"DELETE FROM transactions WHERE id = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, primaryKey);	
		sqlite3_step(statement);
	}
	
	sqlite3_finalize(statement);
}

- (void)save {	
	self.date = [date truncate];
	self.updated = [NSDate date];
	
	if (primaryKey == -1) {
		NSString *sql = @"INSERT INTO transactions (name, from_account_id, to_account_id, from_account_amount, to_account_amount, enable, date, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
		sqlite3_stmt *statement;
	
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(statement, 2, fromAccount.primaryKey);
			sqlite3_bind_int(statement, 3, toAccount.primaryKey);
			sqlite3_bind_double(statement, 4, [fromAccountAmount doubleValue]);
			sqlite3_bind_double(statement, 5, [toAccountAmount doubleValue]);
			sqlite3_bind_int(statement, 6, enable);
			sqlite3_bind_double(statement, 7, [date timeIntervalSince1970]);
			sqlite3_bind_double(statement, 8, [updated timeIntervalSince1970]);
			
			if (sqlite3_step(statement) == SQLITE_DONE) {
				primaryKey = sqlite3_last_insert_rowid(database);
			}
		}
		
		sqlite3_finalize(statement);
	} else {	
		NSString *sql = @"UPDATE transactions SET name = ?, from_account_id = ?, to_account_id = ?, from_account_amount = ?, to_account_amount = ?, enable = ?, date = ?, updated_at = ? WHERE id = ?";
		sqlite3_stmt *statement;
		
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			sqlite3_bind_int(statement, 9, primaryKey);
			sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(statement, 2, fromAccount.primaryKey);
			sqlite3_bind_int(statement, 3, toAccount.primaryKey);
			sqlite3_bind_double(statement, 4, [fromAccountAmount doubleValue]);
			sqlite3_bind_double(statement, 5, [toAccountAmount doubleValue]);
			sqlite3_bind_int(statement, 6, enable);
			sqlite3_bind_double(statement, 7, [date timeIntervalSince1970]);
			sqlite3_bind_double(statement, 8, [updated timeIntervalSince1970]);
		
			sqlite3_step(statement);
		}
		
		sqlite3_finalize(statement);
	}
}

- (NSComparisonResult)compareDate:(Transaction *)transaction {
	if ([date timeIntervalSince1970] < [transaction.date timeIntervalSince1970]) {
		return NSOrderedAscending;
	} else if ([date timeIntervalSince1970] > [transaction.date timeIntervalSince1970]) {
		return NSOrderedDescending;
	}
	
	return NSOrderedSame;
}

- (void)dealloc {
	[name release];
	[fromAccount release];
	[toAccount release];
	[fromAccountAmount release];
	[toAccountAmount release];
	[date release];
	[updated release];
	[super dealloc];
}

@end