#import "TrashTransactionsController.h"

@implementation TrashTransactionsController

@synthesize view;
@synthesize transactions;

- (void)awakeFromNib {
	defaults = [NSUserDefaults standardUserDefaults];
	
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
	return [transactions count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
	Transaction *transaction = [transactions objectAtIndex:row];
	
	if ([[tableColumn identifier] isEqualToString:@"date"]) {
		return [dateFormatter stringFromDate:transaction.date];
	}
	
	if ([[tableColumn identifier] isEqualToString:@"amount"]) {
		return [formatter stringFromNumber:transaction.fromAccountAmount];
	}
	
	return @"";
}

- (id)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
	Transaction *transaction = [transactions objectAtIndex:row];
	
	if ([[tableColumn identifier] isEqualToString:@"transaction"]) {
		TrashCell *cell = [[TrashCell alloc] init];
		
		cell.name = transaction.name;
		
		cell.fromAccountName = transaction.fromAccount.name;
		cell.fromAccountIcon = transaction.fromAccount.icon;
		cell.fromAmount = [formatter stringFromNumber:transaction.fromAccountAmount];
		
		cell.toAccountName = transaction.toAccount.name;
		cell.toAccountIcon = transaction.toAccount.icon;
		cell.toAmount = [formatter stringFromNumber:transaction.toAccountAmount];
		
		return cell;
	}
	
	if ([[tableColumn identifier] isEqualToString:@"amount"]) {
		CenterCell *cell = [[[CenterCell alloc] initTextCell:@""] autorelease];
		
		[cell setEditable:NO];
		[cell setAlignment:NSRightTextAlignment];		
		[cell setFont:[NSFont boldSystemFontOfSize:11]];
		
		if (row == [view selectedRow]) {
			[cell setTextColor:[NSColor whiteColor]];
		} else {
			[cell setTextColor:[NSColor colorWithDeviceRed:40.0/255.0 green:40.0/255.0 blue:40./255.0 alpha:1.0]];
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
	
	return [tableColumn dataCell];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
	int selectedRow = [[notification object] selectedRow];
	
	[restoreTransactionButton setEnabled:NO];
	[deleteTransactionButton setEnabled:NO];
	
	if (selectedRow != -1) {
		[restoreTransactionButton setEnabled:YES];
		[deleteTransactionButton setEnabled:YES];
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
		[transactions sortUsingSelector:@selector(compareDate:)];
	}
	
	if ([identifier isEqualToString:@"amount"]) {
		//[transactions sortUsingSelector:@selector(compareAmount:)];
	}
	
	if ([identifier isEqualToString:@"transaction"]) {
		//[transactions sortUsingSelector:@selector(compareAccountName:)];		
	}
	
	if (sortAscending) {
		[self reverse];
	}
	
	[defaults setObject:identifier forKey:[NSString stringWithFormat:@"%@ Sorting Column", [view autosaveName]]];
	[defaults setBool:order forKey:[NSString stringWithFormat:@"%@ Sort Order", [view autosaveName]]];
	
    [view reloadData];
}

- (void)reverse {
	for (int i = 0; i < (floor([transactions count] / 2)); i++) {
		[transactions exchangeObjectAtIndex:i withObjectAtIndex:([transactions count] - (i + 1))];
	}
}

- (Transaction *)selectedTransaction {
	int selectedRow = [view selectedRow];
	
	if (selectedRow != -1) {
		return [transactions objectAtIndex:selectedRow];
	}
	
	return nil;
}

- (void)dealloc {
	[view release];
	[transactions release];
	[formatter release];
	[dateFormatter release];
	[super dealloc];
}

@end
