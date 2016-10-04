#import "EditRateController.h"

@implementation EditRateController

@synthesize rate;
@synthesize currencies;
@synthesize fromCurrency;
@synthesize toCurrency;

- (void)showOnWindow:(NSWindow *)sender {
	NSWindow *window = [self window];
	
	formatter = [[NSNumberFormatter alloc] init];
	
	[formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	
	NSString *value = [NSString stringWithFormat:@"#,##0.00"];
	[formatter setPositiveFormat:value];
	
	[fromCurrencyButton removeAllItems];
	[toCurrencyButton removeAllItems];
	
	int fromCurrencyIndex = 0;
	int toCurrencyIndex = 0;
	
	for (int i = 0; i < [currencies count]; i++) {
		Currency *currency = [currencies objectAtIndex:i];
		
		[fromCurrencyButton addItemWithTitle:currency.shortName];
		[toCurrencyButton addItemWithTitle:currency.shortName];
		
		if (currency.primaryKey == fromCurrency.primaryKey) {
			fromCurrencyIndex = i;
		}
		
		if (currency.primaryKey == toCurrency.primaryKey) {
			toCurrencyIndex = i;
		}
	}	
	
	[fromCurrencyButton selectItem:[fromCurrencyButton itemAtIndex:fromCurrencyIndex]];
	[toCurrencyButton selectItem:[toCurrencyButton itemAtIndex:toCurrencyIndex]];
	
	[rateField setTitleWithMnemonic:[formatter stringFromNumber:[NSNumber numberWithFloat:0.0]]];
	
	[titleLabel setFont:[NSFont boldSystemFontOfSize:18]];
	[titleLabel setFrame:NSRectFromCGRect(CGRectMake(15, 0, 300, 32))];
	
	[datePicker setDateValue:rate.date];
	
	if (rate.primaryKey != -1) {
		[titleLabel setTitleWithMnemonic:@"Edit Rate"];
		[rateField setTitleWithMnemonic:[formatter stringFromNumber:rate.rate]];
		
		for (int i = 0; i < [currencies count]; i++) {
			if (rate.fromCurrency.primaryKey == [[currencies objectAtIndex:i] primaryKey]) {
				[fromCurrencyButton selectItem:[fromCurrencyButton itemAtIndex:i]];
				break;
			}
		}
		
		for (int i = 0; i < [currencies count]; i++) {
			if (rate.toCurrency.primaryKey == [[currencies objectAtIndex:i] primaryKey]) {
				[toCurrencyButton selectItem:[toCurrencyButton itemAtIndex:i]];
				break;
			}
		}
	} else {
		[titleLabel setTitleWithMnemonic:@"New Rate"];		
	}
	
	NSString *newValue = [[rateField stringValue] stringByReplacingOccurrencesOfString:@"." withString:[formatter decimalSeparator]];
	newValue = [newValue stringByReplacingOccurrencesOfString:@"," withString:[formatter decimalSeparator]]; 
	[rateField setTitleWithMnemonic:newValue];
	
	[window makeFirstResponder:rateField];
	
	[NSApp beginSheet:window modalForWindow:sender modalDelegate:nil didEndSelector:nil contextInfo:nil];
	[NSApp runModalForWindow:window];
	
	[NSApp endSheet:window];
	[window orderOut:self];
}

- (IBAction)cancel:(id)sender {
	[NSApp stopModal];
}

- (IBAction)done:(id)sender {
	rate.fromCurrency = [currencies objectAtIndex:[fromCurrencyButton indexOfSelectedItem]];
	rate.toCurrency = [currencies objectAtIndex:[toCurrencyButton indexOfSelectedItem]];
	rate.rate = [formatter numberFromString:[rateField stringValue]];
	rate.date = [datePicker dateValue];
	
	[rate save];
	
	[NSApp stopModal];	
}

- (void)controlTextDidChange:(NSNotification *)notification {
	NSTextField *field = [notification object];
	
	if (field == rateField) {
		NSString *newValue = [[field stringValue] stringByReplacingOccurrencesOfString:@"." withString:[formatter decimalSeparator]];
		newValue = [newValue stringByReplacingOccurrencesOfString:@"," withString:[formatter decimalSeparator]]; 
		
		[field setTitleWithMnemonic:newValue];
	}
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
	NSTextField *field = [notification object];	
	
	if (field == rateField) {
		[field setTitleWithMnemonic:[formatter stringFromNumber:[formatter numberFromString:[field stringValue]]]];
	}
}

- (void)dealloc {
	[titleLabel release];
	[rateField release];
	[fromCurrencyButton release];
	[toCurrencyButton release];
    [rate release];
	[currencies release];
	[formatter release];
	[super dealloc];
}

@end
