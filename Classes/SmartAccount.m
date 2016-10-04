#import "SmartAccount.h"

@implementation SmartAccount

@synthesize primaryKey;
@synthesize name;
@synthesize type;
@synthesize currency;
@synthesize orderIndex;
@synthesize enable;
@synthesize date;
@synthesize lastUpdate;
@synthesize amount;
@synthesize filters;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db {
	if (self == [super init]) {	
		database = db;
		primaryKey = pk;
		
		/*if (primaryKey == -1) {			
			self.name = @"";
			self.type = 0;
			self.orderIndex = 0;
			self.enable = YES;
			self.date = [NSDate date];
			self.lastUpdate = [NSDate date];
			//self.filters = [[NSMutableArray alloc] init];
		} else {
			NSString *sql = @"SELECT name, type_id, currency_id, order_id, enable, date, last_update FROM smart_accounts WHERE id = ?";
			sqlite3_stmt *statement;
			
			if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
				sqlite3_bind_int(statement, 1, primaryKey);
				
				if (sqlite3_step(statement) == SQLITE_ROW) {
					self.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
					self.type = sqlite3_column_int(statement, 1);
					self.currency = [[[Currency alloc] initWithPrimaryKey:sqlite3_column_int(statement, 2) database:database] autorelease];
					self.orderIndex = sqlite3_column_int(statement, 3);
					self.enable = sqlite3_column_int(statement, 4);
					self.date = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 5)];
					self.lastUpdate = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 6)];					
				}
			}
			
			sqlite3_finalize(statement);
		}*/
	}
	
	return self;
}

- (NSNumber *)balance {
	float receipt_sum = 0.0;
	float expense_sum = 0.0;
	
	NSString *sql = @"SELECT TOTAL(t.to_account_amount) FROM transactions t, accounts a WHERE a.type_id = ? AND t.to_account_id = a.id AND t.enable = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, type);
		sqlite3_bind_int(statement, 2, YES);
		
		if (sqlite3_step(statement) == SQLITE_ROW) {
			receipt_sum = sqlite3_column_double(statement, 0);
		}
	}
	
	sqlite3_reset(statement);
	
	sql = @"SELECT TOTAL(t.from_account_amount) FROM transactions t, accounts a WHERE a.type_id = ? AND t.from_account_id = ? AND t.enable = ?";	
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, type);
		sqlite3_bind_int(statement, 2, YES);
		
		if (sqlite3_step(statement) == SQLITE_ROW) {
			expense_sum = sqlite3_column_double(statement, 0);
		}
	}
	
	sqlite3_finalize(statement);	
	
	float total;
	
	if (type == 0 || type == 3) {
		total = expense_sum - receipt_sum;
	} else {
		total = receipt_sum - expense_sum;
	}
	
	return [NSNumber numberWithFloat:total];
}

- (NSNumber *)balanceForDate:(NSDate *)byDate {
	NSString *sql = @"SELECT TOTAL(to_account_amount) FROM transactions WHERE to_account_id = ? AND enable = ? AND date = ?";
	sqlite3_stmt *statement;
	float receipt_sum = 0.0;
	float expense_sum = 0.0;	
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:byDate];		
	
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	
	byDate = [calendar dateFromComponents:components];
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, primaryKey);
		sqlite3_bind_int(statement, 2, YES);
		sqlite3_bind_double(statement, 3, [byDate timeIntervalSince1970]);		
		
		if (sqlite3_step(statement) == SQLITE_ROW) {
			receipt_sum = sqlite3_column_double(statement, 0);
		}		
	}
	
	sqlite3_reset(statement);
	
	sql = @"SELECT TOTAL(from_account_amount) FROM transactions WHERE from_account_id = ? AND enable = ? AND date = ?";
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, primaryKey);
		sqlite3_bind_int(statement, 2, YES);
		sqlite3_bind_double(statement, 3, [byDate timeIntervalSince1970]);
		
		if (sqlite3_step(statement) == SQLITE_ROW) {
			expense_sum = sqlite3_column_double(statement, 0);
		}
	}
	
	sqlite3_finalize(statement);	
	
	float total = 0.0;
	
	if (type == 0) {
		total = expense_sum - receipt_sum;
	} else {
		total = receipt_sum - expense_sum;
	}
	
	return [NSNumber numberWithFloat:total];
}

