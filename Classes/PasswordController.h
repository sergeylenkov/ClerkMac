#import <Cocoa/Cocoa.h>
#import "PTKeychain.h"

@interface PasswordController : NSWindowController {
	IBOutlet NSTextField *currentPassword;
	IBOutlet NSTextField *newPassword;
	IBOutlet NSTextField *confirmPassword;
	IBOutlet NSButton *doneButton;
}

- (void)showOnWindow:(NSWindow *)sender;
- (IBAction)changePassword:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
