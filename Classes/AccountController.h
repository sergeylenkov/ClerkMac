#import <Cocoa/Cocoa.h>
#import "Account.h"
#import "Accounts.h"
#import "Transaction.h"
#import "MGScopeBar.h"
#import "TransactionsController.h"
#import "EditTransactionController.h"

@interface AccountController : NSViewController <MGScopeBarDelegate> {	
	IBOutlet MGScopeBar *scopeBar;
	IBOutlet NSView *dateFilterView;
	IBOutlet NSButton *fromDateButton;
	IBOutlet NSButton *toDateButton;	
	IBOutlet NSDatePicker *datePicker;
	IBOutlet NSMenu *dateMenu;
	IBOutlet TransactionsController *transactionsController;	
	NSWindow *mainWindow;
	sqlite3 *database;
	Account *account;
	Accounts *accounts;
	NSMutableArray *transactions;
	NSInteger period;
	NSButton *infoButton;
	NSInteger lastTransactionId;
	EditTransactionController *editTransactionController;
	NSNumberFormatter *formatter;
	NSString *filter;
	NSDate *fromDate;
	NSDate *toDate;
	BOOL isChangeFromDate;
	NSUserDefaults *defaults;
}

@property (nonatomic, retain) NSWindow *mainWindow;
@property (nonatomic, assign) sqlite3 *database;
@property (nonatomic, retain) Account *account;
@property (nonatomic, retain) Accounts *accounts;
@property (nonatomic, retain) NSButton *infoButton;
@property (nonatomic, copy) NSString *filter;

- (void)initialization;
- (void)refresh;

- (IBAction)changeFromDate:(id)sender;
- (IBAction)changeToDate:(id)sender;
- (IBAction)dateSelected:(id)sender;
- (IBAction)addTransaction:(id)sender;
- (IBAction)editTransaction:(id)sender;
- (IBAction)deleteTransaction:(id)sender;
- (IBAction)dublicateTransaction:(id)sender;

@end