- (NSMutableArray *)transactions {
	NSMutableArray *results = [[[NSMutableArray alloc] init] autorelease];
	
	NSString *sql = @"SELECT id FROM transactions WHERE (to_account_id = ? OR from_account_id = ?) AND enable = ? ORDER BY date DESC, id DESC";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, primaryKey);
		sqlite3_bind_int(statement, 2, primaryKey);
		sqlite3_bind_int(statement, 3, YES);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Transaction *transaction = [[[Transaction alloc] initWithPrimaryKey:sqlite3_column_int(statement, 0) database:database] autorelease];
			[results addObject:transaction];
		}
	}
	
	sqlite3_finalize(statement);
	
	return results;
}

- (NSMutableArray *)transactionsByPeriod:(NSInteger)period withFilter:(NSString *)filter {
	NSMutableArray *results = [[[NSMutableArray alloc] init] autorelease];
	NSDate *startDate;
	NSDate *endDate;
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components;
	
	if (period == 0) {
		startDate = [NSDate dateWithTimeIntervalSince1970:0];
		endDate = [NSDate date];
	}
	
	if (period == 1) {
		startDate = [NSDate date];
		components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:startDate];	
		[components setHour:0];
		[components setMinute:0];
		[components setSecond:0];
		
		startDate = [calendar dateFromComponents:components];
		
		endDate = [NSDate date];
		
		components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:endDate];	
		[components setHour:0];
		[components setMinute:0];
		[components setSecond:0];
		
		endDate = [calendar dateFromComponents:components];
	}
	
	if (period == 2) {
		startDate = [NSDate date];		
		components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit) fromDate:startDate];
		NSDateComponents *firstDay = [[NSDateComponents alloc] init];
		
		[firstDay setWeekday:[calendar firstWeekday]];
		[firstDay setWeek:[components week]];
		[firstDay setMonth:[components month]];
		[firstDay setYear:[components year]];
		
		startDate = [calendar dateFromComponents:firstDay];
		
		components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:startDate];
		
		[components setDay:[components day] + 7];
		[components setHour:0];
		[components setMinute:0];
		[components setSecond:0];		
		
		endDate = [calendar dateFromComponents:components];
		
		[firstDay release];
	}
	
	if (period == 3) {		
		startDate = [NSDate date];
		
		components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:startDate];
		[components setDay:1];
		[components setHour:0];
		[components setMinute:0];
		[components setSecond:0];
		
		startDate = [calendar dateFromComponents:components];
		
		NSRange dayRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:startDate];
		
		components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:startDate];
		[components setDay:dayRange.length];
		[components setHour:0];
		[components setMinute:0];
		[components setSecond:0];
		
		endDate = [calendar dateFromComponents:components];	
	}
	
	if (period == 4) {
		startDate = [NSDate date];
		
		components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:startDate];
		[components setMonth:[components month] - 1];
		[components setDay:1];
		[components setHour:0];
		[components setMinute:0];
		[components setSecond:0];
		
		startDate = [calendar dateFromComponents:components];
		
		NSRange dayRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:startDate];
		
		components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:startDate];
		[components setDay:dayRange.length];
		[components setHour:0];
		[components setMinute:0];
		[components setSecond:0];
		
		endDate = [calendar dateFromComponents:components];
	}
	
	NSString *sql = @"";
	
	if (type == 0) {
		sql = @"SELECT t.id FROM transactions t, accounts a WHERE a.type_id = ? AND t.from_account_id = a.id AND t.enable = ? AND t.date >= ? AND t.date <= ? ORDER BY t.date DESC, t.id DESC";	
	}
	
	if (type == 2) {
		sql = @"SELECT t.id FROM transactions t, accounts a WHERE a.type_id = ? AND t.to_account_id = a.id AND t.enable = ? AND t.date >= ? AND t.date <= ? ORDER BY t.date DESC, t.id DESC";	
	}
	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, type);
		sqlite3_bind_int(statement, 2, YES);
		sqlite3_bind_double(statement, 3, [startDate timeIntervalSince1970]);
		sqlite3_bind_double(statement, 4, [endDate timeIntervalSince1970]);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int key = sqlite3_column_int(statement, 0);
			
			Transaction *transaction = [[[Transaction alloc] initWithPrimaryKey:key database:database] autorelease];
			
			if ([filter isEqualToString:@""]) { 
				[results addObject:transaction];
			} else {
				NSRange nameRange = [[transaction.name lowercaseString] rangeOfString:[filter lowercaseString]];
				NSRange fromRange = [[transaction.fromAccount.name lowercaseString] rangeOfString:[filter lowercaseString]];
				NSRange toRange = [[transaction.toAccount.name lowercaseString] rangeOfString:[filter lowercaseString]];
				
				if (type == 0) {
					if (nameRange.location != NSNotFound || fromRange.location != NSNotFound) {
						[results addObject:transaction];
					}
				}
				
				if (type == 2) {
					if (nameRange.location != NSNotFound || toRange.location != NSNotFound) {
						[results addObject:transaction];
					}
				}
			}
		}
	}
	
	sqlite3_finalize(statement);
	
	return results;
}

