#import <Cocoa/Cocoa.h>
#import <sqlite3.h>
#import "Scheduler.h"
#import "EditSchedulerController.h"
#import "SchedulersController.h"

@interface SchedulerController : NSViewController {
	IBOutlet SchedulersController *schedulersController;
	NSWindow *mainWindow;
	sqlite3 *database;
	Accounts *accounts;
	NSMutableArray *schedulers;
	NSInteger period;
	NSButton *infoButton;
	NSNumberFormatter *formatter;
	NSString *filter;
	EditSchedulerController *editSchedulerController;	
}

@property (nonatomic, retain) NSWindow *mainWindow;
@property (nonatomic, assign) sqlite3 *database;
@property (nonatomic, retain) Accounts *accounts;
@property (nonatomic, retain) NSButton *infoButton;
@property (nonatomic, copy) NSString *filter;

- (void)initialization;
- (void)refresh;
- (IBAction)addScheduler:(id)sender;
- (IBAction)editScheduler:(id)sender;
- (IBAction)deleteScheduler:(id)sender;

@end
