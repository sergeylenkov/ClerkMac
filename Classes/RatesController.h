#import <Cocoa/Cocoa.h>
#import "NSDate+Format.h"
#import "Rate.h"
#import "RateCell.h"
#import "CenterCell.h"

@interface RatesController : NSObject {
	IBOutlet NSTableView *view;
	IBOutlet NSButton *editRateButton;
	IBOutlet NSButton *deleteRateButton;
	NSMutableArray *rates;
	NSInteger period;
	NSNumberFormatter *formatter;
	NSDateFormatter *dateFormatter;
	NSString *lastIdentifier;
	BOOL sortAscending;
	NSUserDefaults *defaults;
}

@property (nonatomic, retain) NSTableView *view;
@property (nonatomic, retain) NSMutableArray *rates;

- (void)refresh;
- (void)tableViewSelectionDidChange:(NSNotification *)notification;

- (void)sortTableView:(NSTableView *)tableView byIdentifier:(NSString *)identifier ascending:(BOOL)order;
- (void)reverse;

- (Rate *)selectedRate;

@end