- (NSMutableArray *)transactionsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate withFilter:(NSString *)filter {
	NSMutableArray *results = [[[NSMutableArray alloc] init] autorelease];
	
	NSString *sql = @"";
	
	if (type == 0) {
		sql = @"SELECT t.id FROM transactions t, accounts a WHERE a.type_id = ? AND t.from_account_id = a.id AND t.enable = ? AND t.date >= ? AND t.date <= ? ORDER BY t.date DESC, t.id DESC";	
	}
	
	if (type == 2) {
		sql = @"SELECT t.id FROM transactions t, accounts a WHERE a.type_id = ? AND t.to_account_id = a.id AND t.enable = ? AND t.date >= ? AND t.date <= ? ORDER BY t.date DESC, t.id DESC";	
	}
	
	//NSString *sql = @"SELECT id FROM transactions WHERE (to_account_id = ? OR from_account_id = ?) AND enable = ? AND date >= ? AND date <= ? ORDER BY date DESC, id DESC";	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, type);
		sqlite3_bind_int(statement, 2, YES);
		sqlite3_bind_double(statement, 3, [fromDate timeIntervalSince1970]);
		sqlite3_bind_double(statement, 4, [toDate timeIntervalSince1970]);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int key = sqlite3_column_int(statement, 0);
			
			Transaction *transaction = [[[Transaction alloc] initWithPrimaryKey:key database:database] autorelease];
			
			if ([filter isEqualToString:@""]) { 
				[results addObject:transaction];
			} else {
				NSRange nameRange = [[transaction.name lowercaseString] rangeOfString:[filter lowercaseString]];
				NSRange fromRange = [[transaction.fromAccount.name lowercaseString] rangeOfString:[filter lowercaseString]];
				NSRange toRange = [[transaction.toAccount.name lowercaseString] rangeOfString:[filter lowercaseString]];
				
				if (type == 0) {
					if (nameRange.location != NSNotFound || fromRange.location != NSNotFound) {
						[results addObject:transaction];
					}
				}
				
				if (type == 2) {
					if (nameRange.location != NSNotFound || toRange.location != NSNotFound) {
						[results addObject:transaction];
					}
				}
			}
		}
	}
	
	sqlite3_finalize(statement);
	
	return results;
}

