#import <Cocoa/Cocoa.h>
#import "PTKeychain.h"

@interface LockController : NSViewController {
	IBOutlet NSTextField *passwordField;
	IBOutlet NSImageView *iconView;
	IBOutlet NSButton *unlockButton;
}

- (void)focusPasswordField;
- (IBAction)unlock:(id)sender;

@end
