#import <Cocoa/Cocoa.h>
#import "Account.h"
#import "Currency.h"

@interface EditAccountController : NSWindowController {
	IBOutlet NSTextField *nameField;
	IBOutlet NSTextField *amountField;
	IBOutlet NSPopUpButton *currencyButton;
	IBOutlet NSTextField *titleLabel;
	IBOutlet NSPopUpButton *iconButton;
	Account *account;
	NSMutableArray *currencies;
	NSNumberFormatter *formatter;
	BOOL isCanceled;
}

@property(nonatomic, retain) Account *account;
@property(nonatomic, retain) NSMutableArray *currencies;
@property (nonatomic, assign) BOOL isCanceled;

- (void)showOnWindow:(NSWindow *)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
