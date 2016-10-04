#import "ExchangeController.h"

@implementation ExchangeController

@synthesize mainWindow;
@synthesize database;
@synthesize infoButton;
@synthesize filter;
@synthesize currencies;

- (void)awakeFromNib {
	defaults = [NSUserDefaults standardUserDefaults];
	
	editRateController = [[EditRateController alloc] initWithWindowNibName:@"EditRateView"];	
	
	[ratesController.view setTarget:self]; 
	[ratesController.view setDoubleAction:@selector(editRate:)];
	
	graphView.delegate = self;
	graphView.dataSource = self;
	
	graphView.showMarker = YES;
	
	graphView.lineWidth = 1.2;
	graphView.drawBullets = NO;
	
	graphView.marker.backgroundColor = [NSColor colorWithDeviceRed:5/255.0 green:141/255.0 blue:199/255.0 alpha:1.0];
	graphView.marker.borderColor = [NSColor colorWithDeviceRed:5/255.0 green:141/255.0 blue:169/255.0 alpha:1.0];
	graphView.marker.textColor = [NSColor whiteColor];
	graphView.marker.type = YBMarkerTypeRectWithArrow;
	graphView.marker.shadow = YES;
	
	//graphView.zeroAsMinValue = NO;
	
	series = [[NSMutableArray alloc] init];
	values = [[NSMutableArray alloc] init];
	rates = [[NSMutableArray alloc] init];		
	formatter = [[NSNumberFormatter alloc] init];
	
	[formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[formatter setPositiveFormat:[NSString stringWithFormat:@"#,##0.00"]];
	
	graphView.formatter = formatter;
	
	filter = @"";
}

- (void)initialization {
	if ([defaults objectForKey:@"From Currency Index"] != nil) {
		selectedFromItem = [[defaults objectForKey:@"From Currency Index"] intValue];
	} else {
		selectedFromItem = 0;
	}

	if (selectedFromItem >= [currencies count]) {
		selectedFromItem = 0;
	}
	
	[scopeBar setSelected:YES forItem:[NSString stringWithFormat:@"%d", selectedFromItem] inGroup:0];
	
	if ([defaults objectForKey:@"To Currency Index"] != nil) {
		selectedToItem = [[defaults objectForKey:@"To Currency Index"] intValue];
	} else {
		selectedToItem = 0;
	}

	if (selectedToItem >= [currencies count]) {
		selectedToItem = 0;
	}
	
	[scopeBar setSelected:YES forItem:[NSString stringWithFormat:@"%d", selectedToItem] inGroup:1];

	selectedPeriod = @"All";
	
	if ([defaults objectForKey:@"Currency Period"] != nil) {
		selectedPeriod = [defaults objectForKey:@"Currency Period"];
	}
	
	[scopeBar setSelected:YES forItem:selectedPeriod inGroup:2];
	
	if ([defaults objectForKey:@"Rates Graph Visible"] == nil) {
		graphVisible = NO;
	} else {
		graphVisible = [defaults boolForKey:@"Rates Graph Visible"];
	}
	
	//[self showGraph:nil];
}

- (void)refresh {
	[values removeAllObjects];
	[series removeAllObjects];
	[rates removeAllObjects];
		
	NSString *sql = @"SELECT r.id FROM rates r, currencies c, currencies c2 WHERE c.id = ? AND c.id = r.from_currency_id AND c2.id = ? AND c2.id = r.to_currency_id AND date > ? ORDER BY r.date DESC";
	sqlite3_stmt *statement;
	
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
	
	if ([selectedPeriod isEqualToString:@"Week"]) {
		date = [[NSDate date] dateByAddingDays:-7];
	}
	
	if ([selectedPeriod isEqualToString:@"Month"]) {
		date = [[NSDate date] dateByAddingDays:-30];
	}

	if ([selectedPeriod isEqualToString:@"3 Month"]) {
		date = [[NSDate date] dateByAddingDays:-90];
	}
	
	if ([selectedPeriod isEqualToString:@"6 Month"]) {
		date = [[NSDate date] dateByAddingDays:-180];
	}
	
	if ([selectedPeriod isEqualToString:@"Year"]) {
		date = [[NSDate date] dateByAddingDays:-365];
	}
	
	Currency *fromCurrency = [currencies objectAtIndex:selectedFromItem];
	Currency *toCurrency = [currencies objectAtIndex:selectedToItem];
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, fromCurrency.primaryKey);
		sqlite3_bind_int(statement, 2, toCurrency.primaryKey);
		sqlite3_bind_double(statement, 3, [[date truncate] timeIntervalSince1970]);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Rate *rate = [[[Rate alloc] initWithPrimaryKey:sqlite3_column_int(statement, 0) database:database] autorelease];			
			[rates addObject:rate];			
		}
	}
	
	sqlite3_finalize(statement);
	
	[infoButton setTitle:[NSString localizedStringWithFormat:@"%d rates", [rates count]]];
	
	ratesController.rates = rates;
	[ratesController refresh];
	
	for (Rate *rate in rates) {
		[series addObject:[rate.date formattedDateWithYear:YES]];
		[values addObject:rate.rate];
	}
	
	for (int i = 0; i < (floor([series count] / 2)); i++) {
		[series exchangeObjectAtIndex:i withObjectAtIndex:([series count] - (i + 1))];
	}
	
	for (int i = 0; i < (floor([values count] / 2)); i++) {
		[values exchangeObjectAtIndex:i withObjectAtIndex:([values count] - (i + 1))];
	}
	
	[graphView draw];
}

