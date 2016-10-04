#import "ExpensesReportController.h"

@implementation ExpensesReportController

@synthesize accounts;
@synthesize database;

- (void)awakeFromNib {
	defaults = [NSUserDefaults standardUserDefaults];
	
	graphValues = [[NSMutableArray alloc] init];
	graphSeries = [[NSMutableArray alloc] init];
	chartValues = [[NSMutableArray alloc] init];
	chartSeries = [[NSMutableArray alloc] init];
	
	formatter = [[NSNumberFormatter alloc] init];
	
	[formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[formatter setPositiveFormat:[NSString stringWithFormat:@"#,##0.00"]];
	
	expensesGraphView.delegate = self;
	expensesGraphView.dataSource = self;
	expensesGraphView.showMarker = YES;
	
	expensesGraphView.lineWidth = 1.2;
	expensesGraphView.drawBullets = NO;
	
	expensesGraphView.marker.backgroundColor = [NSColor colorWithDeviceRed:5/255.0 green:141/255.0 blue:199/255.0 alpha:1.0];
	expensesGraphView.marker.borderColor = [NSColor colorWithDeviceRed:5/255.0 green:141/255.0 blue:169/255.0 alpha:1.0];
	expensesGraphView.marker.textColor = [NSColor whiteColor];
	expensesGraphView.marker.type = YBMarkerTypeRectWithArrow;
	expensesGraphView.marker.shadow = YES;
	
	expensesChartView.delegate = self;
	expensesChartView.dataSource = self;
	expensesChartView.drawLegend = NO;
	expensesChartView.showMarker = YES;
	
	expensesChartView.marker.type = YBMarkerTypeRectWithArrow;
}

- (void)initialization {
	NSDate *minDate = [NSDate date];
	NSDate *maxDate = [NSDate dateWithTimeIntervalSince1970:0];
			
	[accountsButton removeAllItems];
	[accountsButton addItemWithTitle:@"All"];
	
	NSString *bundlePath = [[NSBundle mainBundle] resourcePath];
	
	for (int i = 0; i < [accounts.allExpenses count]; i++) {
		Account *account = [accounts.allExpenses objectAtIndex:i];
		NSMutableArray *transactions = [account transactions];
		
		for (int j = 0; j < [transactions count]; j++) {
			Transaction *transaction = [transactions objectAtIndex:j];
			
			if ([transaction.date timeIntervalSince1970] < [minDate timeIntervalSince1970]) {
				minDate = transaction.date;
			}
			
			if ([transaction.date timeIntervalSince1970] > [maxDate timeIntervalSince1970]) {
				maxDate = transaction.date;
			}		
		}
		
		[accountsButton addItemWithTitle:account.name];
		
		NSImage *iconImage = [[[NSImage alloc] initWithContentsOfFile:[bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.png", account.iconIndex]]] autorelease];
		[iconImage setSize:NSMakeSize(16, 16)];
		
		[[accountsButton itemAtIndex:i + 1] setImage:iconImage];
	}
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:minDate];
	
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	
	minDate = [calendar dateFromComponents:components];
	
	components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:maxDate];
	
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	
	maxDate = [calendar dateFromComponents:components];
	
	[fromDate setMinDate:minDate];
	[fromDate setMaxDate:maxDate];
	
	[toDate setMinDate:minDate];
	[toDate setMaxDate:maxDate];
	
	if ([defaults objectForKey:@"Expenses Min Date"] == nil) {
		[fromDate setDateValue:minDate];
	} else {
		[fromDate setDateValue:[defaults objectForKey:@"Expenses Min Date"]];
	}
	
	[toDate setDateValue:maxDate];
	
	if ([defaults objectForKey:@"Expenses Graph By"] == nil) {
		[byButton selectItem:[byButton itemAtIndex:0]];
	} else {
		int index = [[defaults objectForKey:@"Expenses Graph By"] intValue];
		[byButton selectItem:[byButton itemAtIndex:index]];
	}
	
	if ([defaults objectForKey:@"Expenses Account Index"] == nil) {
		[accountsButton selectItem:[accountsButton itemAtIndex:0]];
	} else {
		int index = [[defaults objectForKey:@"Expenses Account Index"] intValue];
		
		if (index < [accounts.expenses count]) {
			[accountsButton selectItem:[accountsButton itemAtIndex:index]];
		} else {
			[accountsButton selectItem:[accountsButton itemAtIndex:0]];
		}
	}
	
	if ([defaults objectForKey:@"Expenses View Index"] == nil) {
		[changeViewButton setSelectedSegment:0];
	} else {
		int index = [[defaults objectForKey:@"Expenses View Index"] intValue];
		[changeViewButton setSelectedSegment:index];
	}
		
	[self viewChanged:self];
}

- (void)refresh {
	[graphValues removeAllObjects];
	[graphSeries removeAllObjects];
	[chartValues removeAllObjects];
	[chartSeries removeAllObjects];
	
	NSMutableArray *dates = [[NSMutableArray alloc] init];
	NSMutableArray *amounts = [[NSMutableArray alloc] init];
		
	NSMutableArray *sortArray = [[NSMutableArray alloc] init];
	sortArray = [accounts.allExpenses mutableCopy];	
	[sortArray sortUsingSelector:@selector(compareBalance:)];
	
	Currency *currency = [[Currency alloc] initWithPrimaryKey:[[defaults objectForKey:@"Base Currency"] intValue] database:database];
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDate *date = [fromDate dateValue];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	
	for (int i = 0; i < [sortArray count]; i++) {
		Account *account = [sortArray objectAtIndex:i];
		[chartSeries addObject:account.name];
		
		date = [fromDate dateValue];
		[comps setDay:0];
		
		float amount = 0.0;
		
		while ([date timeIntervalSince1970] <= [[toDate dateValue] timeIntervalSince1970]) {
			date = [calendar dateByAddingComponents:comps toDate:date options:0];
			NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
			
			[components setHour:0];
			[components setMinute:0];
			[components setSecond:0];
			
			date = [calendar dateFromComponents:components];
			
			amount = amount + [[account balanceForDate:date] floatValue];						
			[comps setDay:1];
			
			if ([date isEqualToDate:[toDate dateValue]]) {
				break;
			}
		}
		
		[chartValues addObject:[NSNumber numberWithFloat:amount]];
	}

	date = [fromDate dateValue];
	[comps setDay:0];	
		
	while ([date timeIntervalSince1970] <= [[toDate dateValue] timeIntervalSince1970]) {
		date = [calendar dateByAddingComponents:comps toDate:date options:0];
		NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];
		
		[components setHour:0];
		[components setMinute:0];
		[components setSecond:0];
		
		date = [calendar dateFromComponents:components];
		float amount = 0.0;
		
		if ([accountsButton indexOfSelectedItem] == 0) {
			for (int n = 0; n < [sortArray count]; n++) {
				Account *account = [sortArray objectAtIndex:n];
				amount = amount + [Currency convertAmount:[account balanceForDate:date] fromCurrency:account.currency toCurrency:currency onDate:date];				
			}
		} else {
			Account *account = [accounts.allExpenses objectAtIndex:[accountsButton indexOfSelectedItem] - 1];
			amount = [Currency convertAmount:[account balanceForDate:date] fromCurrency:account.currency toCurrency:currency onDate:date];	
		}
		
		[dates addObject:date];
		[amounts addObject:[NSNumber numberWithFloat:amount]];
		
		[comps setDay:1];
		
		if ([date isEqualToDate:[toDate dateValue]]) {
			break;
		}
	}
	
	if ([byButton indexOfSelectedItem] == 0) {
		for (int i = 0; i < [dates count]; i++) {
			NSDate *date = [dates objectAtIndex:i];
			
			[graphSeries addObject:[date formattedDateWithYear:YES]];
			[graphValues addObject:[amounts objectAtIndex:i]];
		}
	}
	
	if ([byButton indexOfSelectedItem] == 1 && [dates count] > 0) {
		NSDate *date = [dates objectAtIndex:0];		
		float revenue = 0.0;
		
		for (int i = 0; i < [dates count]; i++) {
			NSDate *newDate = [dates objectAtIndex:i];
			
			NSDateComponents *components = [calendar components:(NSWeekCalendarUnit) fromDate:date];
			NSDateComponents *newComponents = [calendar components:(NSWeekCalendarUnit) fromDate:newDate];
			
			if ([components week] != [newComponents week]) {
				[graphSeries addObject:[date formattedDateWithYear:YES]];
				[graphValues addObject:[NSNumber numberWithFloat:revenue]];
				
				revenue = 0.0;
				
				date = newDate;
				components = [calendar components:(NSWeekCalendarUnit) fromDate:date];
			}
			
			if ([components week] == [newComponents week] && i == [dates count] - 1) {				
				revenue = revenue + [[amounts objectAtIndex:i] floatValue];
				
				[graphSeries addObject:[date formattedDateWithYear:YES]];
				[graphValues addObject:[NSNumber numberWithFloat:revenue]];
			}
			
			revenue = revenue + [[amounts objectAtIndex:i] floatValue];
		}
	}
	
	if ([byButton indexOfSelectedItem] == 2 && [dates count] > 0) {
		NSDate *date = [dates objectAtIndex:0];		
		float revenue = 0.0;
		
		for (int i = 0; i < [dates count]; i++) {
			NSDate *newDate = [dates objectAtIndex:i];
			
			NSDateComponents *components = [calendar components:(NSMonthCalendarUnit) fromDate:date];
			NSDateComponents *newComponents = [calendar components:(NSMonthCalendarUnit) fromDate:newDate];
			
			if ([components month] != [newComponents month]) {
				[graphSeries addObject:[date formattedMonth]];
				[graphValues addObject:[NSNumber numberWithFloat:revenue]];
				
				revenue = 0.0;
				
				date = newDate;
				components = [calendar components:(NSMonthCalendarUnit) fromDate:date];			
			}

			if ([components month] == [newComponents month] && i == [dates count] - 1) {				
				revenue = revenue + [[amounts objectAtIndex:i] floatValue];
				
				[graphSeries addObject:[date formattedMonth]];
				[graphValues addObject:[NSNumber numberWithFloat:revenue]];
			}
			
			revenue = revenue + [[amounts objectAtIndex:i] floatValue];
		}
	}
		
	[dates release];
	[amounts release];
	[sortArray release];
	
	if ([graphSeries count] < 70) {
		expensesGraphView.lineWidth = 1.4;
		expensesGraphView.drawBullets = YES;
	} else {
		expensesGraphView.lineWidth = 1.2;
		expensesGraphView.drawBullets = NO;
	}
	
	[expensesChartView draw];
	[expensesGraphView draw];
}

- (NSInteger)numberOfGraphsInGraphView:(YBGraphView *)graph {
	return 1;
}

- (NSArray *)seriesForGraphView:(YBGraphView *)graph {
	return graphSeries;
}

- (NSArray *)graphView:(YBGraphView *)graph valuesForGraph:(NSInteger)index {	
	return graphValues;
}

- (NSString *)graphView:(YBGraphView *)graph markerTitleForGraph:(NSInteger)graphIndex forElement:(NSInteger)elementIndex {
	NSString *value = [formatter stringFromNumber:[graphValues objectAtIndex:elementIndex]];	
	return [NSString stringWithFormat:@"%@\n%@", [graphSeries objectAtIndex:elementIndex], value];
}

- (NSInteger)numberOfCharts {
	return [chartValues count];
}

- (NSNumber *)chartView:(YBChartView *)chart valueForChart:(NSInteger)index {
	return [chartValues objectAtIndex:index];
}

- (NSString *)chartView:(YBChartView *)chart titleForChart:(NSInteger)index {
	return [chartSeries objectAtIndex:index];
}

- (NSString *)chartView:(YBChartView *)chart legendTitleForChart:(NSString *)title withValue:(NSNumber *)value andPercent:(NSNumber *)percent {
	return [NSString stringWithFormat:@"%@: %@%%", title, [formatter stringFromNumber:percent]];
}

- (NSString *)chartView:(YBChartView *)chart markerTitleForChart:(NSString *)title withValue:(NSNumber *)value andPercent:(NSNumber *)percent {
	return [NSString stringWithFormat:@"%@\n%@", title, [formatter stringFromNumber:value]];
}

- (IBAction)changeDate:(id)sender {
	[defaults setObject:[fromDate dateValue] forKey:@"Expenses Min Date"];	
	[self refresh];	
}

- (IBAction)changeBy:(id)sender {
	[defaults setInteger:[byButton indexOfSelectedItem] forKey:@"Expenses Graph By"];	
	[self refresh];
}

- (IBAction)changeAccount:(id)sender {
	[defaults setInteger:[accountsButton indexOfSelectedItem] forKey:@"Expenses Account Index"];	
	[self refresh];
}

- (IBAction)viewChanged:(id)sender {
	[graphView removeFromSuperview];
	[chartView removeFromSuperview];
	
	[self hideGraphButton];
	
	if ([changeViewButton selectedSegment] == 0) {		
		[graphView setFrame:[contentView bounds]];
		[contentView addSubview:graphView];
		
		[self showGraphButton];
	} else {				
		[chartView setFrame:[contentView bounds]];
		[contentView addSubview:chartView];
	}
	
	[defaults setObject:[NSNumber numberWithInt:[changeViewButton selectedSegment]] forKey:@"Expenses View Index"];
}

- (void)showGraphButton {
	[byLabel setHidden:NO];
	[byButton setHidden:NO];
	[accountLabel setHidden:NO];
	[accountsButton setHidden:NO];
}

- (void)hideGraphButton {
	[byLabel setHidden:YES];
	[byButton setHidden:YES];
	[accountLabel setHidden:YES];
	[accountsButton setHidden:YES];
}

- (void)dealloc {
	[accounts release];
	[graphSeries release];
	[graphValues release];
	[chartSeries release];
	[chartValues release];
	[formatter release];
	[defaults release];
	[super dealloc];
}
		
@end
