#import <Cocoa/Cocoa.h>
#import "PTKeychain.h"
#import "NSDate+Format.h"
#import "CurrenciesController.h"
#import "PasswordController.h"

@interface PrefsController : NSWindowController <NSToolbarDelegate> {
    IBOutlet NSView *generalView;
	IBOutlet NSView *currenciesView;
	IBOutlet NSView *updateView;
	IBOutlet NSButton *requirePasswordButton;
	IBOutlet NSSecureTextField *passwordField;
	IBOutlet CurrenciesController *currenciesController;
	IBOutlet PasswordController *passwordController;
	NSUserDefaults *defaults;
	sqlite3 *database;	
}

@property (nonatomic, assign) sqlite3 *database;

- (void)setPrefView:(id)sender;
- (void)refresh;

- (IBAction)setRequirePassword:(id)sender;
- (IBAction)changePassword:(id)sender;

@end
