#import "SchedulersController.h"

@implementation SchedulersController

@synthesize view;
@synthesize schedulers;

- (void)awakeFromNib {
	defaults = [NSUserDefaults standardUserDefaults];
	
	days = [[NSMutableArray alloc] init];
	
	[days addObject:@"1st"];
	[days addObject:@"2nd"];
	[days addObject:@"3rd"];
	[days addObject:@"4th"];
	[days addObject:@"5th"];
	[days addObject:@"6th"];
	[days addObject:@"7th"];
	[days addObject:@"8th"];
	[days addObject:@"9th"];
	[days addObject:@"10th"];
	[days addObject:@"11th"];
	[days addObject:@"12th"];
	[days addObject:@"13th"];
	[days addObject:@"14th"];
	[days addObject:@"15th"];
	[days addObject:@"16th"];
	[days addObject:@"17th"];
	[days addObject:@"18th"];
	[days addObject:@"19th"];
	[days addObject:@"20th"];
	[days addObject:@"21st"];
	[days addObject:@"22nd"];
	[days addObject:@"23rd"];
	[days addObject:@"24th"];
	[days addObject:@"25th"];
	[days addObject:@"26th"];
	[days addObject:@"27th"];
	[days addObject:@"28th"];
	[days addObject:@"29th"];
	[days addObject:@"30th"];
	[days addObject:@"31st"];
	
	months = [[NSMutableArray alloc] init];
	
	[months addObject:@""];
	[months addObject:@"January"];
	[months addObject:@"February"];
	[months addObject:@"March"];
	[months addObject:@"April"];
	[months addObject:@"May"];
	[months addObject:@"June"];
	[months addObject:@"July"];
	[months addObject:@"August"];
	[months addObject:@"September"];
	[months addObject:@"October"];
	[months addObject:@"November"];
	[months addObject:@"December"];
	
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
	return [schedulers count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
	Scheduler *scheduler = [schedulers objectAtIndex:row];
	
	if ([[tableColumn identifier] isEqualToString:@"date"]) {
		return [dateFormatter stringFromDate:scheduler.nextDate];
	}
	
	return @"";
}

- (id)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(int)row {	
	if ([[tableColumn identifier] isEqualToString:@"scheduler"]) {
		Scheduler *scheduler = [schedulers objectAtIndex:row];
		
		SchedulerCell *cell = [[SchedulerCell alloc] init];
		
		cell.name = scheduler.name;
		
		NSString *description = @"Repeat ";
		
		if (scheduler.periodType == 0) {
			description = [description stringByAppendingString:@"daily"];
		}
		
		if (scheduler.periodType == 1) {
			description = [description stringByAppendingFormat:@"weekly every %@ day", [days objectAtIndex:scheduler.day - 1]];
		}
		
		if (scheduler.periodType == 2) {
			description = [description stringByAppendingFormat:@"monthly every %@ day", [days objectAtIndex:scheduler.day - 1]];
		}
		
		if (scheduler.periodType == 3) {
			description = [description stringByAppendingFormat:@"yearly every %@ day in %@", [days objectAtIndex:scheduler.day - 1], [months objectAtIndex:scheduler.month]];
		}
		
		cell.description = description;
		
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
	
	return [tableColumn dataCell];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
	int selectedRow = [[notification object] selectedRow];
	
	[editSchedulerButton setEnabled:NO];
	[deleteSchedulerButton setEnabled:NO];
	
	if (selectedRow != -1) {
		[editSchedulerButton setEnabled:YES];
		[deleteSchedulerButton setEnabled:YES];
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
		[schedulers sortUsingSelector:@selector(compareDate:)];
	}
	
	if ([identifier isEqualToString:@"scheduler"]) {
		[schedulers sortUsingSelector:@selector(compareName:)];
	}
	
	if (sortAscending) {
		[self reverse];
	}
	
	[defaults setObject:identifier forKey:[NSString stringWithFormat:@"%@ Sorting Column", [view autosaveName]]];
	[defaults setBool:order forKey:[NSString stringWithFormat:@"%@ Sort Order", [view autosaveName]]];
	
    [view reloadData];
}

- (void)reverse {
	for (int i = 0; i < (floor([schedulers count] / 2)); i++) {
		[schedulers exchangeObjectAtIndex:i withObjectAtIndex:([schedulers count] - (i + 1))];
	}
}

- (void)dealloc {
	[view release];
	[days release];
	[months release];
	[schedulers release];
	[formatter release];
	[defaults release];
	[super dealloc];
}

@end
