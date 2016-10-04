#import "EditAccountController.h"

#define ICONS_COUNT 43

@implementation EditAccountController

@synthesize account;
@synthesize currencies;
@synthesize isCanceled;

- (void)awakeFromNib {
	formatter = [[NSNumberFormatter alloc] init];
	
	[formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];

	[formatter setPositiveFormat:[NSString stringWithFormat:@"#,##0.00"]];
}

- (void)showOnWindow:(NSWindow *)sender {
	NSWindow *window = [self window];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[amountField setTitleWithMnemonic:[formatter stringFromNumber:[NSNumber numberWithFloat:0.0]]];
	
	[currencyButton removeAllItems];
	
	for (int i = 0; i < [currencies count]; i++) {
		Currency *currency = [currencies objectAtIndex:i];
		[currencyButton addItemWithTitle:currency.shortName];
		
		if (currency.primaryKey == [[defaults objectForKey:@"Base Currency"] intValue]) {
			[currencyButton selectItem:[currencyButton itemAtIndex:i]];			
		}
	}	
	
	[titleLabel setFont:[NSFont boldSystemFontOfSize:18]];
	[titleLabel setFrame:NSRectFromCGRect(CGRectMake(15, 0, 300, 32))];
	
	[iconButton removeAllItems];
	
	NSString *bundlePath = [[NSBundle mainBundle] resourcePath];

	for (int i = 0; i < ICONS_COUNT; i++) {
		[iconButton addItemWithTitle:@""];
				
		NSImage *iconImage = [[NSImage alloc] initWithContentsOfFile:[bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.png", i]]];
		[iconImage setSize:NSMakeSize(16, 16)];
				
		[[iconButton itemAtIndex:i] setImage:iconImage];
	}
		
	if (account.primaryKey != -1) {
		if (account.type == 0) {
			[titleLabel setTitleWithMnemonic:@"Edit Receipt"];
		}
		
		if (account.type == 1) {
			[titleLabel setTitleWithMnemonic:@"Edit Deposit"];
		}
		
		if (account.type == 2) {
			[titleLabel setTitleWithMnemonic:@"Edit Expense"];
		}
		
		if (account.type == 3) {
			[titleLabel setTitleWithMnemonic:@"Edit Debt"];
		}
		
		[nameField setTitleWithMnemonic:account.name];
				
		if (account.iconIndex >= [iconButton numberOfItems]) {
			[iconButton selectItem:[iconButton itemAtIndex:0]];
		} else {
			[iconButton selectItem:[iconButton itemAtIndex:account.iconIndex]];
		}
		
		for (int i = 0; i < [currencies count]; i++) {
			if (account.currency.primaryKey == [[currencies objectAtIndex:i] primaryKey]) {
				[currencyButton selectItem:[currencyButton itemAtIndex:i]];
				break;
			}
		}
		
		[amountField setEditable:NO];
		[amountField setTextColor:[NSColor grayColor]];
	} else {
		if (account.type == 0) {
			[titleLabel setTitleWithMnemonic:@"New Receipt"];
		}
		
		if (account.type == 1) {
			[titleLabel setTitleWithMnemonic:@"New Deposit"];
		}
		
		if (account.type == 2) {
			[titleLabel setTitleWithMnemonic:@"New Expense"];
		}
		
		if (account.type == 3) {
			[titleLabel setTitleWithMnemonic:@"New Debt"];
		}
		
		[nameField setTitleWithMnemonic:@""];
		[iconButton selectItem:[iconButton itemAtIndex:0]];

		[amountField setEditable:YES];
		[amountField setTextColor:[NSColor blackColor]];
	}
	
	[window makeFirstResponder:nameField];
	
	[NSApp beginSheet:window modalForWindow:sender modalDelegate:nil didEndSelector:nil contextInfo:nil];
	[NSApp runModalForWindow:window];
	
	[NSApp endSheet:window];
	[window orderOut:self];	
}

- (IBAction)cancel:(id)sender {
	isCanceled = YES;
	[NSApp stopModal];
}

- (IBAction)done:(id)sender {
	account.name = [nameField stringValue];
	account.amount = [formatter numberFromString:[amountField stringValue]];
	account.iconIndex = [iconButton indexOfSelectedItem];
	
	Currency *currency = [currencies objectAtIndex:[currencyButton indexOfSelectedItem]];
	account.currency = currency;	
	
	NSString *bundlePath = [[NSBundle mainBundle] resourcePath];
	NSImage *iconImage = [[NSImage alloc] initWithContentsOfFile:[bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.png", account.iconIndex]]];
	[iconImage setSize:NSMakeSize(16, 16)];
	
	account.icon = iconImage;
	
	[account save];
	
	isCanceled = NO;
	[NSApp stopModal];
}

- (void)controlTextDidChange:(NSNotification *)notification {
	NSTextField *field = [notification object];
	
	if (field == amountField) {
		NSString *newValue = [[field stringValue] stringByReplacingOccurrencesOfString:@"." withString:[formatter decimalSeparator]];
		newValue = [newValue stringByReplacingOccurrencesOfString:@"," withString:[formatter decimalSeparator]]; 
		[field setTitleWithMnemonic:newValue];
	}
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
	NSTextField *field = [notification object];
	
	[formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	
	NSString *value = [NSString stringWithFormat:@"#,##0.00"];
	[formatter setPositiveFormat:value];
	
	if (field == amountField) {
		[field setTitleWithMnemonic:[formatter stringFromNumber:[NSNumber numberWithFloat:[field floatValue]]]];
	}	
}

- (void)dealloc {
	[nameField release];
	[amountField release];
    [account release];
	[formatter release];
	[super dealloc];
}

@end
