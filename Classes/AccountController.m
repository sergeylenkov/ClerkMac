#import "AccountController.h"

@implementation AccountController

@synthesize mainWindow;
@synthesize database;
@synthesize account;
@synthesize accounts;
@synthesize infoButton;
@synthesize filter;

- (void)awakeFromNib {
	defaults = [NSUserDefaults standardUserDefaults];
	transactions = [[NSMutableArray alloc] init];
	
	editTransactionController = [[EditTransactionController alloc] initWithWindowNibName:@"EditTransactionView"];	
	
	[transactionsController.view setTarget:self]; 
	[transactionsController.view setDoubleAction:@selector(editTransaction:)];
	
	formatter = [[NSNumberFormatter alloc] init];
	
	[formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[formatter setPositiveFormat:[NSString stringWithFormat:@"#,##0.00"]];
		
	filter = @"";
}

- (void)initialization {
	period = [[defaults objectForKey:[NSString stringWithFormat:@"Period Filter For %@", account.name]] intValue];
	
	switch (period) {
		case 0:
			[scopeBar setSelected:YES forItem:@"All" inGroup:0];
			break;
		case 1:
			[scopeBar setSelected:YES forItem:@"Today" inGroup:0];
			break;
		case 2:
			[scopeBar setSelected:YES forItem:@"Week" inGroup:0];
			break;
		case 3:
			[scopeBar setSelected:YES forItem:@"Current Month" inGroup:0];
			break;
		case 4:
			[scopeBar setSelected:YES forItem:@"Previous Month" inGroup:0];
			break;
		case 5:
			[scopeBar setSelected:YES forItem:@"Period" inGroup:0];
			break;
		default:
			[scopeBar setSelected:YES forItem:@"All" inGroup:0];
			break;
	}
	
	fromDate = [[NSDate date] retain];
	toDate = [[NSDate date] retain];
	
	if ([defaults objectForKey:[NSString stringWithFormat:@"Min Date Filter For %@", account.name]] == nil) {
		fromDate = [[account minDate] retain];
	} else {
		fromDate = [[defaults objectForKey:[NSString stringWithFormat:@"Min Date Filter For %@", account.name]] retain];
	}
	
	if ([defaults objectForKey:[NSString stringWithFormat:@"Max Date Filter For %@", account.name]] == nil) {
		toDate = [[account maxDate] retain];
	} else {
		toDate = [[defaults objectForKey:[NSString stringWithFormat:@"Max Date Filter For %@", account.name]] retain];
	}
    
    [mainWindow makeFirstResponder:transactionsController.view];
    [transactionsController.view selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

- (void)refresh {
	[transactions removeAllObjects];
	
	NSMutableArray *accountTransactions;
	
	if (period == 5) {
		accountTransactions = [account transactionsFromDate:fromDate toDate:toDate withFilter:filter];
	} else {
		accountTransactions = [account transactionsByPeriod:period withFilter:filter];
	}	

	if (account.type == 0 || account.type == 2) {
		float amount = 0.0;
	
		for (int i = 0; i < [accountTransactions count]; i++) {
			Transaction *transaction = [accountTransactions objectAtIndex:i];
		
			if (account.primaryKey == transaction.fromAccount.primaryKey) {
				amount = amount + [transaction.fromAccountAmount floatValue];
			} else if (account.primaryKey == transaction.toAccount.primaryKey) {
				amount = amount + [transaction.toAccountAmount floatValue];
			} else {		
				amount = amount + [transaction.fromAccountAmount floatValue];
			}
		}

		NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithFloat:amount]];
		[infoButton setTitle:[NSString stringWithFormat:@"%d transactions, %@ %@", [accountTransactions count], formatted, account.currency.shortName]];
	} else {
		NSString *formatted = [formatter stringFromNumber:[account balance]];
		[infoButton setTitle:[NSString stringWithFormat:@"%d transactions, %@ %@", [accountTransactions count], formatted, account.currency.shortName]];
	}
	
	for (Transaction *transaction in accountTransactions) {
		TableTransaction *tableTransaction = [[[TableTransaction alloc] init] autorelease];
		
		tableTransaction.name = transaction.name;
		
		if (account.type == 0) {
			tableTransaction.accountName = transaction.toAccount.name;
			tableTransaction.accountIcon = transaction.toAccount.icon;
			tableTransaction.amount = transaction.fromAccountAmount;
			tableTransaction.isIncoming = YES;
		}
		
		if (account.type == 1) {
			if (transaction.toAccount.primaryKey == account.primaryKey) {
				tableTransaction.accountName = transaction.fromAccount.name;
				tableTransaction.accountIcon = transaction.fromAccount.icon;
				tableTransaction.amount = transaction.toAccountAmount;
				tableTransaction.isIncoming = YES;
			}
			
			if (transaction.fromAccount.primaryKey == account.primaryKey) {
				tableTransaction.accountName = transaction.toAccount.name;
				tableTransaction.accountIcon = transaction.toAccount.icon;
				tableTransaction.amount = transaction.fromAccountAmount;
				tableTransaction.isIncoming = NO;
			}
		}
		
		if (account.type == 2 || account.type == 3) {
			tableTransaction.accountName = transaction.fromAccount.name;
			tableTransaction.accountIcon = transaction.fromAccount.icon;
			tableTransaction.amount = transaction.toAccountAmount;
			tableTransaction.isIncoming = NO;
		}
		
		tableTransaction.date = transaction.date;
		tableTransaction.accountTransaction = transaction;
		
		[transactions addObject:tableTransaction];
	}
	
	transactionsController.transactions = transactions;
	[transactionsController refresh];
	
	[fromDateButton setTitle:[fromDate formattedDateWithYear:YES]];
	[toDateButton setTitle:[toDate formattedDateWithYear:YES]];
}

#pragma mark -
#pragma mark scope bar protocol
#pragma mark -

- (int)numberOfGroupsInScopeBar:(MGScopeBar *)theScopeBar {
	return 1;
}

- (NSArray *)scopeBar:(MGScopeBar *)theScopeBar itemIdentifiersForGroup:(int)groupNumber {
	if (groupNumber == 0) {
		return [NSArray arrayWithObjects:@"All", @"Today", @"Week", @"Current Month", @"Previous Month", @"Period", nil];
	}
	
	return nil;
}

- (NSString *)scopeBar:(MGScopeBar *)theScopeBar labelForGroup:(int)groupNumber {
	return @"";
}

- (NSString *)scopeBar:(MGScopeBar *)theScopeBar titleOfItem:(NSString *)identifier inGroup:(int)groupNumber {
	return identifier;
}

- (MGScopeBarGroupSelectionMode)scopeBar:(MGScopeBar *)theScopeBar selectionModeForGroup:(int)groupNumber {
	return 0;
}

- (void)scopeBar:(MGScopeBar *)theScopeBar selectedStateChanged:(BOOL)selected forItem:(NSString *)identifier inGroup:(int)groupNumber {
	[dateFilterView removeFromSuperview];
	
	if ([identifier isEqualToString:@"All"]) {
		period = 0;
	}
	
	if ([identifier isEqualToString:@"Today"]) {
		period = 1;
	}
	
	if ([identifier isEqualToString:@"Week"]) {
		period = 2;
	}
	
	if ([identifier isEqualToString:@"Current Month"]) {
		period = 3;
	}
	
	if ([identifier isEqualToString:@"Previous Month"]) {
		period = 4;
	}

	if ([identifier isEqualToString:@"Period"]) {
		period = 5;
		
		NSRect frame = dateFilterView.frame;
		
		frame.origin.x = self.view.frame.size.width - frame.size.width - 12;
		frame.origin.y = 0;
		
		dateFilterView.frame = frame;
		
		[scopeBar addSubview:dateFilterView];
	}
	
	[defaults setObject:[NSNumber numberWithInt:period] forKey:[NSString stringWithFormat:@"Period Filter For %@", account.name]];
		
	[self refresh];
}

#pragma mark -
#pragma mark actions
#pragma mark -

- (IBAction)changeFromDate:(id)sender {	
	isChangeFromDate = YES;
		
	[datePicker setDateValue:fromDate];
	
	NSRect frame = [fromDateButton frame];
	NSPoint menuOrigin = [[fromDateButton superview] convertPoint:NSMakePoint(frame.origin.x - 14, frame.origin.y + frame.size.height - 22) toView:nil];
	
	NSEvent *event = [NSEvent mouseEventWithType:NSLeftMouseDown location:menuOrigin modifierFlags:NSLeftMouseDownMask timestamp:0 windowNumber:[[fromDateButton window] windowNumber] context:[[fromDateButton window] graphicsContext] eventNumber:0 clickCount:1 pressure:1];
		
	[NSMenu popUpContextMenu:dateMenu withEvent:event forView:fromDateButton];	
}

- (IBAction)changeToDate:(id)sender {
	isChangeFromDate = NO;
	
	[datePicker setDateValue:toDate];

	NSRect frame = [toDateButton frame];
	NSPoint menuOrigin = [[toDateButton superview] convertPoint:NSMakePoint(frame.origin.x - 14, frame.origin.y + frame.size.height - 22) toView:nil];
	 
	NSEvent *event = [NSEvent mouseEventWithType:NSLeftMouseDown location:menuOrigin modifierFlags:NSLeftMouseDownMask timestamp:0 windowNumber:[[toDateButton window] windowNumber] context:[[toDateButton window] graphicsContext] eventNumber:0 clickCount:1 pressure:1];
	 
	[NSMenu popUpContextMenu:dateMenu withEvent:event forView:toDateButton];
}

- (IBAction)dateSelected:(id)sender {
	if (isChangeFromDate) {
		fromDate = [[datePicker dateValue] retain];
	} else {
		toDate = [[datePicker dateValue] retain];
	}
	
	[defaults setObject:fromDate forKey:[NSString stringWithFormat:@"Min Date Filter For %@", account.name]];
	[defaults setObject:toDate forKey:[NSString stringWithFormat:@"Max Date Filter For %@", account.name]];
	
	[dateMenu cancelTracking];	
	[self refresh];
}

- (IBAction)addTransaction:(id)sender {
	Transaction *transaction = [[[Transaction alloc] initWithPrimaryKey:-1 database:database] autorelease];

	editTransactionController.transaction = transaction;
	editTransactionController.accounts = accounts;
	editTransactionController.selectedAccount = account;
	
	[editTransactionController showOnWindow:mainWindow];
	//[editTransactionController showOnWindow:nil];
	
	[self refresh];
}

- (IBAction)editTransaction:(id)sender {
	Transaction *transaction = [transactionsController selectedTransaction];
	
	if (transaction != nil) {
		editTransactionController.transaction = transaction;
		editTransactionController.accounts = accounts;
		
		[editTransactionController showOnWindow:mainWindow];
		//[editTransactionController showOnWindow:nil];
		
		[self refresh];
	}
}

- (IBAction)deleteTransaction:(id)sender {
	Transaction *transaction = [transactionsController selectedTransaction];
	
	if (transaction != nil) {
		transaction.enable = NO;
		[transaction save];
		
		lastTransactionId = transaction.primaryKey;
		
		[self refresh];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshView" object:nil];
	}
}

- (IBAction)undoTransaction:(id)sender {
	Transaction *transaction = [[Transaction alloc] initWithPrimaryKey:lastTransactionId database:database];	
	transaction.enable = YES;
	[transaction save];	
	[transaction release];
	
	lastTransactionId = -1;
	[transactionsController refresh];
}

- (IBAction)dublicateTransaction:(id)sender {
	Transaction *transaction = [transactionsController selectedTransaction];
	
	if (transaction != nil) {
		Transaction *newTransaction = [[Transaction alloc] initWithPrimaryKey:-1 database:database];
		
		newTransaction.name = transaction.name;
		newTransaction.fromAccountAmount = transaction.fromAccountAmount;
		newTransaction.toAccountAmount = transaction.toAccountAmount;	
		newTransaction.fromAccount = transaction.fromAccount;
		newTransaction.toAccount = transaction.toAccount;
		newTransaction.date = [NSDate date];
		
		[newTransaction save];
		[newTransaction release];
		
		[self refresh];
	}	
}

- (void)dealloc {
	[account release];
	[transactions release];	
	[formatter release];
	[infoButton release];
	[fromDate release];
	[toDate release];
	[super dealloc];
}

@end
