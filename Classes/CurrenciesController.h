#import <Cocoa/Cocoa.h>
#import <sqlite3.h>
#import "Currency.h"

@interface CurrenciesController : NSObject {
	IBOutlet NSTableView *view;
	IBOutlet NSButton *deleteButton;
	IBOutlet NSPopUpButton *currenciesButton;
	NSMutableArray *currencies;
	sqlite3 *database;
	NSUserDefaults *defaults;
}

@property (nonatomic, assign) sqlite3 *database;

- (void)initialization;
- (void)refresh;
- (void)refreshBaseCurrencyButton;

- (IBAction)addCurrency:(id)sender;
- (IBAction)removeCurrency:(id)sender;
- (IBAction)changeBaseCurrency:(id)sender;

@end
