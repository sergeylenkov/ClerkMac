#import "RatesController.h"

@implementation RatesController

@synthesize view;
@synthesize rates;

- (void)awakeFromNib {	
	formatter = [[NSNumberFormatter alloc] init];
	
	[formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];	
	[formatter setPositiveFormat:@"#,##0.00"];
	
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
}

- (void)refresh {
	if ([defaults objectForKey:[NSString stringWithFormat:@"%@ Sorting Column", [view autosaveName]]] == nil) {
		sortAscending = YES;		
		[self sortTableView:view byIdentifier:@"date" ascending:sortAscending];
	} else {
		lastIdentifier = [defaults objectForKey:[NSString stringWithFormat:@"%@ Sorting Column", [view autosaveName]]];
		sortAscending = [defaults boolForKey:[NSString stringWithFormat:@"%@ Sort Order", [view autosaveName]]];
		
		[self sortTableView:view byIdentifier:lastIdentifier ascending:sortAscending];
	}
	
	[view reloadData];
	[self tableViewSelectionDidChange:[NSNotification notificationWithName:@"NSObject" object:view]];
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView {
	return [rates count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
	Rate *rate = [rates objectAtIndex:row];
	
	if ([[tableColumn identifier] isEqualToString:@"from"]) {
		return rate.fromCurrency.shortName;
	}
	
	if ([[tableColumn identifier] isEqualToString:@"to"]) {
		return rate.toCurrency.shortName;
	}
	
	if ([[tableColumn identifier] isEqualToString:@"date"]) {
		return [dateFormatter stringFromDate:rate.date];
	}
	
	if ([[tableColumn identifier] isEqualToString:@"rate"]) {
		return [formatter stringFromNumber:rate.rate];
	}
	
	if ([[tableColumn identifier] isEqualToString:@"change"]) {
		if (row < [rates count] - 1) {
			Rate *previousRate = [rates objectAtIndex:row + 1];
			
			NSNumber *change = [NSNumber numberWithFloat:[rate.rate floatValue] - [previousRate.rate floatValue]];
						
			if ([rate.rate doubleValue] > [previousRate.rate doubleValue]) {
				return [NSString stringWithFormat:@"+ %@", [formatter stringFromNumber:change]];
			}
			
			if ([rate.rate floatValue] < [previousRate.rate floatValue]) {
				return [formatter stringFromNumber:change];
			}
			
			return [formatter stringFromNumber:change];
		}
	}
	
	return @"";
}

- (id)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
	Rate *rate = [rates objectAtIndex:row];
	
	if ([[tableColumn identifier] isEqualToString:@"from"]) {
		CenterCell *cell = [[[CenterCell alloc] initTextCell:@""] autorelease];
		
		[cell setEditable:NO];
		[cell setAlignment:NSLeftTextAlignment];
		[cell setFont:[NSFont boldSystemFontOfSize:11]];
		
		if (row == [view selectedRow]) {
			[cell setTextColor:[NSColor whiteColor]];
		} else {
			[cell setTextColor:[NSColor colorWithDeviceRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1.0]];
		}
		
		return cell;
	}
	
	if ([[tableColumn identifier] isEqualToString:@"to"]) {
		CenterCell *cell = [[[CenterCell alloc] initTextCell:@""] autorelease];
		
		[cell setEditable:NO];
		[cell setAlignment:NSLeftTextAlignment];
		[cell setFont:[NSFont boldSystemFontOfSize:11]];
		
		if (row == [view selectedRow]) {
			[cell setTextColor:[NSColor whiteColor]];
		} else {
			[cell setTextColor:[NSColor colorWithDeviceRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1.0]];
		}
		
		return cell;
	}
	
	if ([[tableColumn identifier] isEqualToString:@"date"]) {
		CenterCell *cell = [[[CenterCell alloc] initTextCell:@""] autorelease];
		
		[cell setEditable:NO];
		[cell setAlignment:NSCenterTextAlignment];		
		[cell setFont:[NSFont boldSystemFontOfSize:11]];
		
		if (row == [view selectedRow]) {
			[cell setTextColor:[NSColor whiteColor]];
		} else {
			[cell setTextColor:[NSColor colorWithDeviceRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1.0]];
		}
		
		return cell;
	}
	
	if ([[tableColumn identifier] isEqualToString:@"rate"]) {
		CenterCell *cell = [[[CenterCell alloc] initTextCell:@""] autorelease];
		
		[cell setEditable:NO];
		[cell setAlignment:NSRightTextAlignment];
		[cell setFont:[NSFont boldSystemFontOfSize:11]];
		
		if (row == [view selectedRow]) {
			[cell setTextColor:[NSColor whiteColor]];
		} else {
			[cell setTextColor:[NSColor colorWithDeviceRed:40.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1.0]];
		}
		
		return cell;
	}
	
	if ([[tableColumn identifier] isEqualToString:@"change"]) {
		CenterCell *cell = [[[CenterCell alloc] initTextCell:@""] autorelease];
		
		[cell setEditable:NO];
		[cell setAlignment:NSRightTextAlignment];
		[cell setFont:[NSFont boldSystemFontOfSize:11]];
		
		if (row == [view selectedRow]) {
			[cell setTextColor:[NSColor whiteColor]];
		} else {			
			[cell setTextColor:[NSColor colorWithDeviceRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1.0]];
			
			if (row < [rates count] - 1) {
				Rate *previousRate = [rates objectAtIndex:row + 1];
				
				if ([rate.rate doubleValue] > [previousRate.rate doubleValue]) {
					[cell setTextColor:[NSColor colorWithDeviceRed:26.0/255.0 green:147.0/255.0 blue:7.0/255.0 alpha:1.0]];
				}
				
				if ([rate.rate floatValue] < [previousRate.rate floatValue]) {
					[cell setTextColor:[NSColor colorWithDeviceRed:199.0/255.0 green:42.0/255.0 blue:65.0/255.0 alpha:1.0]];
				}
			}
		}
		
		return cell;
	}
	
	return [tableColumn dataCell];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
	int selectedRow = [[notification object] selectedRow];
	
	[editRateButton setEnabled:NO];
	[deleteRateButton setEnabled:NO];
	
	if (selectedRow != -1) {
		[editRateButton setEnabled:YES];
		[deleteRateButton setEnabled:YES];
	}
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn {
	if (![lastIdentifier isEqualToString:[tableColumn identifier]]) {
		sortAscending = YES;
		lastIdentifier = [tableColumn identifier];
	} else {
		sortAscending = !sortAscending;
	}
	
	[self sortTableView:tableView byIdentifier:[tableColumn identifier] ascending:sortAscending];
}

- (void)sortTableView:(NSTableView *)tableView byIdentifier:(NSString *)identifier ascending:(BOOL)order {
	if ([identifier isEqualToString:@"date"]) {
		[rates sortUsingSelector:@selector(compareDate:)];
	}
	
	if ([identifier isEqualToString:@"rate"]) {
		[rates sortUsingSelector:@selector(compareRate:)];
	}
	
	if (sortAscending) {
		[self reverse];
	}
	
	[defaults setObject:identifier forKey:[NSString stringWithFormat:@"%@ Sorting Column", [view autosaveName]]];
	[defaults setBool:order forKey:[NSString stringWithFormat:@"%@ Sort Order", [view autosaveName]]];
	
    [view reloadData];
}

- (void)reverse {
	for (int i = 0; i < (floor([rates count] / 2)); i++) {
		[rates exchangeObjectAtIndex:i withObjectAtIndex:([rates count] - (i + 1))];
	}
}

- (Rate *)selectedRate {
	int selectedRow = [view selectedRow];
	
	if (selectedRow != -1) {
		return [rates objectAtIndex:selectedRow];
	}
	
	return nil;
}

- (void)dealloc {
	[view release];
	[rates release];
	[formatter release];
	[super dealloc];
}

@end