- (NSInteger)numberOfGraphsInGraphView:(YBGraphView *)graph {
	return 1;
}

- (NSArray *)seriesForGraphView:(YBGraphView *)graph {
	return series;
}

- (NSArray *)graphView:(YBGraphView *)graph valuesForGraph:(NSInteger)index {	
	return values;
}

- (NSString *)graphView:(YBGraphView *)graph markerTitleForGraph:(NSInteger)graphIndex forElement:(NSInteger)elementIndex {
	NSString *value = [formatter stringFromNumber:[values objectAtIndex:elementIndex]];
	return [NSString stringWithFormat:@"%@\n%@", [series objectAtIndex:elementIndex], value];
}

- (int)numberOfGroupsInScopeBar:(MGScopeBar *)theScopeBar {
	return 3;
}

- (NSArray *)scopeBar:(MGScopeBar *)theScopeBar itemIdentifiersForGroup:(int)groupNumber {
	if (groupNumber == 0) {
		NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
		
		for (int i = 0; i < [currencies count]; i++) {			
			[array addObject:[NSString stringWithFormat:@"%d", i]];
		}
		
		return array;
	}
	
	if (groupNumber == 1) {
		NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
		
		for (int i = 0; i < [currencies count]; i++) {			
			[array addObject:[NSString stringWithFormat:@"%d", i]];
		}
		
		return array;
	}
	
	if (groupNumber == 2) {
		return [NSArray arrayWithObjects:@"All", @"Week", @"Month", @"3 Month", @"6 Month", @"Year", nil];
	}
	
	return nil;
}

- (NSString *)scopeBar:(MGScopeBar *)theScopeBar labelForGroup:(int)groupNumber {
	if (groupNumber == 0) {
		return @"From:";
	}
	
	if (groupNumber == 1) {
		return @"To:";
	}
	
	return @"Period:";
}

- (NSString *)scopeBar:(MGScopeBar *)theScopeBar titleOfItem:(NSString *)identifier inGroup:(int)groupNumber {
	if (groupNumber == 2) {
		return identifier;
	} else {
		Currency *currency = [currencies objectAtIndex:[identifier intValue]];
		return currency.shortName;
	}
	
	return @"";
}

- (MGScopeBarGroupSelectionMode)scopeBar:(MGScopeBar *)theScopeBar selectionModeForGroup:(int)groupNumber {
	return 0;
}

- (void)scopeBar:(MGScopeBar *)theScopeBar selectedStateChanged:(BOOL)selected forItem:(NSString *)identifier inGroup:(int)groupNumber {
	if (groupNumber == 0) {		
		selectedFromItem = [identifier intValue];
		[defaults setInteger:selectedFromItem forKey:@"From Currency Index"];
	}
	
	if (groupNumber == 1) {
		selectedToItem = [identifier intValue];
		[defaults setInteger:selectedToItem forKey:@"To Currency Index"];
	}
	
	if (groupNumber == 2) {
		[defaults setObject:identifier forKey:@"Currency Period"];
		selectedPeriod = identifier;
	}
	
	[self refresh];
}

- (IBAction)addRate:(id)sender {	
	Rate *rate = [[[Rate alloc] initWithPrimaryKey:-1 database:database] autorelease];
	
	editRateController.rate = rate;
	editRateController.currencies = currencies;
	editRateController.fromCurrency = [currencies objectAtIndex:selectedFromItem];
	editRateController.toCurrency = [currencies objectAtIndex:selectedToItem];
	
	[editRateController showOnWindow:mainWindow];
	
	[self refresh];
}

- (IBAction)editRate:(id)sender {
	Rate *rate = [rates objectAtIndex:[ratesController.view selectedRow]];
	
	editRateController.rate = rate;
	editRateController.currencies = currencies;
	
	[editRateController showOnWindow:mainWindow];
	
	[self refresh];
}

- (IBAction)deleteRate:(id)sender {
	Rate *rate = [rates objectAtIndex:[ratesController.view selectedRow]];
	[rate delete];
	
	[self refresh];
}

- (IBAction)dublicateRate:(id)sender {
	Rate *rate = [rates objectAtIndex:[ratesController.view selectedRow]];
	
	Rate *newRate = [[[Rate alloc] initWithPrimaryKey:-1 database:database] autorelease];
	
	newRate.fromCurrency = rate.fromCurrency;
	newRate.toCurrency = rate.toCurrency;
	newRate.rate = rate.rate;
	newRate.date = [NSDate date];
	
	[newRate save];
	
	[self refresh];
}

- (IBAction)showGraph:(id)sender {
	[defaults setBool:graphVisible forKey:[NSString stringWithFormat:@"Rates Graph Visible"]];
	
	if (graphVisible) {
		[showGraphButton setTitle:@"Hide Graph"];
	} else {
		[showGraphButton setTitle:@"Show Graph"];
	}
}

- (void)dealloc {
	[values release];
	[series release];
	[rates release];
	[currencies release];
	[infoButton release];
	[formatter release];
	[editRateController release];
	[super dealloc];
}

@end
