#import "Account.h"

@implementation Account

@synthesize primaryKey;
@synthesize name;
@synthesize type;
@synthesize currency;
@synthesize iconIndex;
@synthesize orderIndex;
@synthesize enable;
@synthesize created;
@synthesize updated;
@synthesize amount;
@synthesize icon;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db {
	if (self == [super init]) {	
		database = db;
		primaryKey = pk;
		
		if (primaryKey == -1) {			
			self.name = @"";
			self.type = 0;
			self.iconIndex = 0;
			self.orderIndex = 0;
			self.enable = YES;
			self.created = [NSDate date];
			self.updated = [NSDate date];
		} else {
			NSString *sql = @"SELECT name, type_id, currency_id, icon_id, order_id, enable, created_at, updated_at FROM accounts WHERE id = ?";
			sqlite3_stmt *statement;
		
			if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
				sqlite3_bind_int(statement, 1, primaryKey);
			
				if (sqlite3_step(statement) == SQLITE_ROW) {
					self.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
					self.type = sqlite3_column_int(statement, 1);
					self.currency = [[[Currency alloc] initWithPrimaryKey:sqlite3_column_int(statement, 2) database:database] autorelease];
					self.iconIndex = sqlite3_column_int(statement, 3);
					self.orderIndex = sqlite3_column_int(statement, 4);
					self.enable = sqlite3_column_int(statement, 5);
					self.created = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 6)];
					self.updated = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 7)];					
				}
			}
			
			sqlite3_finalize(statement);
		}
		
		NSString *bundlePath = [[NSBundle mainBundle] resourcePath];
		self.icon = [[[NSImage alloc] initWithContentsOfFile:[bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.png", iconIndex]]] autorelease];
	}
		
	return self;
}

- (NSNumber *)balance {
	float receipt_sum = 0.0;
	float expense_sum = 0.0;
		
	NSString *sql = @"SELECT TOTAL(to_account_amount) FROM transactions WHERE to_account_id = ? AND enable = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, primaryKey);
		sqlite3_bind_int(statement, 2, YES);
	
		if (sqlite3_step(statement) == SQLITE_ROW) {
			receipt_sum = sqlite3_column_double(statement, 0);
		}
	}
	
	sqlite3_reset(statement);
		
	sql = @"SELECT TOTAL(from_account_amount) FROM transactions WHERE from_account_id = ? AND enable = ?";	
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, primaryKey);
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
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:byDate];		
	
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
		endDate = [NSDate date];
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
				
		endDate = [calendar dateFromComponents:components];
		
		[firstDay release];
	}
	
	if (period == 3) {		
		startDate = [NSDate date];
		
		components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:startDate];
		[components setDay:1];
		
		startDate = [calendar dateFromComponents:components];

		NSRange dayRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:startDate];
		
		components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:startDate];
		[components setDay:dayRange.length];
		
		endDate = [calendar dateFromComponents:components];	
	}
	
	if (period == 4) {
		startDate = [NSDate date];
		
		components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:startDate];
		[components setMonth:[components month] - 1];
		[components setDay:1];
		
		startDate = [calendar dateFromComponents:components];
				
		NSRange dayRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:startDate];
		
		components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:startDate];
		[components setDay:dayRange.length];
		
		endDate = [calendar dateFromComponents:components];
	}
	
	NSString *sql = @"SELECT id FROM transactions WHERE (to_account_id = ? OR from_account_id = ?) AND enable = ? AND date >= ? AND date <= ? ORDER BY date DESC, id DESC";	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, primaryKey);
		sqlite3_bind_int(statement, 2, primaryKey);
		sqlite3_bind_int(statement, 3, YES);
		sqlite3_bind_double(statement, 4, [[startDate truncate] timeIntervalSince1970]);
		sqlite3_bind_double(statement, 5, [[endDate truncate] timeIntervalSince1970]);
		
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
					if (nameRange.location != NSNotFound || toRange.location != NSNotFound) {
						[results addObject:transaction];
					}
				}
				
				if (type == 1) {
					if (nameRange.location != NSNotFound || fromRange.location != NSNotFound || toRange.location != NSNotFound) {
						[results addObject:transaction];
					}
				}
				
				if (type == 2 || type == 3) {
					if (nameRange.location != NSNotFound || fromRange.location != NSNotFound) {
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
	
	NSString *sql = @"SELECT id FROM transactions WHERE (to_account_id = ? OR from_account_id = ?) AND enable = ? AND date >= ? AND date <= ? ORDER BY date DESC, id DESC";	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, primaryKey);
		sqlite3_bind_int(statement, 2, primaryKey);
		sqlite3_bind_int(statement, 3, YES);
		sqlite3_bind_double(statement, 4, [[fromDate truncate] timeIntervalSince1970]);
		sqlite3_bind_double(statement, 5, [[toDate truncate] timeIntervalSince1970]);
		
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
					if (nameRange.location != NSNotFound || toRange.location != NSNotFound) {
						[results addObject:transaction];
					}
				}
				
				if (type == 1) {
					if (nameRange.location != NSNotFound || fromRange.location != NSNotFound || toRange.location != NSNotFound) {
						[results addObject:transaction];
					}
				}
				
				if (type == 2 || type == 3) {
					if (nameRange.location != NSNotFound || fromRange.location != NSNotFound) {
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
	NSString *sql = @"DELETE FROM transactions WHERE (to_account_id = ? OR from_account_id = ?)";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, primaryKey);
		sqlite3_bind_int(statement, 2, primaryKey);
		sqlite3_step(statement);
	}
	
	sqlite3_finalize(statement);
	
	sql = @"DELETE FROM accounts WHERE id = ?";
		
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, primaryKey);
		sqlite3_step(statement);
	}
	
	sqlite3_finalize(statement);
}

