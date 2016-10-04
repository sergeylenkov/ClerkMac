#import <Cocoa/Cocoa.h>
#import "Yuba.h"
#import "MGScopeBar.h"
#import "NSDate+Format.h"
#import "Rate.h"
#import "RatesController.h"
#import "EditRateController.h"

@interface ExchangeController : NSViewController <MGScopeBarDelegate> {
	IBOutlet MGScopeBar *scopeBar;
	IBOutlet NSView *dateFilterView;
	IBOutlet NSDatePicker *fromDate;
	IBOutlet NSDatePicker *toDate;
	IBOutlet RatesController *ratesController;
	IBOutlet YBGraphView *graphView;
	IBOutlet NSButton *showGraphButton;
	NSWindow *mainWindow;
	sqlite3 *database;
	NSMutableArray *series;
	NSMutableArray *values;
	NSMutableArray *rates;
	NSMutableArray *currencies;
	NSInteger period;
	NSButton *infoButton;	
	EditRateController *editRateController;
	NSNumberFormatter *formatter;
	NSString *filter;
	NSInteger selectedFromItem;
	NSInteger selectedToItem;
	NSString *selectedPeriod;
	BOOL graphVisible;
	NSUserDefaults *defaults;
}

@property (nonatomic, retain) NSWindow *mainWindow;
@property (nonatomic, assign) sqlite3 *database;
@property (nonatomic, retain) NSButton *infoButton;
@property (nonatomic, copy) NSString *filter;
@property (nonatomic, retain) NSMutableArray *currencies;

- (void)initialization;
- (void)refresh;
- (IBAction)addRate:(id)sender;
- (IBAction)editRate:(id)sender;
- (IBAction)deleteRate:(id)sender;
- (IBAction)dublicateRate:(id)sender;
- (IBAction)showGraph:(id)sender;

@end
