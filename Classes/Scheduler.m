#import "Scheduler.h"

@implementation Scheduler

@synthesize primaryKey;
@synthesize name;
@synthesize periodType;
@synthesize day;
@synthesize month;
@synthesize fromAccount;
@synthesize toAccount;
@synthesize fromAccountAmount;
@synthesize toAccountAmount;
@synthesize enable;
@synthesize nextDate;
@synthesize lastDate;
@synthesize date;
@synthesize lastUpdate;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db {
	if (self == [super init]) {	
		database = db;
		primaryKey = pk;
		
		if (primaryKey == -1) {	
			self.name = @"";
			self.periodType = 0;
			self.day = 1;
			self.month = 1;
			self.fromAccountAmount = [NSNumber numberWithInt:0];
			self.toAccountAmount = [NSNumber numberWithInt:0];
			self.enable = YES;
			self.nextDate = [NSDate date];
			self.lastDate = [NSDate date];
			self.date = [NSDate date];
			self.lastUpdate = [NSDate date];
		} else	{
			NSString *sql = @"SELECT name, period_type, day, month, from_account_id, to_account_id, from_account_amount, to_account_amount, enable, next_date, last_date, date, last_update FROM schedulers WHERE id = ?";
			sqlite3_stmt *statement;
			
			if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {				
				sqlite3_bind_int(statement, 1, primaryKey);
				
				if (sqlite3_step(statement) == SQLITE_ROW) {
					self.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
					self.periodType = sqlite3_column_int(statement, 1);
					self.day = sqlite3_column_int(statement, 2);
					self.month = sqlite3_column_int(statement, 3);
					self.fromAccount = [[[Account alloc] initWithPrimaryKey:sqlite3_column_int(statement, 4) database:database] autorelease];
					self.toAccount = [[[Account alloc] initWithPrimaryKey:sqlite3_column_int(statement, 5) database:database] autorelease];
					self.fromAccountAmount = [NSNumber numberWithDouble:sqlite3_column_double(statement, 6)];
					self.toAccountAmount = [NSNumber numberWithDouble:sqlite3_column_double(statement, 7)];
					self.enable = sqlite3_column_int(statement, 8);
					self.nextDate = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 9)];
					self.lastDate = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 10)];
					self.date = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 11)];
					self.lastUpdate = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 12)];
				}
			}
			
			sqlite3_finalize(statement);
		}
	}
	
	return self;
}

- (void)calculateNextDate {
	NSCalendar *calendar = [NSCalendar currentCalendar];

	if (periodType == 0) {
		NSDateComponents *components = [[NSDateComponents alloc] init];
		[components setDay:1];
		
		self.nextDate = [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
		[components release];
	}
	
	if (periodType == 1) {
		NSDateComponents *components = [[NSDateComponents alloc] init];
		[components setDay:day - 1];
		
		NSDateComponents *weekComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit) fromDate:[NSDate date]];
		NSDateComponents *firstDay = [[NSDateComponents alloc] init];
		
		[firstDay setWeekday:[calendar firstWeekday]];
		[firstDay setWeek:[weekComponents week] + 1];
		[firstDay setMonth:[weekComponents month]];
		[firstDay setYear:[weekComponents year]];
		
		self.nextDate = [calendar dateFromComponents:firstDay];
		self.nextDate = [calendar dateByAddingComponents:components toDate:nextDate options:0];
		
		[components release];
		[firstDay release];
	}
	
	if (periodType == 2) {
		NSDateComponents *components = [[NSDateComponents alloc] init];
		NSDateComponents *monthComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];

		[monthComponents setMonth:[monthComponents month] + 1];
		[monthComponents setDay:1];
		
		self.nextDate = [calendar dateFromComponents:monthComponents];

		NSRange dayRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:nextDate];

		if (day > dayRange.length) {
			self.day = dayRange.length;
		}
		
		[components setDay:day - 1];
		
		self.nextDate = [calendar dateByAddingComponents:components toDate:nextDate options:0];
		[components release];
	}
	
	if (periodType == 3) {
		NSDateComponents *components = [[NSDateComponents alloc] init];
		NSDateComponents *yearComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
		
		[yearComponents setYear:[yearComponents year] + 1];
		[yearComponents setMonth:month];
		[yearComponents setDay:1];
		
		self.nextDate = [calendar dateFromComponents:yearComponents];
		
		NSRange dayRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:nextDate];
		
		if (day > dayRange.length) {
			self.day = dayRange.length;
		}
		
		[components setDay:day - 1];
		
		self.nextDate = [calendar dateByAddingComponents:components toDate:nextDate options:0];
		[components release];
	}
	
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:nextDate];
	
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	
	self.nextDate = [calendar dateFromComponents:components];
}

