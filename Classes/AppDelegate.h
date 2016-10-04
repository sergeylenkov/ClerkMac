#import <Cocoa/Cocoa.h>
#import "MenuController.h"
#import "PrefsController.h"
#import "LockController.h"
#import "Accounts.h"
#import "Scheduler.h"
#import "Transaction.h"

@interface AppDelegate : NSObject {
	IBOutlet NSWindow *mainWindow;
	IBOutlet MenuController *menuController;
	sqlite3 *database;
	Accounts *accounts;
	PrefsController *preferencesController;
	LockController *lockController;
	NSTimer *schedulerTimer;
}

@property (nonatomic, assign) sqlite3 *database;

- (void)createEditableCopyOfDatabaseIfNeeded;
- (void)initializeDatabase;

- (void)scheduler;

- (IBAction)preferences:(id)sender;
- (IBAction)visitWebSite:(id)sender;

- (void)update;

@end
