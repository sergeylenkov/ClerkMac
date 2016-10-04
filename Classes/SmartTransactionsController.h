#import <Cocoa/Cocoa.h>
#import "ImageAndTextCell.h"
#import "NSDate+Format.h"
#import "Transaction.h"
#import "SmartAccount.h"
#import "TransactionCell.h"
#import "CenterCell.h"
#import "TableTransaction.h"

@interface SmartTransactionsController : NSObject {
	IBOutlet NSTableView *view;
	IBOutlet NSButton *addTransactionButton;
	IBOutlet NSButton *editTransactionButton;
	IBOutlet NSButton *deleteTransactionButton;
	IBOutlet NSButton *dublicateTransactionButton;
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
