#import "AppDelegate.h"

@implementation AppDelegate

@synthesize database;

- (void)awakeFromNib {
	[self createEditableCopyOfDatabaseIfNeeded];
	[self initializeDatabase];
	[self update];
    
	if (![mainWindow setFrameUsingName:@"Main"]) {
		[mainWindow center];
	}
		
	[mainWindow setAutorecalculatesContentBorderThickness:YES forEdge:NSMinYEdge];
	[mainWindow setContentBorderThickness:35 forEdge:NSMinYEdge];	

	accounts = [[Accounts alloc] initWithDatabase:database];

	menuController.database = database;
	menuController.mainWindow = mainWindow;
	menuController.accounts = accounts;
	 
	preferencesController = [[PrefsController alloc] init];
	preferencesController.database = database;
	
	lockController = [[LockController alloc] initWithNibName:@"LockView" bundle:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if ([defaults boolForKey:@"Require Password"]) {
		[lockController.view setFrame:[mainWindow.contentView bounds]];
		[mainWindow.contentView addSubview:lockController.view];
		
		[lockController focusPasswordField];
	}

	[menuController initialization];
	[menuController refresh];

	[[NSApplication sharedApplication] setApplicationIconImage:[NSImage imageNamed:@"IconWork.icns"]];
	
	[self scheduler];
	
	schedulerTimer = [[NSTimer timerWithTimeInterval:(3600.0 * 1) target:self selector:@selector(scheduler) userInfo:nil repeats:YES] retain];
	[[NSRunLoop currentRunLoop] addTimer:schedulerTimer forMode:NSDefaultRunLoopMode];
}

- (void)createEditableCopyOfDatabaseIfNeeded {
    NSError *error;
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportFolder = [paths objectAtIndex:0];   
	
	NSFileManager *fileManager = [NSFileManager defaultManager];

	applicationSupportFolder = [applicationSupportFolder stringByAppendingPathComponent:@"Clerk"];
	
	if (![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL]) {
        [fileManager createDirectoryAtPath:applicationSupportFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
	
	applicationSupportFolder = [applicationSupportFolder stringByAppendingPathComponent:@"Database.sqlite"];
	
    if ([fileManager fileExistsAtPath:applicationSupportFolder]) {
		return;
	}
	
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Database.sqlite"];
	
    if (![fileManager copyItemAtPath:defaultDBPath toPath:applicationSupportFolder error:&error]) {
        NSAssert1(NO, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

- (void)initializeDatabase {		
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);				
	NSString *applicationSupportFolder = [paths objectAtIndex:0];	
	
	applicationSupportFolder = [applicationSupportFolder stringByAppendingPathComponent:@"Clerk"];
	
	NSString *path = [applicationSupportFolder stringByAppendingPathComponent:@"Database.sqlite"];
	
	if (sqlite3_open([path UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);		
	}
}

- (void)scheduler {
	NSMutableArray *schedulers = [[NSMutableArray alloc] init];
	
	NSString *sql = @"SELECT id FROM schedulers WHERE enable = 1";	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Scheduler *scheduler = [[Scheduler alloc] initWithPrimaryKey:sqlite3_column_int(statement, 0) database:database];						
			[schedulers addObject:scheduler];
			[scheduler release];			
		}
	}
	
	sqlite3_reset(statement);
	
	BOOL isScheduled = NO;
	
	for (int i = 0; i < [schedulers count]; i++) {
		Scheduler *scheduler = [schedulers objectAtIndex:i];

		if ([scheduler.nextDate  compare:[NSDate date]] == NSOrderedAscending) {
			Transaction *transaction = [[Transaction alloc] initWithPrimaryKey:-1 database:database];
			
			transaction.name = scheduler.name;
			transaction.fromAccount = scheduler.fromAccount;
			transaction.toAccount = scheduler.toAccount;
			transaction.fromAccountAmount = scheduler.fromAccountAmount;
			transaction.toAccountAmount = scheduler.toAccountAmount;
			
			[transaction save];
			[transaction release];
			
			scheduler.lastDate = scheduler.nextDate;
			[scheduler calculateNextDate];
			[scheduler save];
			
			isScheduled = YES;
		}
	}
	
	if (isScheduled) {
		[menuController refreshView];
	}
		
	[schedulers release];
}

- (IBAction)preferences:(id)sender {
	[preferencesController showWindow:sender];
	[[preferencesController window] center];
	
	[preferencesController refresh];	
}

- (IBAction)visitWebSite:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://positiveteam.com"]];
}

- (void)update {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
	if ([[defaults objectForKey:@"Updated"] isEqualToString:version]) {
		return;
	}
    
    NSString *sql = @"SELECT enabled FROM currencies";
	sqlite3_stmt *statement;
    BOOL isNeedUpdateCurrencies = NO;
    
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
        isNeedUpdateCurrencies = YES;
    }

    sqlite3_finalize(statement);
    
    if (isNeedUpdateCurrencies) {
        NSMutableArray *currencies = [[[NSMutableArray alloc] init] autorelease];
        NSMutableArray *allAccounts = [[[NSMutableArray alloc] init] autorelease];
        NSMutableArray *rates = [[[NSMutableArray alloc] init] autorelease];
        
        sql = @"SELECT id, name, short_name FROM currencies";
	    
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                Currency *currency = [[[Currency alloc] init] autorelease];
                
                currency.primaryKey = sqlite3_column_int(statement, 0);
                currency.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                currency.shortName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];           
                
                [currencies addObject:currency];
            }
        }
        
        sqlite3_finalize(statement);
        
        sql = @"SELECT id, currency_id FROM accounts";
	    
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_int(statement, 1, 2);
            
            while (sqlite3_step(statement) == SQLITE_ROW) {	
                Account *account = [[[Account alloc] initWithPrimaryKey:sqlite3_column_int(statement, 0) database:database] autorelease];
                [allAccounts addObject:account];
                
                for (Currency *currency in currencies) {
                    if (currency.primaryKey == sqlite3_column_int(statement, 1)) {
                        account.currency = currency;
                        break;
                    }
                }
            }
        }
        
        sqlite3_finalize(statement);
        
        sql = @"SELECT id, from_currency_id, to_currency_id FROM rates";
		
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {		
            while (sqlite3_step(statement) == SQLITE_ROW) {
                Rate *rate = [[[Rate alloc] initWithPrimaryKey:sqlite3_column_int(statement, 0) database:database] autorelease];			
                [rates addObject:rate];
                
                for (Currency *currency in currencies) {
                    if (currency.primaryKey == sqlite3_column_int(statement, 1)) {
                        rate.fromCurrency = currency;
                    }
                    
                    if (currency.primaryKey == sqlite3_column_int(statement, 2)) {
                        rate.toCurrency = currency;
                    }
                }
            }
        }
        
        sqlite3_finalize(statement);
        
        sql = @"ALTER TABLE currencies ADD COLUMN enabled INTEGER";
	    
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_step(statement);		
        }
        
        sqlite3_finalize(statement);	
		
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Currencies.csv"];		
        NSString *txt = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSArray *items = [txt componentsSeparatedByString:@"\n"];
        
        NSString *deleteSQL = @"DELETE FROM currencies";
        NSString *insertSQL = @"INSERT INTO currencies (name, short_name, enabled) VALUES (?, ?, ?)";
        
        if (sqlite3_prepare_v2(database, [deleteSQL UTF8String], -1, &statement, NULL) == SQLITE_OK) {        
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }
        
        for (int i = 0; i < [items count]; i++) {
            NSArray *fields = [[items objectAtIndex:i] componentsSeparatedByString:@";"];
            
            if (sqlite3_prepare_v2(database, [insertSQL UTF8String], -1, &statement, NULL) == SQLITE_OK) {
                sqlite3_bind_text(statement, 1, [[fields objectAtIndex:1] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(statement, 2, [[fields objectAtIndex:0] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_int(statement, 3, NO);
                
                sqlite3_step(statement);
                sqlite3_finalize(statement);
            }
        }
        
        [txt release];
	    
        sql = @"UPDATE currencies SET enabled = ? WHERE short_name = ?";
        
        for (Currency *currency in currencies) {
            if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
                sqlite3_bind_int(statement, 1, YES);
                sqlite3_bind_text(statement, 2, [currency.shortName UTF8String], -1, SQLITE_TRANSIENT);
                
                sqlite3_step(statement);
                sqlite3_finalize(statement);
                
                if (currency.primaryKey == [defaults integerForKey:@"Base Currency"]) {
                    NSString *selectSQL = @"SELECT id FROM currencies WHERE short_name = ?";
                    sqlite3_stmt *selectStatement;
                    
                    if (sqlite3_prepare_v2(database, [selectSQL UTF8String], -1, &selectStatement, NULL) == SQLITE_OK) {
                        sqlite3_bind_text(selectStatement, 1, [currency.shortName UTF8String], -1, SQLITE_TRANSIENT);
                        
                        if (sqlite3_step(selectStatement) == SQLITE_ROW) {
                            [defaults setInteger:sqlite3_column_int(selectStatement, 0) forKey:@"Base Currency"];                        
                        }
                        
                        sqlite3_finalize(selectStatement);
                    }
                }
                
                if (currency.primaryKey == [defaults integerForKey:@"From Currency Index"]) {
                    NSString *selectSQL = @"SELECT id FROM currencies WHERE short_name = ?";
                    sqlite3_stmt *selectStatement;
                    
                    if (sqlite3_prepare_v2(database, [selectSQL UTF8String], -1, &selectStatement, NULL) == SQLITE_OK) {
                        sqlite3_bind_text(selectStatement, 1, [currency.shortName UTF8String], -1, SQLITE_TRANSIENT);
                        
                        if (sqlite3_step(selectStatement) == SQLITE_ROW) {
                            [defaults setInteger:sqlite3_column_int(selectStatement, 0) forKey:@"From Currency Index"];                        
                        }
                        
                        sqlite3_finalize(selectStatement);
                    }
                }
                
                if (currency.primaryKey == [defaults integerForKey:@"To Currency Index"]) {
                    NSString *selectSQL = @"SELECT id FROM currencies WHERE short_name = ?";
                    sqlite3_stmt *selectStatement;
                    
                    if (sqlite3_prepare_v2(database, [selectSQL UTF8String], -1, &selectStatement, NULL) == SQLITE_OK) {
                        sqlite3_bind_text(selectStatement, 1, [currency.shortName UTF8String], -1, SQLITE_TRANSIENT);
                        
                        if (sqlite3_step(selectStatement) == SQLITE_ROW) {
                            [defaults setInteger:sqlite3_column_int(selectStatement, 0) forKey:@"To Currency Index"];                        
                        }
                        
                        sqlite3_finalize(selectStatement);
                    }
                }
            }
        }    
        
        sql = @"UPDATE accounts SET currency_id = ? WHERE id = ?";
        NSString *selectSQL = @"SELECT id FROM currencies WHERE short_name = ?";
        sqlite3_stmt *selectStatement;
        
        for (Account *account in allAccounts) {
            if (sqlite3_prepare_v2(database, [selectSQL UTF8String], -1, &selectStatement, NULL) == SQLITE_OK) {
                sqlite3_bind_text(selectStatement, 1, [account.currency.shortName UTF8String], -1, SQLITE_TRANSIENT);
                
                if (sqlite3_step(selectStatement) == SQLITE_ROW) {
                    int index = sqlite3_column_int(selectStatement, 0);
                    
                    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
                        sqlite3_bind_int(statement, 1, index);
                        sqlite3_bind_int(statement, 2, account.primaryKey);
                        
                        sqlite3_step(statement);
                        sqlite3_finalize(statement);
                    }
                }
                
                sqlite3_finalize(selectStatement);
            }
        }
        
        sql = @"UPDATE rates SET from_currency_id = ?, to_currency_id = ? WHERE id = ?";
        selectSQL = @"SELECT id FROM currencies WHERE short_name = ?";
        
        for (Rate *rate in rates) {
            int fromIndex;
            int toIndex;
            
            if (sqlite3_prepare_v2(database, [selectSQL UTF8String], -1, &selectStatement, NULL) == SQLITE_OK) {
                sqlite3_bind_text(selectStatement, 1, [rate.fromCurrency.shortName UTF8String], -1, SQLITE_TRANSIENT);            
                
                if (sqlite3_step(selectStatement) == SQLITE_ROW) {
                    fromIndex = sqlite3_column_int(selectStatement, 0);
                }
                
                sqlite3_finalize(selectStatement);
            }
            
            if (sqlite3_prepare_v2(database, [selectSQL UTF8String], -1, &selectStatement, NULL) == SQLITE_OK) {
                sqlite3_bind_text(selectStatement, 1, [rate.toCurrency.shortName UTF8String], -1, SQLITE_TRANSIENT);            
                
                if (sqlite3_step(selectStatement) == SQLITE_ROW) {
                    toIndex = sqlite3_column_int(selectStatement, 0);
                }
                
                sqlite3_finalize(selectStatement);
            }
            
            if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
                sqlite3_bind_int(statement, 1, fromIndex);
                sqlite3_bind_int(statement, 2, toIndex);
                sqlite3_bind_int(statement, 3, rate.primaryKey);
                
                sqlite3_step(statement);
                sqlite3_finalize(statement);
            }
        }
    }    
    
    
    [defaults setObject:version forKey:@"Updated"];
	[defaults synchronize];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	NSString *sql = @"REINDEX";
	sqlite3_stmt *statement;
	
	sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
	sqlite3_step(statement);	
	sqlite3_finalize(statement);
	
	sql = @"BEGIN TRANSACTION; VACUUM; COMMIT;";
	
	sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
	sqlite3_step(statement);
	sqlite3_finalize(statement);
	
	sqlite3_close(database);

	return NSTerminateNow;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
	if (flag) {
		return NO;
	} else {
		[mainWindow makeKeyAndOrderFront:self];
		return YES;
	}	
}

- (void)dealloc {	
	[super dealloc];
}

@end
