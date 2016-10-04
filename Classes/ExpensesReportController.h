#import <Cocoa/Cocoa.h>
#import "Yuba.h"
#import "NSDate+Format.h"
#import "Accounts.h"
#import "Account.h"
#import "Transaction.h"
#import "Currency.h"

@interface ExpensesReportController : NSViewController {
	IBOutlet YBGraphView *expensesGraphView;
	IBOutlet YBChartView *expensesChartView;	
	IBOutlet NSView *contentView;
	IBOutlet NSView *graphView;
	IBOutlet NSView *chartView;
	IBOutlet NSSegmentedControl *changeViewButton;
	IBOutlet NSDatePicker *fromDate;
	IBOutlet NSDatePicker *toDate;
	IBOutlet NSTextField *byLabel;
	IBOutlet NSPopUpButton *byButton;
	IBOutlet NSTextField *accountLabel;
	IBOutlet NSPopUpButton *accountsButton;
	NSMutableArray *graphValues;
	NSMutableArray *graphSeries;
	NSMutableArray *chartValues;
	NSMutableArray *chartSeries;
	Accounts *accounts;
	sqlite3 *database;
	NSNumberFormatter *formatter;
	NSUserDefaults *defaults;
}

@property (nonatomic, retain) Accounts *accounts;
@property (nonatomic, assign) sqlite3 *database;

- (void)initialization;
- (void)refresh;
- (IBAction)changeDate:(id)sender;
- (IBAction)changeBy:(id)sender;
- (IBAction)changeAccount:(id)sender;
- (IBAction)viewChanged:(id)sender;
- (void)showGraphButton;
- (void)hideGraphButton;

@end
