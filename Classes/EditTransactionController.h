#import <Cocoa/Cocoa.h>
#import "Transaction.h"
#import "Account.h"
#import "Accounts.h"

@interface EditTransactionController : NSWindowController {
	IBOutlet NSTextField *titleLabel;
	IBOutlet NSComboBox *namesBox;
	IBOutlet NSDatePicker *datePicker;
	IBOutlet NSPopUpButton *fromAccountButton;
	IBOutlet NSPopUpButton *toAccountButton;
	IBOutlet NSTextField *fromAmountField;
	IBOutlet NSTextField *toAmountField;
	IBOutlet NSTextField *fromCurrencyField;
	IBOutlet NSTextField *toCurrencyField;	
	Transaction *transaction;
	Accounts *accounts;
	NSMutableArray *fromAccounts;
	NSMutableArray *toAccounts;
	Account *selectedAccount;
	NSNumberFormatter *formatter;
}

@property(nonatomic, retain) Transaction *transaction;
@property(nonatomic, retain) Accounts *accounts;
@property(nonatomic, retain) Account *selectedAccount;

- (void)showOnWindow:(NSWindow *)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)fromAccountChange:(id)sender;
- (IBAction)toAccountChange:(id)sender;
- (IBAction)changeFromAmount:(id)sender;

@end
