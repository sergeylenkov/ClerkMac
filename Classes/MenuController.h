#import <Cocoa/Cocoa.h>
#import "ImageAndTextCell.h"
#import "Group.h"
#import "Account.h"
#import "SmartAccount.h"
#import "Report.h"
#import "MenuItem.h"
#import "Accounts.h"
#import "AccountController.h"
#import "SmartAccountController.h"
#import "EmptyController.h"
#import "EditAccountController.h"
#import "ReceiptsReportController.h"
#import "ExpensesReportController.h"
#import "TrashController.h"
#import "SchedulerController.h"
#import "ExchangeController.h"

@interface MenuController : NSObject {
	IBOutlet NSOutlineView *view;	
	IBOutlet NSView *contentView;
	IBOutlet NSButton *infoButton;
	IBOutlet NSMenu *addMenu;
	IBOutlet NSMenu *optionsMenu;
	IBOutlet NSButton *addButton;
	IBOutlet NSButton *optionsButton;
	IBOutlet NSSearchField *searchField;	
	NSWindow *mainWindow;
	sqlite3 *database;	
	Accounts *accounts;
	NSMutableArray *currencies;
	AccountController *accountController;
	SmartAccountController *smartAccountController;
	EmptyController *emptyController;
	EditAccountController *editAccountController;
	ReceiptsReportController *receiptsReportController;
	ExpensesReportController *expensesReportController;
	TrashController *trashController;
	SchedulerController *schedulerController;
	ExchangeController *exchangeController;
	NSNumberFormatter *formatter;
	Account *draggingAccount;
	NSMutableArray *groups;
	NSMutableArray *reports;
	NSMutableArray *summaries;
	NSMutableArray *menuItems;
	BOOL showTotalBalance;
	NSUserDefaults *defaults;
	Account *lastAcccount;
	NSInteger lastIndex;
}

@property (nonatomic, retain) NSWindow *mainWindow;
@property (nonatomic, assign) sqlite3 *database;
@property (nonatomic, retain) Accounts *accounts;

- (void)initialization;
- (void)refresh;
- (void)refreshView;
- (void)summaryInfo;

- (IBAction)addReceipt:(id)sender;
- (IBAction)addDeposit:(id)sender;
- (IBAction)addExpense:(id)sender;
- (IBAction)addDebt:(id)sender;

- (IBAction)deleteAccount:(id)sender;
- (IBAction)editAccount:(id)sender;
- (IBAction)archiveAccount:(id)sender;

- (IBAction)showActions:(id)sender;
- (IBAction)search:(id)sender;

- (IBAction)addItem:(id)sender;
- (IBAction)dublicateItem:(id)sender;
- (IBAction)deleteItem:(id)sender;

- (IBAction)changeBalanceView:(id)sender;

@end
