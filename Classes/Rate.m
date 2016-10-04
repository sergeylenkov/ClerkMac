#import "Rate.h"

@implementation Rate

@synthesize primaryKey;
@synthesize fromCurrency;
@synthesize toCurrency;
@synthesize rate;
@synthesize date;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db {
	if (self == [super init]) {	
		database = db;
		primaryKey = pk;
		
		if (primaryKey == -1) {
			self.rate = [NSNumber numberWithInt:0];
			self.date = [NSDate date];
		} else	{
			NSString *sql = @"SELECT from_currency_id, to_currency_id, rate, date FROM rates WHERE id = ?";
			sqlite3_stmt *statement;
			
			if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
				sqlite3_bind_int(statement, 1, primaryKey);
				
				if (sqlite3_step(statement) == SQLITE_ROW) {
					self.fromCurrency = [[[Currency alloc] initWithPrimaryKey:sqlite3_column_int(statement, 0) database:database] autorelease];
					self.toCurrency = [[[Currency alloc] initWithPrimaryKey:sqlite3_column_int(statement, 1) database:database] autorelease];
					self.rate = [NSNumber numberWithDouble:sqlite3_column_double(statement, 2)];
					self.date = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 3)];
				}
			}
			
			sqlite3_finalize(statement);
		}
	}
	
	return self;
}

- (void)delete {
	NSString *sql = @"DELETE FROM rates WHERE id = ?";
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
	
	components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];
	
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	
	self.date = [calendar dateFromComponents:components];
	
	if (primaryKey == -1) {
		NSString *sql = @"INSERT INTO rates (from_currency_id, to_currency_id, rate, date) VALUES (?, ?, ?, ?)";
		sqlite3_stmt *statement;
		
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			sqlite3_bind_int(statement, 1, fromCurrency.primaryKey);
			sqlite3_bind_int(statement, 2, toCurrency.primaryKey);
			sqlite3_bind_double(statement, 3, [rate doubleValue]);
			sqlite3_bind_double(statement, 4, [date timeIntervalSince1970]);
			
			if (sqlite3_step(statement) == SQLITE_DONE) {
				primaryKey = sqlite3_last_insert_rowid(database);
			}
		}
		
		sqlite3_finalize(statement);
	} else {	
		NSString *sql = @"UPDATE rates SET from_currency_id = ?, to_currency_id = ?, rate = ?, date = ? WHERE id = ?";
		sqlite3_stmt *statement;
		
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			sqlite3_bind_int(statement, 5, primaryKey);
			sqlite3_bind_int(statement, 1, fromCurrency.primaryKey);
			sqlite3_bind_int(statement, 2, toCurrency.primaryKey);
			sqlite3_bind_double(statement, 3, [rate doubleValue]);
			sqlite3_bind_double(statement, 4, [date timeIntervalSince1970]);
			
			sqlite3_step(statement);			
		}
		
		sqlite3_finalize(statement);
	}
}

- (NSComparisonResult)compareDate:(Rate	*)compareRate {
	if ([date timeIntervalSince1970] < [compareRate.date timeIntervalSince1970]) {
		return NSOrderedAscending;
	} else if ([date timeIntervalSince1970] > [compareRate.date timeIntervalSince1970]) {
		return NSOrderedDescending;
	}
	
	return NSOrderedSame;
}

- (void)dealloc {
	[fromCurrency release];
	[toCurrency release];
	[rate release];
	[date release];
	[super dealloc];
}

@end
