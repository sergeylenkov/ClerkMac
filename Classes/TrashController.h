#import <Cocoa/Cocoa.h>
#import <sqlite3.h>
#import "TrashTransactionsController.h"

@interface TrashController : NSViewController {	
	IBOutlet TrashTransactionsController *transactionsController;
	NSWindow *mainWindow;
	sqlite3 *database;
	NSMutableArray *transactions;
	NSInteger period;
	NSButton *infoButton;
	NSNumberFormatter *formatter;
	NSString *filter;
}

@property (nonatomic, retain) NSWindow *mainWindow;
@property (nonatomic, assign) sqlite3 *database;
@property (nonatomic, retain) NSButton *infoButton;
@property (nonatomic, copy) NSString *filter;
@property (nonatomic, retain) NSMutableArray *transactions;

- (void)initialization;
- (void)refresh;
- (IBAction)restoreTransaction:(id)sender;
- (IBAction)deleteTransaction:(id)sender;

@end
