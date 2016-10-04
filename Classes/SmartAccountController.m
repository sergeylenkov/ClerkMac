#import "SmartAccountController.h"

@implementation SmartAccountController

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
	
	isDatePickerHidden = YES;
	
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
}

- (void)refresh {
	Currency *currency = [[[Currency alloc] initWithPrimaryKey:[[defaults objectForKey:@"Base Currency"] intValue] database:database] autorelease];
		
	NSMutableArray *accountTransaction;
	
	if (period == 5) {
		accountTransaction = [account transactionsFromDate:fromDate toDate:toDate withFilter:filter];
	} else {
		accountTransaction = [account transactionsByPeriod:period withFilter:filter];
	}	

	float amount = 0.0;
	
	for (int i = 0; i < [accountTransaction count]; i++) {
		Transaction *transaction = [accountTransaction objectAtIndex:i];
		
		if (account.type == 0) {
			amount = amount + [Currency convertAmount:transaction.fromAccountAmount fromCurrency:transaction.fromAccount.currency toCurrency:currency onDate:transaction.date];
		}
		
		if (account.type == 2) {
			amount = amount + [Currency convertAmount:transaction.toAccountAmount fromCurrency:transaction.toAccount.currency toCurrency:currency onDate:transaction.date];
		}
	}

	NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithFloat:amount]];
	
	[infoButton setTitle:[NSString stringWithFormat:@"%d transactions, %@ %@", [accountTransaction count], formatted, currency.shortName]];
	
	[transactions removeAllObjects];
	
	for (Transaction *transaction in accountTransaction) {
		TableTransaction *tableTransaction = [[[TableTransaction alloc] init] autorelease];
		
		tableTransaction.name = transaction.name;
		
		if (account.type == 0) {
			tableTransaction.accountName = transaction.fromAccount.name;
			tableTransaction.accountIcon = transaction.fromAccount.icon;
			tableTransaction.amount = transaction.fromAccountAmount;
			tableTransaction.isIncoming = YES;
		}
		
		if (account.type == 2 || account.type == 3) {
			tableTransaction.accountName = transaction.toAccount.name;
			tableTransaction.accountIcon = transaction.toAccount.icon;
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
	return [NSArray arrayWithObjects:@"All", @"Today", @"Week", @"Current Month", @"Previous Month", @"Period", nil];
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
	Transaction *transaction = [[Transaction alloc] initWithPrimaryKey:-1 database:database];
			
	editTransactionController.transaction = transaction;
	editTransactionController.accounts = accounts;
	editTransactionController.selectedAccount = nil;
			
	[transaction release];
	[editTransactionController showOnWindow:mainWindow];
			
	[self refresh];
}

- (IBAction)editTransaction:(id)sender {
	Transaction *transaction = [transactionsController selectedTransaction];
	
	if (transaction != nil) {
		editTransactionController.transaction = transaction;
		editTransactionController.accounts = accounts;
		
		[editTransactionController showOnWindow:mainWindow];
		
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
	[accounts release];
	[infoButton release];
	[formatter release];
	[fromDate release];
	[toDate release];
	[defaults release];
	[super dealloc];
}

@end
