#import <Cocoa/Cocoa.h>
#import "NSDate+Format.h"
#import "ImageAndTextCell.h"
#import "SchedulerCell.h"
#import "Scheduler.h"
#import "CenterCell.h"

@interface SchedulersController : NSObject {
	IBOutlet NSTableView *view;
	IBOutlet NSButton *editSchedulerButton;
	IBOutlet NSButton *deleteSchedulerButton;
	NSMutableArray *days;
	NSMutableArray *months;
	NSMutableArray *schedulers;
	NSNumberFormatter *formatter;
	NSDateFormatter *dateFormatter;
	NSString *lastIdentifier;
	BOOL sortAscending;
	NSUserDefaults *defaults;
}

@property (nonatomic, retain) NSTableView *view;
@property (nonatomic, retain) NSMutableArray *schedulers;

- (void)refresh;
- (void)tableViewSelectionDidChange:(NSNotification *)notification;

- (void)sortTableView:(NSTableView *)tableView byIdentifier:(NSString *)identifier ascending:(BOOL)order;
- (void)reverse;

@end