- (void)save {
	self.updated = [NSDate date];
	
	if (primaryKey == -1) {
		NSString *sql = @"INSERT INTO accounts (name, type_id, currency_id, icon_id, order_id, enable, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
		sqlite3_stmt *statement;
	
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(statement, 2, type);
			sqlite3_bind_int(statement, 3, currency.primaryKey);
			sqlite3_bind_int(statement, 4, iconIndex);
			sqlite3_bind_int(statement, 5, [self lastOrderIndex]);
			sqlite3_bind_int(statement, 6, enable);
			sqlite3_bind_double(statement, 7, [[NSDate date] timeIntervalSince1970]);
			sqlite3_bind_double(statement, 8, [updated timeIntervalSince1970]);
			
			if (sqlite3_step(statement) == SQLITE_DONE) {
				primaryKey = sqlite3_last_insert_rowid(database);
				
				if ([amount intValue] > 0) {
					Transaction *transaction = [[Transaction alloc] initWithPrimaryKey:-1 database:database];
					transaction.fromAccountAmount = amount;
					transaction.toAccountAmount = amount;
					transaction.name = @"Initial transaction";
					
					if (type == 0 || type == 1) {
						transaction.toAccount = self;
					}
					
					if (type == 2 || type == 3) {
						transaction.fromAccount = self;
					}
					
					[transaction save];
				}
			}
		}
		
		sqlite3_finalize(statement);
	} else 	{	
		NSString *sql = @"UPDATE accounts SET name = ?, type_id = ?, currency_id = ?, icon_id = ?, order_id = ?, enable = ?, updated_at = ? WHERE id = ?";
		sqlite3_stmt *statement;
		
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			sqlite3_bind_int(statement, 8, primaryKey);
			sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(statement, 2, type);
			sqlite3_bind_int(statement, 3, currency.primaryKey);
			sqlite3_bind_int(statement, 4, iconIndex);
			sqlite3_bind_int(statement, 5, orderIndex);
			sqlite3_bind_int(statement, 6, enable);
			sqlite3_bind_double(statement, 7, [updated timeIntervalSince1970]);
			
			sqlite3_step(statement);
		}
		
		sqlite3_finalize(statement);
	}
}

- (NSInteger)lastOrderIndex {
	NSInteger index = 0;
	
	NSString *sql = @"SELECT MAX(order_id) FROM accounts WHERE type_id = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, type);
		
		if (sqlite3_step(statement) == SQLITE_ROW) {
			index = sqlite3_column_int(statement, 0);
		}
	}
	
	sqlite3_finalize(statement);
	
	return index;
}

- (NSComparisonResult)compareBalance:(Account *)account {
	if ([[self balance] floatValue] > [[account balance] floatValue]) {
		return NSOrderedAscending;
	} else if ([[self balance] floatValue] < [[account balance] floatValue]) {
		return NSOrderedDescending;
	}
	
	return NSOrderedSame;
}

- (void)dealloc {
	[name release];
	[currency release];
	[created release];
	[updated release];
	[icon release];
	[super dealloc];
}

@end