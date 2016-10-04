#import "Currency.h"

static sqlite3 *database;

@implementation Currency

@synthesize primaryKey;
@synthesize name;
@synthesize shortName;
@synthesize isEnabled;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db {
	if (self == [super init]) {	
		database = db;
		primaryKey = pk;
		
		if (primaryKey == -1) {	
			self.name = @"";
			self.shortName = @"";
            self.isEnabled = NO;
		} else	{
			NSString *sql = @"SELECT name, short_name, enabled FROM currencies WHERE id = ?";
			sqlite3_stmt *statement;
			
			if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
				sqlite3_bind_int(statement, 1, primaryKey);
			
				if (sqlite3_step(statement) == SQLITE_ROW) {
					self.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
					self.shortName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                    self.isEnabled = sqlite3_column_int(statement, 2);
				}
			}
			
			sqlite3_finalize(statement);
		}
	}

	return self;
}

- (void)delete {
	NSString *sql = @"DELETE FROM currencies WHERE id = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, primaryKey);
		sqlite3_step(statement);		
	}
	
	sqlite3_finalize(statement);
}

- (void)save {
	if (primaryKey == -1) {
		NSString *sql = @"INSERT INTO currencies (name, short_name, enabled) VALUES (?, ?, ?)";
		sqlite3_stmt *statement;
		
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(statement, 2, [shortName UTF8String], -1, SQLITE_TRANSIENT);		
            sqlite3_bind_int(statement, 3, isEnabled);
            
			if (sqlite3_step(statement) == SQLITE_DONE) {
				primaryKey = sqlite3_last_insert_rowid(database);
			}
		}
		
		sqlite3_finalize(statement);
	} else {	
		NSString *sql = @"UPDATE currencies SET name = ?, short_name = ?, enabled = ? WHERE id = ?";
		sqlite3_stmt *statement;
		
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			sqlite3_bind_int(statement, 4, primaryKey);
			sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(statement, 2, [shortName UTF8String], -1, SQLITE_TRANSIENT);		
            sqlite3_bind_int(statement, 3, isEnabled);
            
			sqlite3_step(statement);			
		}
		
		sqlite3_finalize(statement);
	}
}

+ (float)convertAmount:(NSNumber *)amount fromCurrency:(Currency *)fromCurrency toCurrency:(Currency *)toCurrency onDate:(NSDate *)onDate {
	if (fromCurrency.primaryKey == toCurrency.primaryKey) {
		return [amount floatValue];
	}
	
	NSString *sql = @"SELECT rate FROM rates WHERE from_currency_id = ? AND to_currency_id = ? AND date < ? ORDER BY date DESC LIMIT 1";
	sqlite3_stmt *statement;
	
	onDate = [[onDate dateByAddingDays:1] truncate];
	float rate = 1.0;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, fromCurrency.primaryKey);
		sqlite3_bind_int(statement, 2, toCurrency.primaryKey);
		sqlite3_bind_double(statement, 3, [onDate timeIntervalSince1970]);
		
		if (sqlite3_step(statement) == SQLITE_ROW) {
			rate = sqlite3_column_double(statement, 0);
		}
	}
	
	sqlite3_finalize(statement);	
	
	if (rate != 1.0) {		
		return [amount floatValue] / rate;
	}
	
	sql = @"SELECT rate FROM rates WHERE from_currency_id = ? AND to_currency_id = ? AND date < ? ORDER BY date DESC LIMIT 1";
	rate = 1.0;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, toCurrency.primaryKey);
		sqlite3_bind_int(statement, 2, fromCurrency.primaryKey);
		sqlite3_bind_double(statement, 3, [onDate timeIntervalSince1970]);
		
		if (sqlite3_step(statement) == SQLITE_ROW) {
			rate = sqlite3_column_double(statement, 0);
		}
	}
	
	sqlite3_finalize(statement);

	if (rate != 1.0) {		
		return [amount floatValue] * rate;
	}
	
	sql = @"SELECT rate FROM rates WHERE from_currency_id = ? AND to_currency_id = ? AND date > ? ORDER BY date LIMIT 1";
	rate = 1.0;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, fromCurrency.primaryKey);
		sqlite3_bind_int(statement, 2, toCurrency.primaryKey);
		sqlite3_bind_double(statement, 3, [onDate timeIntervalSince1970]);
		
		if (sqlite3_step(statement) == SQLITE_ROW) {
			rate = sqlite3_column_double(statement, 0);
		}
	}
	
	sqlite3_finalize(statement);
	
	if (rate != 1.0) {		
		return [amount floatValue] / rate;
	}
	
	sql = @"SELECT rate FROM rates WHERE from_currency_id = ? AND to_currency_id = ? AND date > ? ORDER BY date LIMIT 1";
	rate = 1.0;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, toCurrency.primaryKey);
		sqlite3_bind_int(statement, 2, fromCurrency.primaryKey);
		sqlite3_bind_double(statement, 3, [onDate timeIntervalSince1970]);
		
		if (sqlite3_step(statement) == SQLITE_ROW) {
			rate = sqlite3_column_double(statement, 0);
		}
	}
	
	sqlite3_finalize(statement);
	
	if (rate != 1.0) {		
		return [amount floatValue] * rate;
	}
	
	return [amount floatValue];
}

- (void)dealloc {
	[name release];
	[shortName release];
	[super dealloc];
}

@end