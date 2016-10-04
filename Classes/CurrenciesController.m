#import "CurrenciesController.h"

@implementation CurrenciesController

@synthesize database;

- (void)initialization {	
	defaults = [NSUserDefaults standardUserDefaults];
	
	currencies = [[NSMutableArray alloc] init];
	
	NSTableColumn *tableColumn = [view tableColumnWithIdentifier:@"name"];
	
	NSTextFieldCell *dataCell = [[[NSTextFieldCell alloc] initTextCell:@""] autorelease];
	[dataCell setEditable:YES];
	[dataCell setAlignment:NSLeftTextAlignment];
	[dataCell setFont:[NSFont systemFontOfSize:13]];	
	[tableColumn setDataCell:dataCell];
	
	tableColumn = [view tableColumnWithIdentifier:@"short_name"];
	
	dataCell = [[[NSTextFieldCell alloc] initTextCell:@""] autorelease];
	[dataCell setEditable:NO];
	[dataCell setAlignment:NSLeftTextAlignment];
	[dataCell setFont:[NSFont systemFontOfSize:13]];	
	[tableColumn setDataCell:dataCell];
}

- (void)refresh {	
	[currencies removeAllObjects];
	
	NSString *sql = @"SELECT id FROM currencies ORDER BY short_name";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Currency *currency = [[Currency alloc] initWithPrimaryKey:sqlite3_column_int(statement, 0) database:database];
			
			[currencies addObject:currency];			
			[currency release];			
		}
	}
	
	sqlite3_reset(statement);
			
	[view reloadData];
	[self refreshBaseCurrencyButton];
	
	[deleteButton setEnabled:NO];
}

- (void)refreshBaseCurrencyButton {
	[currenciesButton removeAllItems];

    int selectedIndex = 0;
    
	for (int i = 0; i < [currencies count]; i++) {
		Currency *currency = [currencies objectAtIndex:i];
        
        if (currency.isEnabled) {
            [currenciesButton addItemWithTitle:currency.name];

            if (currency.primaryKey == [defaults integerForKey:@"Base Currency"]) {
                [currenciesButton selectItem:[currenciesButton itemAtIndex:selectedIndex]];			
            }
            
            selectedIndex = selectedIndex + 1;
        }		
	}
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView {	
	return [currencies count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
	Currency *currency = [currencies objectAtIndex:row];

	if ([[tableColumn identifier] isEqualToString:@"name"]) {
		return currency.name;
	}
	
	if ([[tableColumn identifier] isEqualToString:@"short_name"]) {
		return currency.shortName;
	}
	
    if ([[tableColumn identifier] isEqualToString:@"enabled"]) {
		return [NSNumber numberWithInt:currency.isEnabled];
	}
    
	return @"";
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row {
	Currency *currency = [currencies objectAtIndex:row];
	
	if ([[tableColumn identifier] isEqualToString:@"name"]) {
		currency.name = object;
	}
	
	if ([[tableColumn identifier] isEqualToString:@"short_name"]) {
		currency.shortName = object;
	}
	
	if ([[tableColumn identifier] isEqualToString:@"enabled"]) {
		currency.isEnabled = [object boolValue];
	}
    
	[currency save];
	[self refreshBaseCurrencyButton];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
	int selectedRow = [[notification object] selectedRow];
	
	if (selectedRow != -1) {
		[deleteButton setEnabled:YES];
	} else {
		[deleteButton setEnabled:NO];
	}	
}

- (IBAction)addCurrency:(id)sender {
	Currency *currency = [[Currency alloc] initWithPrimaryKey:-1 database:database];
	
	[currencies addObject:currency];
	
	[currency save];
	[currency release];
	
	[view reloadData];	
    [view editColumn:0 row:([currencies count] - 1) withEvent:nil select:YES];	
	
	[self refreshBaseCurrencyButton];
}

- (IBAction)removeCurrency:(id)sender {
	int selectedRow = [view selectedRow];
	
	if (selectedRow != -1) {
		Currency *currency = [currencies objectAtIndex:selectedRow];
		[currency delete];
		
		[currencies removeObjectAtIndex:selectedRow];		
		
		[view reloadData];
		[self refreshBaseCurrencyButton];
	}
}

- (IBAction)changeBaseCurrency:(id)sender {	
	Currency *currency = [currencies objectAtIndex:[currenciesButton indexOfSelectedItem]];
	[defaults setInteger:currency.primaryKey forKey:@"Base Currency"];
}

@end
