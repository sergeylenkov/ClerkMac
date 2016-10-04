#import "EditTransactionController.h"

@implementation EditTransactionController

@synthesize transaction;
@synthesize accounts;
@synthesize selectedAccount;

- (void)awakeFromNib {
	fromAccounts = [[NSMutableArray alloc] init];
	toAccounts = [[NSMutableArray alloc] init];
	
	formatter = [[NSNumberFormatter alloc] init];
	
	[formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
}

- (void)showOnWindow:(NSWindow *)sender {
	NSWindow *window = [self window];
	
	NSString *value = [NSString stringWithFormat:@"#,##0.00"];
	[formatter setPositiveFormat:value];
	
	[namesBox setTitleWithMnemonic:@""];
	[datePicker setDateValue:[NSDate date]];

	[fromAccounts removeAllObjects];
	[toAccounts removeAllObjects];
	
	[fromAccountButton removeAllItems];
	[toAccountButton removeAllItems];
	
	int firstDepositIndex = 0;
	
    if (transaction.primaryKey != -1) {
        for (int i = 0; i < [accounts.allReceipts count]; i++) {
            Account *account = [accounts.allReceipts objectAtIndex:i];		
            [fromAccountButton addItemWithTitle:account.name];
            [fromAccounts addObject:account];
        }        
    } else {
        for (int i = 0; i < [accounts.receipts count]; i++) {
            Account *account = [accounts.receipts objectAtIndex:i];		
            [fromAccountButton addItemWithTitle:account.name];
            [fromAccounts addObject:account];
        }
    }
	
	firstDepositIndex = [fromAccounts count];
	
    if (transaction.primaryKey != -1) {
        for (int i = 0; i < [accounts.allDeposits count]; i++) {
            Account *account = [accounts.allDeposits objectAtIndex:i];		
            [fromAccountButton addItemWithTitle:account.name];
            [fromAccounts addObject:account];
        }
        
        for (int i = 0; i < [accounts.allDeposits count]; i++) {
            Account *account = [accounts.allDeposits objectAtIndex:i];		
            [toAccountButton addItemWithTitle:account.name];
            [toAccounts addObject:account];
        }
        
        for (int i = 0; i < [accounts.allExpenses count]; i++) {
            Account *account = [accounts.allExpenses objectAtIndex:i];		
            [toAccountButton addItemWithTitle:account.name];
            [toAccounts addObject:account];
        }
        
        for (int i = 0; i < [accounts.allDebts count]; i++) {
            Account *account = [accounts.allDebts objectAtIndex:i];		
            [toAccountButton addItemWithTitle:account.name];
            [toAccounts addObject:account];
        }
    } else {
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
	
	if ([fromAccounts count] > 0) {
		[fromAccountButton selectItem:[fromAccountButton itemAtIndex:0]];
	}
	
	if ([toAccounts count] > 0) {
		[toAccountButton selectItem:[toAccountButton itemAtIndex:0]];
	}
	
	[fromAmountField setTitleWithMnemonic:[formatter stringFromNumber:[NSNumber numberWithFloat:0.0]]];
	[toAmountField setTitleWithMnemonic:[formatter stringFromNumber:[NSNumber numberWithFloat:0.0]]];
		
	Account *account = [fromAccounts objectAtIndex:[fromAccountButton indexOfSelectedItem]];
	[fromCurrencyField setTitleWithMnemonic:account.currency.shortName];

	account = [toAccounts objectAtIndex:[toAccountButton indexOfSelectedItem]];
	[toCurrencyField setTitleWithMnemonic:account.currency.shortName];

	[titleLabel setFont:[NSFont boldSystemFontOfSize:18]];
	[titleLabel setFrame:NSRectFromCGRect(CGRectMake(15, 0, 300, 32))];

	if (transaction.primaryKey != -1) {
		[titleLabel setTitleWithMnemonic:@"Edit Transaction"];
		
		[namesBox setTitleWithMnemonic:transaction.name];
		[datePicker setDateValue:transaction.date];
		[fromAmountField setTitleWithMnemonic:[formatter stringFromNumber:transaction.fromAccountAmount]];
		[toAmountField setTitleWithMnemonic:[formatter stringFromNumber:transaction.toAccountAmount]];

		for (int i = 0; i < [fromAccounts count]; i++) {
			if (transaction.fromAccount.primaryKey == [[fromAccounts objectAtIndex:i] primaryKey]) {
				[fromAccountButton selectItem:[fromAccountButton itemAtIndex:i]];
				break;
			}
		}
		
		for (int i = 0; i < [toAccounts count]; i++) {
			if (transaction.toAccount.primaryKey == [[toAccounts objectAtIndex:i] primaryKey]) {
				[toAccountButton selectItem:[toAccountButton itemAtIndex:i]];
				break;
			}
		}
		
		[self fromAccountChange:nil];
		[self toAccountChange:nil];
	} else {
		[titleLabel setTitleWithMnemonic:@"New Transaction"];
		
		if (selectedAccount != nil) {
			if (selectedAccount.type == 0 || selectedAccount.type == 1) {
				for (int i = 0; i < [fromAccounts count]; i++) {
					if (selectedAccount.primaryKey == [[fromAccounts objectAtIndex:i] primaryKey]) {
						[fromAccountButton selectItem:[fromAccountButton itemAtIndex:i]];
						break;
					}
				}
			}
			
			if (selectedAccount.type == 2 || selectedAccount.type == 3) {
				for (int i = 0; i < [toAccounts count]; i++) {
					if (selectedAccount.primaryKey == [[toAccounts objectAtIndex:i] primaryKey]) {
						[toAccountButton selectItem:[toAccountButton itemAtIndex:i]];
						break;
					}
				}
				
				[fromAccountButton selectItem:[fromAccountButton itemAtIndex:firstDepositIndex]];
			}
			
			[self fromAccountChange:nil];
			[self toAccountChange:nil];
		}		
	}
	
	[self fromAccountChange:nil];
	
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
	
	if (fromAccount.currency.primaryKey != toAccount.currency.primaryKey && [toAmountField floatValue] == 0) {
		NSNumber *amount = [formatter numberFromString:[fromAmountField stringValue]];
		float convertAmount = [Currency convertAmount:amount fromCurrency:fromAccount.currency toCurrency:toAccount.currency onDate:transaction.date];
			
		[toAmountField setTitleWithMnemonic:[formatter stringFromNumber:[NSNumber numberWithFloat:convertAmount]]];
	}
}

- (IBAction)cancel:(id)sender {
	[NSApp stopModal];
}

- (IBAction)done:(id)sender {
	transaction.name = [namesBox stringValue];
	transaction.date = [datePicker dateValue];
	
	float oldValue = [transaction.fromAccountAmount floatValue];
	
	transaction.fromAccountAmount = [formatter numberFromString:[fromAmountField stringValue]];
	transaction.toAccountAmount = [formatter numberFromString:[toAmountField stringValue]];	

	transaction.fromAccount = [fromAccounts objectAtIndex:[fromAccountButton indexOfSelectedItem]];
	transaction.toAccount = [toAccounts objectAtIndex:[toAccountButton indexOfSelectedItem]];
	
	if (transaction.fromAccount.type == 1) {
		if ([[transaction.fromAccount balance] floatValue] - ([transaction.fromAccountAmount floatValue] - oldValue) < 0) {
			NSAlert *alert = [NSAlert alertWithMessageText:@"Warning" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:[NSString stringWithFormat:@"You have not enough funds on account \"%@\" for transaction.", transaction.fromAccount.name]];
			[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
			
			return;
		}
	}	
	
	[transaction save];
	
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
		NSNumber *number = [formatter numberFromString:[field stringValue]];
		
		if (number == nil) {
			number = [NSNumber numberWithInt:0];
		}
		
		[field setTitleWithMnemonic:[formatter stringFromNumber:number]];		
	}
}

- (void)dealloc {
	[namesBox release];
	[fromAmountField release];
	[toAmountField release];
	[datePicker release];
	[fromAccountButton release];
	[toAccountButton release];
	[fromAccounts release];
	[toAccounts release];
	[formatter release];
	[super dealloc];
}

@end
