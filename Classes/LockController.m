#import "LockController.h"

@implementation LockController

- (void)focusPasswordField {
	[[self.view window] makeFirstResponder:passwordField];
}

- (IBAction)unlock:(id)sender {
	NSString *password = [PTKeychain passwordForLabel:PASSWORD_LABEL account:@""];

	if ([password isEqualToString:[passwordField stringValue]]) {
		[self.view removeFromSuperview];
	} else {
		NSAlert *alert = [NSAlert alertWithMessageText:@"Incorrect password" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Password what you enter is incorrect."];
		[alert runModal];
	}
}

@end
