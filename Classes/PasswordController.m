#import "PasswordController.h"

@implementation PasswordController

- (void)showOnWindow:(NSWindow *)sender {
	NSWindow *window = [self window];
	
	[doneButton setEnabled:NO];
	
	[NSApp beginSheet:window modalForWindow:sender modalDelegate:nil didEndSelector:nil contextInfo:nil];
	[NSApp runModalForWindow:window];
	
	[NSApp endSheet:window];
	[window orderOut:self];	
}

- (IBAction)changePassword:(id)sender {
	BOOL enable = NO;
	NSString *password = [PTKeychain passwordForLabel:PASSWORD_LABEL account:@""];

	if ([[currentPassword stringValue] isEqualToString:password]) {
		if (![[newPassword stringValue] isEqualToString:@""] && ![[confirmPassword stringValue] isEqualToString:@""]) {
			if ([[newPassword stringValue] isEqualToString:[confirmPassword stringValue]]) {
				enable = YES;				
			}
		}
	}

	[doneButton setEnabled:enable];
}

- (void)controlTextDidChange:(NSNotification *)notification {
	[self changePassword:nil];
}

- (IBAction)cancel:(id)sender {	
	[NSApp stopModal];
}

- (IBAction)done:(id)sender {
	if ([PTKeychain keychainExistsWithLabel:PASSWORD_LABEL forAccount:@""] > 0) {
		[PTKeychain modifyKeychainPassword:[newPassword stringValue] withLabel:PASSWORD_LABEL forAccount:@""];
	} else {
		[PTKeychain addKeychainPassword:[newPassword stringValue] withLabel:PASSWORD_LABEL forAccount:@""];
	}
	
	[NSApp stopModal];
}

@end
