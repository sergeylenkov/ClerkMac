#import "TransactionsController.h"

@implementation TransactionsController

@synthesize view;
@synthesize transactions;

- (void)awakeFromNib {
	defaults = [NSUserDefaults standardUserDefaults];	
	transactions = [[NSMutableArray alloc] init];
	
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
	TableTransaction *transaction = [transactions objectAtIndex:row];
	
	if ([[tableColumn identifier] isEqualToString:@"date"]) {
		return [dateFormatter stringFromDate:transaction.date];
	}
	
	if ([[tableColumn identifier] isEqualToString:@"amount"]) {
		return [formatter stringFromNumber:transaction.amount];
	}
	
	return @"";
}

- (id)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
	TableTransaction *transaction = [[transactions objectAtIndex:row] retain];

	if ([[tableColumn identifier] isEqualToString:@"transaction"]) {
		TransactionCell *cell = [[TransactionCell alloc] init];

		cell.name = transaction.name;
		cell.accountName = transaction.accountName;
		cell.accountIcon = transaction.accountIcon;
		
		return cell;
	}
	
	if ([[tableColumn identifier] isEqualToString:@"amount"]) {
		CenterCell *cell = [[[CenterCell alloc] initTextCell:@""] autorelease];

		[cell setEditable:NO];
		[cell setAlignment:NSRightTextAlignment];
		[cell setTextColor:[NSColor colorWithDeviceRed:40.0/255.0 green:40.0/255.0 blue:40./255.0 alpha:1.0]];
		[cell setFont:[NSFont boldSystemFontOfSize:11]];
		
		if (row == [view selectedRow]) {
			[cell setTextColor:[NSColor whiteColor]];
		} else {
			if (transaction.isIncoming) {
				[cell setTextColor:[NSColor colorWithDeviceRed:26.0/255.0 green:147.0/255.0 blue:7.0/255.0 alpha:1.0]];
			} else {
				[cell setTextColor:[NSColor colorWithDeviceRed:199.0/255.0 green:42.0/255.0 blue:65.0/255.0 alpha:1.0]];
			}
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
	
	[addTransactionButton setEnabled:YES];
	[editTransactionButton setEnabled:NO];
	[deleteTransactionButton setEnabled:NO];
	[dublicateTransactionButton setEnabled:NO];
		
	if (selectedRow != -1) {
		TableTransaction *tableTransaction = [transactions objectAtIndex:selectedRow];
		Transaction *transaction = tableTransaction.accountTransaction;
		
		if (transaction.fromAccount.primaryKey == -1 || transaction.toAccount.primaryKey == -1) {
			[editTransactionButton setEnabled:NO];
			[deleteTransactionButton setEnabled:NO];
			[dublicateTransactionButton setEnabled:NO];
		} else {
			[editTransactionButton setEnabled:YES];
			[deleteTransactionButton setEnabled:YES];
			[dublicateTransactionButton setEnabled:YES];
		}
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
		[transactions sortUsingSelector:@selector(compareAmount:)];
	}
	
	if ([identifier isEqualToString:@"transaction"]) {
		[transactions sortUsingSelector:@selector(compareAccountName:)];		
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
		TableTransaction *tableTransaction = [transactions objectAtIndex:selectedRow];
		return tableTransaction.accountTransaction;
	}
	
	return nil;
}

- (void)dealloc {
	[view release];
	[transactions release];
	[formatter release];
	[dateFormatter release];
	[defaults release];
	[super dealloc];
}

@end