- (NSMutableArray *)transactionNames {
	NSMutableArray *results = [[[NSMutableArray alloc] init] autorelease];
	
	NSString *sql = @"SELECT name FROM transactions WHERE (to_account_id = ? OR from_account_id = ?) AND enable = ? GROUP BY name ORDER BY name";	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, primaryKey);
		sqlite3_bind_int(statement, 2, primaryKey);
		sqlite3_bind_int(statement, 3, YES);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			[results addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]];
		}
	}
	
	sqlite3_finalize(statement);
	
	return results;
}

- (NSDate *)minDate {
	NSString *sql = @"SELECT MIN(date) FROM transactions WHERE (to_account_id = ? OR from_account_id = ?) AND enable = ?";
	sqlite3_stmt *statement;
	NSDate *value = [NSDate date];
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, primaryKey);
		sqlite3_bind_int(statement, 2, primaryKey);
		sqlite3_bind_int(statement, 3, YES);
		
		if (sqlite3_step(statement) == SQLITE_ROW) {
			value = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 0)];
		}
	}
	
	sqlite3_finalize(statement);
	
	return value;
}

- (NSDate *)maxDate {
	NSString *sql = @"SELECT MAX(date) FROM transactions WHERE (to_account_id = ? OR from_account_id = ?) AND enable = ?";
	sqlite3_stmt *statement;
	NSDate *value = [NSDate date];
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, primaryKey);
		sqlite3_bind_int(statement, 2, primaryKey);
		sqlite3_bind_int(statement, 3, YES);
		
		if (sqlite3_step(statement) == SQLITE_ROW) {
			value = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 0)];
		}
	}
	
	sqlite3_finalize(statement);
	
	return value;
}

- (void)delete {
	NSString *sql = @"DELETE FROM smart_accounts WHERE id = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, primaryKey);
		sqlite3_step(statement);
	}
	
	sqlite3_finalize(statement);
}

- (void)save {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components;
	
	components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
	
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	
	self.date = [calendar dateFromComponents:components];
	self.lastUpdate = [NSDate date];
	
	if (primaryKey == -1) {
		NSString *sql = @"INSERT INTO smart_accounts (name, type_id, currency_id, order_id, enable, date, last_update) VALUES (?, ?, ?, ?, ?, ?, ?)";
		sqlite3_stmt *statement;
		
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(statement, 2, type);
			sqlite3_bind_int(statement, 3, currency.primaryKey);
			sqlite3_bind_int(statement, 4, orderIndex);
			sqlite3_bind_int(statement, 5, enable);
			sqlite3_bind_double(statement, 6, [date timeIntervalSince1970]);
			sqlite3_bind_double(statement, 7, [lastUpdate timeIntervalSince1970]);
			
			if (sqlite3_step(statement) == SQLITE_DONE) {
				primaryKey = sqlite3_last_insert_rowid(database);				
			}
		}
		
		sqlite3_finalize(statement);
	} else 	{	
		NSString *sql = @"UPDATE smart_accounts SET name = ?, type_id = ?, currency_id = ?, order_id = ?, enable = ?, date = ?, last_update = ? WHERE id = ?";
		sqlite3_stmt *statement;
		
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			sqlite3_bind_int(statement, 8, primaryKey);
			sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(statement, 2, type);
			sqlite3_bind_int(statement, 3, currency.primaryKey);
			sqlite3_bind_int(statement, 4, orderIndex);
			sqlite3_bind_int(statement, 5, enable);
			sqlite3_bind_double(statement, 6, [date timeIntervalSince1970]);
			sqlite3_bind_double(statement, 7, [lastUpdate timeIntervalSince1970]);
			
			sqlite3_step(statement);			
		}
		
		sqlite3_finalize(statement);
	}
}

- (void)dealloc {
	[name release];
	[currency release];
	[date release];
	[lastUpdate release];
	[filters release];
	[super dealloc];
}

@end