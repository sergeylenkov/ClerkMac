#import <Cocoa/Cocoa.h>
#import "NSDate+Format.h"
#import "Transaction.h"
#import "TrashCell.h"
#import "CenterCell.h"

@interface TrashTransactionsController : NSObject {
	IBOutlet NSTableView *view;
	IBOutlet NSButton *restoreTransactionButton;
	IBOutlet NSButton *deleteTransactionButton;
	NSMutableArray *transactions;
	NSInteger period;
	NSNumberFormatter *formatter;
	NSDateFormatter *dateFormatter;
	NSString *lastIdentifier;
	BOOL sortAscending;
	NSUserDefaults *defaults;
}

@property (nonatomic, retain) NSTableView *view;
@property (nonatomic, retain) NSMutableArray *transactions;

- (void)refresh;
- (void)tableViewSelectionDidChange:(NSNotification *)notification;

- (void)sortTableView:(NSTableView *)tableView byIdentifier:(NSString *)identifier ascending:(BOOL)order;
- (void)reverse;

- (Transaction *)selectedTransaction;

@end
