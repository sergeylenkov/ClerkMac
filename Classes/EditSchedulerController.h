#import <Cocoa/Cocoa.h>
#import "Scheduler.h"
#import "Account.h"
#import "Accounts.h"

@interface EditSchedulerController : NSWindowController {
	IBOutlet NSTextField *titleLabel;
	IBOutlet NSComboBox *namesBox;
	IBOutlet NSPopUpButton *fromAccountButton;
	IBOutlet NSPopUpButton *toAccountButton;
	IBOutlet NSTextField *fromAmountField;
	IBOutlet NSTextField *toAmountField;
	IBOutlet NSTextField *fromCurrencyField;
	IBOutlet NSTextField *toCurrencyField;	
	IBOutlet NSPopUpButton *repeatPeriodButton;
	IBOutlet NSPopUpButton *repeatDayButton;
	IBOutlet NSPopUpButton *repeatMonthButton;
	IBOutlet NSTextField *everyLabel;
	IBOutlet NSTextField *dayLabel;
	Scheduler *scheduler;
	Accounts *accounts;
	NSMutableArray *fromAccounts;
	NSMutableArray *toAccounts;
	NSNumberFormatter *formatter;
}

@property(nonatomic, retain) Scheduler *scheduler;
@property(nonatomic, retain) Accounts *accounts;

- (void)showOnWindow:(NSWindow *)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)fromAccountChange:(id)sender;
- (IBAction)toAccountChange:(id)sender;
- (IBAction)changeFromAmount:(id)sender;
- (IBAction)repeatPeriodChange:(id)sender;

@end
