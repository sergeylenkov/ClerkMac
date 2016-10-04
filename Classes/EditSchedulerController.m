#import "EditSchedulerController.h"

@implementation EditSchedulerController

@synthesize scheduler;
@synthesize accounts;

- (void)awakeFromNib {
	formatter = [[NSNumberFormatter alloc] init];
	
	[formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];

	[formatter setPositiveFormat:@"#,##0.00"];
	
	fromAccounts = [[NSMutableArray alloc] init];
	toAccounts = [[NSMutableArray alloc] init];
}

- (void)showOnWindow:(NSWindow *)sender {
	NSWindow *window = [self window];
	
	[namesBox setTitleWithMnemonic:@""];
	
	[fromAccountButton removeAllItems];
	[toAccountButton removeAllItems];
		
	for (int i = 0; i < [accounts.receipts count]; i++) {
		Account *account = [accounts.receipts objectAtIndex:i];		
		[fromAccountButton addItemWithTitle:account.name];
		[fromAccounts addObject:account];
	}
	
	for (int i = 0; i < [accounts.deposits count]; i++) {
		Account *account = [accounts.deposits objectAtIndex:i];		
		[fromAccountButton addItemWithTitle:account.name];
		[fromAccounts addObject:account];
	}
	
	for (int i = 0; i < [accounts.deposits count]; i++) {
		Account *account = [accounts.deposits objectAtIndex:i];		
		[toAccountButton addItemWithTitle:account.name];
		[toAccounts addObject:account];
	}
	
	for (int i = 0; i < [accounts.expenses count]; i++) {
		Account *account = [accounts.expenses objectAtIndex:i];		
		[toAccountButton addItemWithTitle:account.name];
		[toAccounts addObject:account];
	}
	
	for (int i = 0; i < [accounts.debts count]; i++) {
		Account *account = [accounts.debts objectAtIndex:i];		
		[toAccountButton addItemWithTitle:account.name];
		[toAccounts addObject:account];
	}
	
	NSString *bundlePath = [[NSBundle mainBundle] resourcePath];
	
	for (int i = 0; i < [fromAccountButton numberOfItems]; i++) {
		Account *account = [fromAccounts objectAtIndex:i];
		
		NSImage *iconImage = [[[NSImage alloc] initWithContentsOfFile:[bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.png", account.iconIndex]]] autorelease];
		[iconImage setSize:NSMakeSize(16, 16)];
		
		[[fromAccountButton itemAtIndex:i] setImage:iconImage];
	}
	
	for (int i = 0; i < [toAccountButton numberOfItems]; i++) {
		Account *account = [toAccounts objectAtIndex:i];
		
		NSImage *iconImage = [[[NSImage alloc] initWithContentsOfFile:[bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.png", account.iconIndex]]] autorelease];
		[iconImage setSize:NSMakeSize(16, 16)];
		
		[[toAccountButton itemAtIndex:i] setImage:iconImage];
	}
	
	[repeatPeriodButton selectItem:[repeatPeriodButton itemAtIndex:0]];
	[repeatDayButton selectItem:[repeatDayButton itemAtIndex:0]];
	[repeatMonthButton selectItem:[repeatMonthButton itemAtIndex:0]];
	
	[fromAccountButton selectItem:[fromAccountButton itemAtIndex:0]];
	[toAccountButton selectItem:[toAccountButton itemAtIndex:0]];
	
	[fromAmountField setTitleWithMnemonic:[formatter stringFromNumber:[NSNumber numberWithFloat:0.0]]];
	[toAmountField setTitleWithMnemonic:[formatter stringFromNumber:[NSNumber numberWithFloat:0.0]]];
	
	Account *account = [fromAccounts objectAtIndex:[fromAccountButton indexOfSelectedItem]];
	[fromCurrencyField setTitleWithMnemonic:account.currency.shortName];
	
	account = [toAccounts objectAtIndex:[toAccountButton indexOfSelectedItem]];
	[toCurrencyField setTitleWithMnemonic:account.currency.shortName];
	
	[titleLabel setFont:[NSFont boldSystemFontOfSize:18]];
	[titleLabel setFrame:NSRectFromCGRect(CGRectMake(15, 0, 300, 32))];
	
	if (scheduler.primaryKey != -1) {
		[titleLabel setTitleWithMnemonic:@"Edit Task"];
		
		[namesBox setTitleWithMnemonic:scheduler.name];
		[fromAmountField setTitleWithMnemonic:[formatter stringFromNumber:scheduler.fromAccountAmount]];
		[toAmountField setTitleWithMnemonic:[formatter stringFromNumber:scheduler.toAccountAmount]];
		
		for (int i = 0; i < [fromAccounts count]; i++) {
			if (scheduler.fromAccount.primaryKey == [[fromAccounts objectAtIndex:i] primaryKey]) {
				[fromAccountButton selectItem:[fromAccountButton itemAtIndex:i]];
				break;
			}
		}
		
		for (int i = 0; i < [toAccounts count]; i++) {
			if (scheduler.toAccount.primaryKey == [[toAccounts objectAtIndex:i] primaryKey]) {
				[toAccountButton selectItem:[toAccountButton itemAtIndex:i]];
				break;
			}
		}
		
		[self fromAccountChange:nil];
		[self toAccountChange:nil];
				
		[repeatPeriodButton selectItem:[repeatPeriodButton itemAtIndex:scheduler.periodType]];
		
		[self repeatPeriodChange:nil];
		
		[repeatDayButton selectItem:[repeatDayButton itemAtIndex:scheduler.day - 1]];
		[repeatMonthButton selectItem:[repeatMonthButton itemAtIndex:scheduler.month - 1]];
	} else {
		[titleLabel setTitleWithMnemonic:@"New Task"];		
		[self repeatPeriodChange:nil];
	}
	
	NSString *newValue = [[fromAmountField stringValue] stringByReplacingOccurrencesOfString:@"." withString:[formatter decimalSeparator]];
	newValue = [newValue stringByReplacingOccurrencesOfString:@"," withString:[formatter decimalSeparator]]; 
	[fromAmountField setTitleWithMnemonic:newValue];
	
	newValue = [[toAmountField stringValue] stringByReplacingOccurrencesOfString:@"." withString:[formatter decimalSeparator]];
	newValue = [newValue stringByReplacingOccurrencesOfString:@"," withString:[formatter decimalSeparator]]; 
	[toAmountField setTitleWithMnemonic:newValue];
	 
	[window makeFirstResponder:namesBox];
	
	[NSApp beginSheet:window modalForWindow:sender modalDelegate:nil didEndSelector:nil contextInfo:nil];
	[NSApp runModalForWindow:window];
	
	[NSApp endSheet:window];
	[window orderOut:self];
}

- (IBAction)fromAccountChange:(id)sender {
	Account *account = [fromAccounts objectAtIndex:[fromAccountButton indexOfSelectedItem]];
	[fromCurrencyField setTitleWithMnemonic:account.currency.shortName];
	
	NSMutableArray *names = [account transactionNames];
	
	[namesBox removeAllItems];
	
	for (int i = 0; i < [names count]; i++) {
		[namesBox addItemWithObjectValue:[names objectAtIndex:i]];
	}
}

- (IBAction)toAccountChange:(id)sender {
	Account *account = [toAccounts objectAtIndex:[toAccountButton indexOfSelectedItem]];
	[toCurrencyField setTitleWithMnemonic:account.currency.shortName];
}

- (IBAction)changeFromAmount:(id)sender {
	Account *fromAccount = [fromAccounts objectAtIndex:[fromAccountButton indexOfSelectedItem]];
	Account *toAccount = [toAccounts objectAtIndex:[toAccountButton indexOfSelectedItem]];
	
	if (fromAccount.currency.primaryKey == toAccount.currency.primaryKey && [toAmountField floatValue] == 0) {
		[toAmountField setTitleWithMnemonic:[formatter stringFromNumber:[formatter numberFromString:[fromAmountField stringValue]]]];
	}
}

- (IBAction)repeatPeriodChange:(id)sender {
	[repeatDayButton removeAllItems];
	
	if ([repeatPeriodButton indexOfSelectedItem] == 0 || [repeatPeriodButton indexOfSelectedItem] == 1) {
		[repeatDayButton addItemWithTitle:@"1st"];
		[repeatDayButton addItemWithTitle:@"2nd"];
		[repeatDayButton addItemWithTitle:@"3rd"];
		[repeatDayButton addItemWithTitle:@"4th"];
		[repeatDayButton addItemWithTitle:@"5th"];
		[repeatDayButton addItemWithTitle:@"6th"];
		[repeatDayButton addItemWithTitle:@"7th"];
	}
	
	if ([repeatPeriodButton indexOfSelectedItem] == 2 || [repeatPeriodButton indexOfSelectedItem] == 3) {
		[repeatDayButton addItemWithTitle:@"1st"];
		[repeatDayButton addItemWithTitle:@"2nd"];
		[repeatDayButton addItemWithTitle:@"3rd"];
		[repeatDayButton addItemWithTitle:@"4th"];
		[repeatDayButton addItemWithTitle:@"5th"];
		[repeatDayButton addItemWithTitle:@"6th"];
		[repeatDayButton addItemWithTitle:@"7th"];
		[repeatDayButton addItemWithTitle:@"8th"];
		[repeatDayButton addItemWithTitle:@"9th"];
		[repeatDayButton addItemWithTitle:@"10th"];
		[repeatDayButton addItemWithTitle:@"11th"];
		[repeatDayButton addItemWithTitle:@"12th"];
		[repeatDayButton addItemWithTitle:@"13th"];
		[repeatDayButton addItemWithTitle:@"14th"];
		[repeatDayButton addItemWithTitle:@"15th"];
		[repeatDayButton addItemWithTitle:@"16th"];
		[repeatDayButton addItemWithTitle:@"17th"];
		[repeatDayButton addItemWithTitle:@"18th"];
		[repeatDayButton addItemWithTitle:@"19th"];
		[repeatDayButton addItemWithTitle:@"20th"];
		[repeatDayButton addItemWithTitle:@"21st"];
		[repeatDayButton addItemWithTitle:@"22nd"];
		[repeatDayButton addItemWithTitle:@"23rd"];
		[repeatDayButton addItemWithTitle:@"24th"];
		[repeatDayButton addItemWithTitle:@"25th"];
		[repeatDayButton addItemWithTitle:@"26th"];
		[repeatDayButton addItemWithTitle:@"27th"];
		[repeatDayButton addItemWithTitle:@"28th"];
		[repeatDayButton addItemWithTitle:@"29th"];
		[repeatDayButton addItemWithTitle:@"30th"];
		[repeatDayButton addItemWithTitle:@"31st"];
	}
	
	[everyLabel setHidden:YES];
	[dayLabel setHidden:YES];
	[repeatDayButton setHidden:YES];
	[repeatMonthButton setHidden:YES];
	
	if ([repeatPeriodButton indexOfSelectedItem] == 1 || [repeatPeriodButton indexOfSelectedItem] == 2) {		
		[dayLabel setTitleWithMnemonic:@"day"];
		
		[everyLabel setHidden:NO];
		[dayLabel setHidden:NO];
		[repeatDayButton setHidden:NO];
	}
	
	if ([repeatPeriodButton indexOfSelectedItem] == 3) {	
		[dayLabel setTitleWithMnemonic:@"day in"];
		
		[everyLabel setHidden:NO];
		[dayLabel setHidden:NO];
		[repeatDayButton setHidden:NO];
		[repeatMonthButton setHidden:NO];
	}
}

- (IBAction)cancel:(id)sender {
	[NSApp stopModal];
}

- (IBAction)done:(id)sender {
	scheduler.name = [namesBox stringValue];
	
	scheduler.periodType = [repeatPeriodButton indexOfSelectedItem];
	scheduler.day = [repeatDayButton indexOfSelectedItem] + 1;
	scheduler.month = [repeatMonthButton indexOfSelectedItem] + 1;
	
	scheduler.fromAccountAmount = [formatter numberFromString:[fromAmountField stringValue]];
	scheduler.toAccountAmount = [formatter numberFromString:[toAmountField stringValue]];
	
	scheduler.fromAccount = [fromAccounts objectAtIndex:[fromAccountButton indexOfSelectedItem]];
	scheduler.toAccount = [toAccounts objectAtIndex:[toAccountButton indexOfSelectedItem]];
	
	[scheduler calculateNextDate];
	[scheduler save];
	
	[NSApp stopModal];	
}

- (void)controlTextDidChange:(NSNotification *)notification {
	NSTextField *field = [notification object];
	
	if (field == fromAmountField || field == toAmountField) {
		NSString *newValue = [[field stringValue] stringByReplacingOccurrencesOfString:@"." withString:[formatter decimalSeparator]];
		newValue = [newValue stringByReplacingOccurrencesOfString:@"," withString:[formatter decimalSeparator]]; 
		
		[field setTitleWithMnemonic:newValue];
	}
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
	NSTextField *field = [notification object];	
	
	if (field == fromAmountField || field == toAmountField) {
		[field setTitleWithMnemonic:[formatter stringFromNumber:[formatter numberFromString:[field stringValue]]]];
	}
}

- (void)dealloc {
	[namesBox release];
	[fromAmountField release];
	[toAmountField release];
	[fromAccountButton release];
	[toAccountButton release];
	[repeatPeriodButton release];
	[repeatDayButton release];
    [scheduler release];
	[accounts release];
	[fromAccounts release];
	[toAccounts release];
	[formatter release];
	[super dealloc];
}

@end
