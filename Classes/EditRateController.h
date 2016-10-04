#import <Cocoa/Cocoa.h>
#import "Currency.h"
#import "Rate.h"

@interface EditRateController : NSWindowController {
	IBOutlet NSTextField *titleLabel;
	IBOutlet NSPopUpButton *fromCurrencyButton;
	IBOutlet NSPopUpButton *toCurrencyButton;
	IBOutlet NSTextField *rateField;
	IBOutlet NSDatePicker *datePicker;
	Rate *rate;
	NSMutableArray *currencies;
	NSNumberFormatter *formatter;
	Currency *fromCurrency;
	Currency *toCurrency;
}

@property(nonatomic, retain) Rate *rate;
@property(nonatomic, retain) NSMutableArray *currencies;
@property(nonatomic, retain) Currency *fromCurrency;
@property(nonatomic, retain) Currency *toCurrency;

- (void)showOnWindow:(NSWindow *)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end