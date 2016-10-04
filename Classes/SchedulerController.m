#import "SchedulerController.h"

@implementation SchedulerController

@synthesize mainWindow;
@synthesize database;
@synthesize accounts;
@synthesize infoButton;
@synthesize filter;

- (void)awakeFromNib {	
	editSchedulerController = [[EditSchedulerController alloc] initWithWindowNibName:@"EditSchedulerView"];	
	
	[schedulersController.view setTarget:self]; 
	[schedulersController.view setDoubleAction:@selector(editScheduler:)];
	
	schedulers = [[NSMutableArray alloc] init];	
	formatter = [[NSNumberFormatter alloc] init];
	
	[formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[formatter setPositiveFormat:[NSString stringWithFormat:@"#,##0.00"]];
	
	filter = @"";
}

- (void)initialization {
	//
}

- (void)refresh {
	[schedulers removeAllObjects];
	
	NSString *sql = @"SELECT id FROM schedulers WHERE enable = 1";	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Scheduler *scheduler = [[[Scheduler alloc] initWithPrimaryKey:sqlite3_column_int(statement, 0) database:database] autorelease];
			[schedulers addObject:scheduler];
		}
	}
	
	sqlite3_finalize(statement);
	
	[infoButton setTitle:[NSString localizedStringWithFormat:@"%d tasks", [schedulers count]]];
	
	schedulersController.schedulers = schedulers;
	[schedulersController refresh];
}

- (IBAction)addScheduler:(id)sender {
	Scheduler *scheduler = [[[Scheduler alloc] initWithPrimaryKey:-1 database:database] autorelease];
	
	editSchedulerController.scheduler = scheduler;
	editSchedulerController.accounts = accounts;
	
	[editSchedulerController showOnWindow:mainWindow];
	
	[self refresh];
}

- (IBAction)editScheduler:(id)sender {
	Scheduler *scheduler = [schedulers objectAtIndex:[schedulersController.view selectedRow]];
	
	editSchedulerController.scheduler = scheduler;
	editSchedulerController.accounts = accounts;
	
	[editSchedulerController showOnWindow:mainWindow];
	
	[self refresh];
}

- (IBAction)deleteScheduler:(id)sender {
	Scheduler *scheduler = [schedulers objectAtIndex:[schedulersController.view selectedRow]];
	[scheduler delete];
	
	[self refresh];
}

- (void)dealloc {
	[schedulers release];
	[formatter release];
	[infoButton release];
	[super dealloc];
}

@end
