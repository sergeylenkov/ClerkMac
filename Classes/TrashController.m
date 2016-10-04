#import "TrashController.h"

@implementation TrashController

@synthesize mainWindow;
@synthesize database;
@synthesize infoButton;
@synthesize filter;
@synthesize transactions;

- (id)initWithNibName:(NSString *)nib bundle:(NSBundle *)bundle {
	if (self = [super initWithNibName:nib bundle:bundle]) {
		transactions = [[NSMutableArray alloc] init];
		
		formatter = [[NSNumberFormatter alloc] init];
		
		[formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[formatter setPositiveFormat:[NSString stringWithFormat:@"#,##0.00"]];
		
		self.filter = @"";
	}
				
	return self;
}


- (void)initialization {
	//
}

- (void)refresh {
	[transactions removeAllObjects];
	
	NSString *sql = @"SELECT id FROM transactions WHERE enable = 0";	
	sqlite3_stmt *statement;
		
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Transaction *transaction = [[[Transaction alloc] initWithPrimaryKey:sqlite3_column_int(statement, 0) database:database] autorelease];
			
			if ([filter isEqualToString:@""]) { 
				[transactions addObject:transaction];
			} else {				
				NSRange nameRange = [[transaction.name lowercaseString] rangeOfString:[filter lowercaseString]];
				NSRange fromRange = [[transaction.fromAccount.name lowercaseString] rangeOfString:[filter lowercaseString]];
				NSRange toRange = [[transaction.toAccount.name lowercaseString] rangeOfString:[filter lowercaseString]];
				
				if (nameRange.location != NSNotFound || fromRange.location != NSNotFound || toRange.location != NSNotFound) {
					[transactions addObject:transaction];
				}				
			}
		}
	}
	
	sqlite3_finalize(statement);
	
	[infoButton setTitle:[NSString localizedStringWithFormat:@"%d transactions", [transactions count]]];
	
	transactionsController.transactions = transactions;
	[transactionsController refresh];
}

- (IBAction)restoreTransaction:(id)sender {	
	Transaction *transaction = [transactionsController selectedTransaction];
	
	if (transaction != nil) {
		transaction.enable = YES;
		[transaction save];
		
		[transactions removeObjectAtIndex:[transactionsController.view selectedRow]];
		
		[self refresh];		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshView" object:nil];
	}	
}

- (IBAction)deleteTransaction:(id)sender {
	Transaction *transaction = [transactionsController selectedTransaction];
	
	if (transaction != nil) {
		[transaction delete];
		
		[self refresh];		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshView" object:nil];
	}	
}

- (void)dealloc {
	[transactions release];	
	[formatter release];
	[infoButton release];
	[super dealloc];
}

@end