- (void)delete {
	NSString *sql = @"DELETE FROM schedulers WHERE id = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, primaryKey);	
		sqlite3_step(statement);			
	}
	
	sqlite3_finalize(statement);
}

- (void)save {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
	
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	
	self.date = [calendar dateFromComponents:components];
	self.lastUpdate = [NSDate date];
	
	if (primaryKey == -1) {
		NSString *sql = @"INSERT INTO schedulers (name, period_type, day, month, from_account_id, to_account_id, from_account_amount, to_account_amount, enable, next_date, last_date, date, last_update) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
		sqlite3_stmt *statement;
		
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(statement, 2, periodType);
			sqlite3_bind_int(statement, 3, day);
			sqlite3_bind_int(statement, 4, month);
			sqlite3_bind_int(statement, 5, fromAccount.primaryKey);
			sqlite3_bind_int(statement, 6, toAccount.primaryKey);
			sqlite3_bind_double(statement, 7, [fromAccountAmount doubleValue]);
			sqlite3_bind_double(statement, 8, [toAccountAmount doubleValue]);
			sqlite3_bind_int(statement, 9, enable);
			sqlite3_bind_double(statement, 10, [nextDate timeIntervalSince1970]);
			sqlite3_bind_double(statement, 11, [lastDate timeIntervalSince1970]);
			sqlite3_bind_double(statement, 12, [date timeIntervalSince1970]);
			sqlite3_bind_double(statement, 13, [lastUpdate timeIntervalSince1970]);
			
			if (sqlite3_step(statement) == SQLITE_DONE) {
				primaryKey = sqlite3_last_insert_rowid(database);
			}
		}
		
		sqlite3_finalize(statement);
	} else {	
		NSString *sql = @"UPDATE schedulers SET name = ?, period_type = ?, day = ?, month = ?, from_account_id = ?, to_account_id = ?, from_account_amount = ?, to_account_amount = ?, enable = ?, next_date = ?, last_date = ?, date = ?, last_update = ? WHERE id = ?";
		sqlite3_stmt *statement;
		
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			sqlite3_bind_int(statement, 14, primaryKey);
			sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(statement, 2, periodType);
			sqlite3_bind_int(statement, 3, day);
			sqlite3_bind_int(statement, 4, month);
			sqlite3_bind_int(statement, 5, fromAccount.primaryKey);
			sqlite3_bind_int(statement, 6, toAccount.primaryKey);
			sqlite3_bind_double(statement, 7, [fromAccountAmount doubleValue]);
			sqlite3_bind_double(statement, 8, [toAccountAmount doubleValue]);
			sqlite3_bind_int(statement, 9, enable);
			sqlite3_bind_double(statement, 10, [nextDate timeIntervalSince1970]);
			sqlite3_bind_double(statement, 11, [lastDate timeIntervalSince1970]);
			sqlite3_bind_double(statement, 12, [date timeIntervalSince1970]);
			sqlite3_bind_double(statement, 13, [lastUpdate timeIntervalSince1970]);
			
			sqlite3_step(statement);			
		}
		
		sqlite3_finalize(statement);
	}
}

- (NSComparisonResult)compareName:(Scheduler *)scheduler {
	return [name localizedCompare:scheduler.name];
}

- (NSComparisonResult)compareDate:(Scheduler *)scheduler {
	if ([nextDate timeIntervalSince1970] < [scheduler.nextDate timeIntervalSince1970]) {
		return NSOrderedAscending;
	} else if ([nextDate timeIntervalSince1970] > [scheduler.nextDate timeIntervalSince1970]) {
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
	[nextDate release];
	[lastDate release];
	[date release];
	[lastUpdate release];
	[super dealloc];
}

@end
