#import <Cocoa/Cocoa.h>
#import "License.h"

@interface LicenseController : NSWindowController {
	IBOutlet NSTextField *nameField;
	IBOutlet NSTextField *keyField;
	IBOutlet NSTextField *titleLabel;
}

- (void)showOnWindow:(NSWindow *)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
