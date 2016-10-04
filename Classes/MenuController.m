#import "MenuController.h"

@implementation MenuController

@synthesize mainWindow;
@synthesize database;
@synthesize accounts;

- (void)awakeFromNib {
	defaults = [NSUserDefaults standardUserDefaults];
	
	NSTableColumn *tableColumn = [view tableColumnWithIdentifier:@"menu"];
	ImageAndTextCell *imageAndTextCell = [[[ImageAndTextCell alloc] init] autorelease];
	[imageAndTextCell setEditable:YES];
	[tableColumn setDataCell:imageAndTextCell];
	
	[addButton sendActionOn:NSLeftMouseDownMask];
	[optionsButton sendActionOn:NSLeftMouseDownMask];
	
	accountController = [[AccountController alloc] initWithNibName:@"AccountView" bundle:nil];
	smartAccountController = [[SmartAccountController alloc] initWithNibName:@"SmartAccountView" bundle:nil];
	receiptsReportController = [[ReceiptsReportController alloc] initWithNibName:@"ReceiptsReportView" bundle:nil];
	expensesReportController = [[ExpensesReportController alloc] initWithNibName:@"ExpensesReportView" bundle:nil];
	emptyController = [[EmptyController alloc] initWithNibName:@"EmptyView" bundle:nil];
	trashController = [[TrashController alloc] initWithNibName:@"TrashView" bundle:nil];
	schedulerController = [[SchedulerController alloc] initWithNibName:@"SchedulerView" bundle:nil];
	exchangeController = [[ExchangeController alloc] initWithNibName:@"ExchangeView" bundle:nil];
	editAccountController = [[EditAccountController alloc] initWithWindowNibName:@"EditAccountView"];
	
	currencies = [[NSMutableArray alloc] init];	
	groups = [[NSMutableArray alloc] init];
	summaries = [[NSMutableArray alloc] init];
	
	Group *group = [[Group alloc] autorelease];
	group.name = @"RECEIPTS";
	[groups addObject:[group retain]];
	
	group = [[Group alloc] autorelease];
	group.name = @"DEPOSITS";
	[groups addObject:[group retain]];
	
	group = [[Group alloc] autorelease];
	group.name = @"EXPENSES";
	[groups addObject:[group retain]];
	
	group = [[Group alloc] autorelease];
	group.name = @"DEBTS";
	[groups addObject:[group retain]];
	
	group = [[Group alloc] autorelease];
	group.name = @"ARCHIVE";
	[groups addObject:[group retain]];
	
	group = [[Group alloc] autorelease];
	group.name = @"SUMMARY";
	[groups addObject:[group retain]];
	
	group = [[Group alloc] autorelease];
	group.name = @"REPORTS";
	[groups addObject:[group retain]];

	group = [[Group alloc] autorelease];
	group.name = @"SYSTEM";
	[groups addObject:[group retain]];	
	
	reports = [[NSMutableArray alloc] init];
	
	Report *report = [[Report alloc] autorelease];
	report.name = @"Receipts";
	[reports addObject:[report retain]];
	
	report = [[Report alloc] autorelease];
	report.name = @"Expenses";
	[reports addObject:[report retain]];
		
	menuItems = [[NSMutableArray alloc] init];
	
	MenuItem *item = [[MenuItem alloc] autorelease];
	item.name = @"Exchange Rates";
	[menuItems addObject:[item retain]];
	
	item = [[MenuItem alloc] autorelease];
	item.name = @"Scheduler";
	[menuItems addObject:[item retain]];
	
	item = [[MenuItem alloc] autorelease];
	item.name = @"Trash";
	[menuItems addObject:[item retain]];
	
	formatter = [[NSNumberFormatter alloc] init];
	
	[formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[formatter setPositiveFormat:[NSString stringWithFormat:@"#,##0.00"]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:@"RefreshView" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addReceipt:) name:@"AddReceipt" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDeposit:) name:@"AddDeposit" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addExpense:) name:@"AddExpense" object:nil];
}

- (void)initialization {
	accountController.mainWindow = mainWindow;
	accountController.infoButton = infoButton;
	accountController.database = database;	
	accountController.accounts = accounts;
	
	smartAccountController.mainWindow = mainWindow;
	smartAccountController.infoButton = infoButton;
	smartAccountController.database = database;	
	smartAccountController.accounts = accounts;
	
	receiptsReportController.accounts = accounts;
	receiptsReportController.database = database;
	
	expensesReportController.accounts = accounts;
	expensesReportController.database = database;
	
	exchangeController.mainWindow = mainWindow;
	exchangeController.infoButton = infoButton;
	exchangeController.database = database;
	exchangeController.currencies = currencies;
	
	schedulerController.mainWindow = mainWindow;
	schedulerController.infoButton = infoButton;
	schedulerController.database = database;	
	schedulerController.accounts = accounts;
	
	trashController.infoButton = infoButton;
	trashController.database = database;
	
	[currencies removeAllObjects];
	
	NSString *sql = @"SELECT id FROM currencies WHERE enabled = 1 ORDER BY short_name";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Currency *currency = [[[Currency alloc] initWithPrimaryKey:sqlite3_column_int(statement, 0) database:database] autorelease];
			[currencies addObject:[currency retain]];
		}
	}
	
	sqlite3_finalize(statement);
	
	[summaries removeAllObjects];
	
	SmartAccount *account = [[[SmartAccount alloc] initWithPrimaryKey:-1 database:database] autorelease];
	
	account.name = @"Receipts";
	account.type = 0;
	
	[summaries addObject:account];
	
	account = [[[SmartAccount alloc] initWithPrimaryKey:-1 database:database] autorelease];
	
	account.name = @"Expenses";
	account.type = 2;
	
	[summaries addObject:account];
}

- (void)refresh {
	[accounts reload];

	[receiptsReportController initialization];
	[expensesReportController initialization];	

	[schedulerController initialization];
	[schedulerController refresh];

	[trashController initialization];
	[trashController refresh];

	[self refreshView];
}

- (void)refreshView {
	[view reloadData];
	
	for (int i = 0; i < [view numberOfRows]; i++ ) {		
		if ([[view itemAtRow:i] isKindOfClass:[Group class]]) {
			id item = [view itemAtRow:i];
			NSNumber *expand = [defaults objectForKey:[NSString stringWithFormat:@"%@ Expand", [item name]]];
			
			if (expand != nil && [expand boolValue]) {
				[view expandItem:item];
			}
		}
	}
	
	int index = -1;
	
	if ([defaults objectForKey:@"Selected Menu Item"] != nil) {		
		index = [[defaults objectForKey:@"Selected Menu Item"] intValue];
	}

	if (index != -1) {
		[view selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
	} else {	
		[self outlineViewSelectionDidChange:[NSNotification notificationWithName:@"NSObject" object:view]];
	}
}

- (void)summaryInfo {		
	NSString *balance = @"";
	
	for (int i = 0; i < [currencies count]; i++) {
		float amount = 0;
		Currency *currency = [currencies objectAtIndex:i];
		
		for (int j = 0; j < [accounts.deposits count]; j++) {
			Account *account = [accounts.deposits objectAtIndex:j];
			if (account.currency.primaryKey == currency.primaryKey) {
				amount = amount + [[account balance] floatValue];
			}
		}
		
		if (amount > 0) {
			balance = [balance stringByAppendingString:[NSString stringWithFormat:@", %@ %@", [formatter stringFromNumber:[NSNumber numberWithFloat:amount]],  currency.shortName]];
		}
	}
	
	[infoButton setTitle:[NSString localizedStringWithFormat:@"%d deposits%@", [accounts.deposits count], balance]];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	int selectedRow = [view selectedRow];
	
	if (selectedRow != -1 && returnCode == 1) {
		if ([[view itemAtRow:selectedRow] isKindOfClass:[Account class]]) {
			Account *account = [view itemAtRow:selectedRow];		
						
			[defaults setInteger:selectedRow - 1 forKey:@"Selected Menu Item"];
			
			if ([[view itemAtRow:selectedRow - 1] isKindOfClass:[Group class]]) {
				[defaults setInteger:selectedRow forKey:@"Selected Menu Item"];				
			}
			
			if ((account.type == 0 && [accounts.receipts count] == 1) || (account.type == 1 && [accounts.deposits count] == 1) ||
				(account.type == 2 && [accounts.expenses count] == 1) || (account.type == 3 && [accounts.debts count] == 1)) {
				for (int i = 0; i < [view numberOfRows]; i++) {		
					if ([[view itemAtRow:i] isKindOfClass:[Account class]]) {
						Account *temp = (Account *)[view itemAtRow:i];

						if (temp != account) {
							if (account.type == 1) {
								[defaults setInteger:i forKey:@"Selected Menu Item"];
							} else {
								[defaults setInteger:i - 1 forKey:@"Selected Menu Item"];
							}
							
							break;
						}						
					}
				}
			}
			
			[account delete];
			[self refresh];			
		}
	}
}

#pragma mark -
#pragma mark outlineview protocol
#pragma mark -

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (!item) {
        return 8;
    }

	if ([item isKindOfClass:[Group class]]) {
		if ([[item name] isEqualToString:@"RECEIPTS"]) {
			return [accounts.receipts count];
		}
		
		if ([[item name] isEqualToString:@"DEPOSITS"]) {
			return [accounts.deposits count];
		}
		
		if ([[item name] isEqualToString:@"EXPENSES"]) {
			return [accounts.expenses count];
		}
		
		if ([[item name] isEqualToString:@"DEBTS"]) {
			return [accounts.debts count];
		}
		
		if ([[item name] isEqualToString:@"ARCHIVE"]) {
			return [accounts.archive count];
		}
		
		if ([[item name] isEqualToString:@"SUMMARY"]) {
			return [summaries count];
		}
		
		if ([[item name] isEqualToString:@"REPORTS"]) {
			return 2;
		}
		
		if ([[item name] isEqualToString:@"SYSTEM"]) {
			return 3;
		}
	}
	
	return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
    if (!item) {
		return [groups objectAtIndex:index];
	} else {
		if ([item isKindOfClass:[Group class]]) {			
			if ([[item name] isEqualToString:@"RECEIPTS"]) {
				return [accounts.receipts objectAtIndex:index];
			}
			
			if ([[item name] isEqualToString:@"DEPOSITS"]) {
				return [accounts.deposits objectAtIndex:index];
			}
			
			if ([[item name] isEqualToString:@"EXPENSES"]) {
				return [accounts.expenses objectAtIndex:index];
			}
			
			if ([[item name] isEqualToString:@"DEBTS"]) {
				return [accounts.debts objectAtIndex:index];
			}
			
			if ([[item name] isEqualToString:@"ARCHIVE"]) {
				return [accounts.archive objectAtIndex:index];
			}
			
			if ([[item name] isEqualToString:@"SUMMARY"]) {
				return [summaries objectAtIndex:index];
			}
			
			if ([[item name] isEqualToString:@"REPORTS"]) {
				return [reports objectAtIndex:index];
			}
			
			if ([[item name] isEqualToString:@"SYSTEM"]) {
				return [menuItems objectAtIndex:index];				
			}
		}
	}
	
	return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {	
	if ([item isKindOfClass:[Group class]]) {
		return YES;
	}
	
	return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	if (item != nil) {
		return [item name];
	}
    
    return nil;
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	if ([item isKindOfClass:[Group class]]) {		
		[cell setImage:[NSImage imageNamed:@""]];
	}
	
	if ([item isKindOfClass:[Account class]]) {
		Account *account = (Account *)item;
		[cell setTitle:account.name];
		
		if (account.enable) {			
			[cell setImage:account.icon];
		} else {
			[cell setImage:[NSImage imageNamed:@"Archive.png"]];
		}		
	}
		
	if ([item isKindOfClass:[Report class]]) {
		Report *report = (Report *)item;

		[cell setTitle:report.name];
		[cell setImage:[NSImage imageNamed:@"Report.png"]];
	}
		
	if ([item isKindOfClass:[SmartAccount class]]) {
		[cell setImage:[NSImage imageNamed:@"SmartAccount.png"]];
	}
	
	if ([item isKindOfClass:[MenuItem class]]) {
		MenuItem *menuItem = (MenuItem *)item;
		
		if ([menuItem.name isEqualToString:@"Exchange Rates"]) {
			[cell setImage:[NSImage imageNamed:@"Exchange.png"]];
		}
		
		if ([menuItem.name isEqualToString:@"Scheduler"]) {
			[cell setImage:[NSImage imageNamed:@"Calendar.png"]];
		}
		
		if ([menuItem.name isEqualToString:@"Trash"]) {
			if ([trashController.transactions count] > 0) {
				[cell setImage:[NSImage imageNamed:@"TrashFull.png"]];
			} else {
				[cell setImage:[NSImage imageNamed:@"TrashEmpty.png"]];
			}			
		}
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	if ([item isKindOfClass:[Account class]] || [item isKindOfClass:[SmartAccount class]]) {
		return YES;
	}
	
	return NO;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	if ([item isKindOfClass:[Account class]]) {		
		Account *account = (Account *)item;
		NSString *name = object;
		account.name = [name copy];
		[account save];
	}

	if ([item isKindOfClass:[SmartAccount class]]) {		
		SmartAccount *account = (SmartAccount *)item;
		NSString *name = object;
		account.name = [name copy];
		[account save];
	}
}

- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	NSCell *returnCell = [tableColumn dataCell];	
	return returnCell;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
	if ([item isKindOfClass:[Group class]]) {
		return NO;
	}
	
	return YES;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
	if ([item isKindOfClass:[Group class]]) {
		return YES;
	}
	
	return NO;
}

- (void)outlineViewItemWillExpand:(NSNotification *)notification {
	id item = [[notification userInfo] objectForKey:@"NSObject"];
	
	if ([item isKindOfClass:[Group class]]) {
		[defaults setBool:YES forKey:[NSString stringWithFormat:@"%@ Expand", [item name]]];
	}
}

- (void)outlineViewItemWillCollapse:(NSNotification *)notification {
	id item = [[notification userInfo] objectForKey:@"NSObject"];
	
	if ([item isKindOfClass:[Group class]]) {		
		[defaults setBool:NO forKey:[NSString stringWithFormat:@"%@ Expand", [item name]]];
	}
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	[accountController.view removeFromSuperview];
	[smartAccountController.view removeFromSuperview];	
	[receiptsReportController.view removeFromSuperview];
	[expensesReportController.view removeFromSuperview];
	[exchangeController.view removeFromSuperview];
	[trashController.view removeFromSuperview];
	[schedulerController.view removeFromSuperview];
	[emptyController.view removeFromSuperview];
	
	if ([accounts.receipts count] == 0 || [accounts.expenses count] == 0 || [accounts.deposits count] == 0) {
		if ([accounts.receipts count] == 0) {
			emptyController.type = 0;
			[emptyController setText:@"      Add Receipt…"];
		} else if ([accounts.deposits count] == 0) {
			emptyController.type = 1;
			[emptyController setText:@"      Add Deposit…"];
		} else if ([accounts.expenses count] == 0) {
			emptyController.type = 2;
			[emptyController setText:@"      Add Expense…"];
		}
		
		[emptyController.view setFrame:[contentView bounds]];
		[contentView addSubview:emptyController.view];
		
		return;
	}
		
	[infoButton setHidden:NO];
	
	int selectedRow = [[notification object] selectedRow];

	if (selectedRow != -1) {
		id item = [[notification object] itemAtRow:selectedRow];
		
		if ([item isKindOfClass:[Account class]]) {
			Account *account = (Account *)[[notification object] itemAtRow:selectedRow];

			accountController.account = account;
			accountController.filter = [searchField stringValue];
			
			[accountController initialization];
			[accountController refresh];
			
			[accountController.view setFrame:[contentView bounds]];
			[contentView addSubview:accountController.view];
			
			showTotalBalance = NO;
		} 

		if ([item isKindOfClass:[SmartAccount class]]) {
			SmartAccount *account = (SmartAccount *)[[notification object] itemAtRow:selectedRow];
			
			smartAccountController.account = account;
			smartAccountController.filter = [searchField stringValue];
			
			[smartAccountController initialization];
			[smartAccountController refresh];
			
			[smartAccountController.view setFrame:[contentView bounds]];
			[contentView addSubview:smartAccountController.view];
			
			showTotalBalance = NO;
		}
		
		if ([item isKindOfClass:[Report class]]) {
			if ([[item name] isEqualToString:@"Receipts"]) {
				[receiptsReportController initialization];
				[receiptsReportController refresh];
				
				[receiptsReportController.view setFrame:[contentView bounds]];
				[contentView addSubview:receiptsReportController.view];
			}
			
			if ([[item name] isEqualToString:@"Expenses"]) {
				[expensesReportController initialization];
				[expensesReportController refresh];
				
				[expensesReportController.view setFrame:[contentView bounds]];
				[contentView addSubview:expensesReportController.view];
			}
			
			[self summaryInfo];
		}
		
		if ([item isKindOfClass:[MenuItem class]]) {
			if ([[item name] isEqualToString:@"Exchange Rates"]) {
				[exchangeController initialization];
				[exchangeController refresh];
				
				[exchangeController.view setFrame:[contentView bounds]];
				[contentView addSubview:exchangeController.view];
			}
			
			if ([[item name] isEqualToString:@"Scheduler"]) {
				[schedulerController refresh];
				
				[schedulerController.view setFrame:[contentView bounds]];
				[contentView addSubview:schedulerController.view];
			}
			
			if ([[item name] isEqualToString:@"Trash"]) {
				trashController.filter = [searchField stringValue];
				[trashController refresh];
				
				[trashController.view setFrame:[contentView bounds]];
				[contentView addSubview:trashController.view];
			}			
		}
		
		
		[defaults setInteger:selectedRow forKey:@"Selected Menu Item"];
	} else {
		[emptyController setText:@""];
		[emptyController hideButton];
		
		[emptyController.view setFrame:[contentView bounds]];
		[contentView addSubview:emptyController.view];
		
		showTotalBalance = YES;
		[self summaryInfo];
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteBoard {
	[outlineView registerForDraggedTypes:[NSArray arrayWithObjects:@"ACCOUNT", nil]];
	[pasteBoard declareTypes:[NSArray arrayWithObjects:@"ACCOUNT", nil] owner:self];
	
	int selectedRow = [view selectedRow];
	
	if (selectedRow != -1) {
		id item = [view itemAtRow:selectedRow];
		
		if ([item isKindOfClass:[Account class]]) {
			draggingAccount = item;
			return YES;
		}
	}
	
	return NO;
}

- (unsigned int)outlineView:(NSOutlineView*)outView validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(int)index {
	if ([item isKindOfClass:[Group class]]) {
		Group *group = item;
		
		if ([group.name isEqualToString:@"RECEIPTS"] && draggingAccount.type == 0) {
			return NSDragOperationMove;
		}
		
		if ([group.name isEqualToString:@"DEPOSITS"] && draggingAccount.type == 1) {
			return NSDragOperationMove;
		}
		
		if ([group.name isEqualToString:@"EXPENSES"] && draggingAccount.type == 2) {
			return NSDragOperationMove;
		}
		
		if ([group.name isEqualToString:@"DEBTS"] && draggingAccount.type == 3) {
			return NSDragOperationMove;
		}
	}
	
    return NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView*)outView acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(int)index {
	NSMutableArray *items;
	
	if (draggingAccount.type == 0) {
		items = accounts.receipts;		
	}	
	
	if (draggingAccount.type == 1) {
		items = accounts.deposits;
	}	
	
	if (draggingAccount.type == 2) {
		items = accounts.expenses;
	}
	
	if (draggingAccount.type == 3) {
		items = accounts.debts;
	}	
	
	if (index < draggingAccount.orderIndex) {
		int j = index;
		
		for (int i = index; i < [items count]; i++) {
			Account *account = [items objectAtIndex:i];
			
			if (account.primaryKey != draggingAccount.primaryKey) {
				account.orderIndex = j + 1;				
				[account save];
				j = j + 1;
			}
		}
	}
	
	if (index > draggingAccount.orderIndex) {	
		for (int i = 0; i < index; i++) {
			Account *account = [items objectAtIndex:i];
			
			if (account.primaryKey != draggingAccount.primaryKey) {
				account.orderIndex = account.orderIndex - 1;
				[account save];
			}
		}
	}
	
	draggingAccount.orderIndex = index;
	[draggingAccount save];
	
	[accounts reload];
	[self refreshView];
	
	return YES;
}

#pragma mark -
#pragma mark actions
#pragma mark -

- (IBAction)addReceipt:(id)sender {
	Account *account = [[Account alloc] initWithPrimaryKey:-1 database:database];
	account.type = 0;
	
	editAccountController.account = account;
	editAccountController.currencies = currencies;
	
	[account release];
	
	[editAccountController showOnWindow:mainWindow];

	if (!editAccountController.isCanceled) {
		[defaults setInteger:[accounts.receipts count] + 1 forKey:@"Selected Menu Item"];
		[self refresh];
	}	
}

- (IBAction)addDeposit:(id)sender {
	Account *account = [[Account alloc] initWithPrimaryKey:-1 database:database];
	account.type = 1;
	
	editAccountController.account = account;
	editAccountController.currencies = currencies;

	[account release];
	
	[editAccountController showOnWindow:mainWindow];
	
	if (!editAccountController.isCanceled) {
		[defaults setInteger:[accounts.receipts count] + [accounts.deposits count] + 2 forKey:@"Selected Menu Item"];
		[self refresh];
	}
}

- (IBAction)addExpense:(id)sender {
	Account *account = [[Account alloc] initWithPrimaryKey:-1 database:database];
	account.type = 2;
	
	editAccountController.account = account;
	editAccountController.currencies = currencies;
	
	[account release];
	
	[editAccountController showOnWindow:mainWindow];
	
	if (!editAccountController.isCanceled) {
		[defaults setInteger:[accounts.receipts count] + [accounts.deposits count] + [accounts.expenses count] + 3 forKey:@"Selected Menu Item"];
		[self refresh];
	}
}

- (IBAction)addDebt:(id)sender {
	Account *account = [[Account alloc] initWithPrimaryKey:-1 database:database];	
	account.type = 3;
	
	editAccountController.account = account;
	editAccountController.currencies = currencies;
	
	[account release];
	
	[editAccountController showOnWindow:mainWindow];
	
	if (!editAccountController.isCanceled) {
		[defaults setInteger:[accounts.receipts count] + [accounts.deposits count] + [accounts.expenses count] + [accounts.debts count] + 4 forKey:@"Selected Menu Item"];
		[self refresh];
	}
}

- (IBAction)editAccount:(id)sender {
	int selectedRow = [view selectedRow];

	if (selectedRow != -1) {
		id item = [view itemAtRow:selectedRow];
		
		if ([item isKindOfClass:[Account class]]) {			
			editAccountController.account = (Account *)item;
			editAccountController.currencies = currencies;

			[editAccountController showOnWindow:mainWindow];

			[self refreshView];
		}
	}
}

- (IBAction)deleteAccount:(id)sender {
	int selectedRow = [view selectedRow];
	
	if (selectedRow != -1) {
		if ([[view itemAtRow:selectedRow] isKindOfClass:[Account class]]) {
			Account *account = [view itemAtRow:selectedRow];		

			NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Are you sure want to delete account \"%@\"?", account.name] defaultButton:@"Delete" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"All transactions for this accounts will be deleted too."];			
			[alert beginSheetModalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(alertDidEnd: returnCode: contextInfo:) contextInfo:nil];
		}
	}
}

- (IBAction)archiveAccount:(id)sender {
	int selectedRow = [view selectedRow];
	
	if (selectedRow != -1) {
		if ([[view itemAtRow:selectedRow] isKindOfClass:[Account class]]) {
			Account *account = [view itemAtRow:selectedRow];	
			account.enable = !account.enable;
			[account save];
			
			[self refresh];
		}
	}
}

- (IBAction)showActions:(id)sender {
	NSRect frame = [(NSButton *)sender frame];
	NSPoint menuOrigin;
	
	if (sender == addButton) {
		menuOrigin = [[(NSButton *)sender superview] convertPoint:NSMakePoint(frame.origin.x, frame.origin.y + frame.size.height + addMenu.size.height) toView:nil];	
	}
	
	if (sender == optionsButton) {
		menuOrigin = [[(NSButton *)sender superview] convertPoint:NSMakePoint(frame.origin.x, frame.origin.y + frame.size.height + optionsMenu.size.height) toView:nil];	
	}
	
    NSEvent *event = [NSEvent mouseEventWithType:NSLeftMouseDown location:menuOrigin modifierFlags:NSLeftMouseDownMask timestamp:0 windowNumber:[[(NSButton *)sender window] windowNumber] context:[[(NSButton *)sender window] graphicsContext] eventNumber:0 clickCount:1 pressure:1];
	
	if (sender == optionsButton) {
		int selectedRow = [view selectedRow];
		id item = [view itemAtRow:selectedRow];
	
		for (int i = 0; i < [optionsMenu numberOfItems]; i++) {
			NSMenuItem *menuItem = [optionsMenu itemAtIndex:i];
			[menuItem setEnabled:NO];
			
			if (i == 0) {
				if ([item isKindOfClass:[Account class]]) {
					[menuItem setEnabled:YES];
				} else {
					[menuItem setEnabled:NO];
				}				
			}
			
			if (i == 1) {
				[menuItem setTitleWithMnemonic:@"Archive"];
				[menuItem setEnabled:NO];
			
				if ([item isKindOfClass:[Account class]]) {
					Account *account = (Account *)item;					
					[menuItem setEnabled:YES];
					
					if (account.enable) {
						[menuItem setTitleWithMnemonic:@"Archive"];
					} else {
						[menuItem setTitleWithMnemonic:@"Unarchive"];
					}
				}
			}
			
			if (i == 3) {
				[menuItem setEnabled:NO];
			
				if ([item isKindOfClass:[Account class]]) {
					[menuItem setTitleWithMnemonic:@"Delete Account"];
					[menuItem setEnabled:YES];
				}
			}		
		}
		
		[NSMenu popUpContextMenu:optionsMenu withEvent:event forView:(NSButton *)sender withFont:[NSFont menuFontOfSize:13]];
	}
	
	if (sender == addButton) {
		[NSMenu popUpContextMenu:addMenu withEvent:event forView:(NSButton *)sender withFont:[NSFont menuFontOfSize:13]];
	}
}

- (IBAction)search:(id)sender {	
	int selectedRow = [view selectedRow];
	
	if (selectedRow != -1) {
		id item = [view itemAtRow:selectedRow];
		
		if ([item isKindOfClass:[Account class]]) {			
			accountController.filter = [searchField stringValue];
			[accountController refresh];
		}
		
		if ([item isKindOfClass:[SmartAccount class]]) {			
			smartAccountController.filter = [searchField stringValue];
			[smartAccountController refresh];
		}
		
		if ([item isKindOfClass:[MenuItem class]]) {
			if ([[item name] isEqualToString:@"Trash"]) {				
				trashController.filter = [searchField stringValue];
				[trashController refresh];
			}
		}
	}	
}

- (IBAction)addItem:(id)sender {	
	int selectedRow = [view selectedRow];
	
	if (selectedRow != -1) {
		id item = [view itemAtRow:selectedRow];
		
		if ([item isKindOfClass:[Account class]]) {			
			[accountController addTransaction:sender];
		}
		
		if ([item isKindOfClass:[SmartAccount class]]) {			
			[smartAccountController addTransaction:sender];
		}
	}	
}

- (IBAction)dublicateItem:(id)sender {	
	int selectedRow = [view selectedRow];
	
	if (selectedRow != -1) {
		id item = [view itemAtRow:selectedRow];
		
		if ([item isKindOfClass:[Account class]]) {			
			[accountController dublicateTransaction:sender];
		}
		
		if ([item isKindOfClass:[SmartAccount class]]) {			
			[smartAccountController dublicateTransaction:sender];
		}
		
		if ([item isKindOfClass:[MenuItem class]]) {
			if ([[item name] isEqualToString:@"Exchange Rates"]) {
				[exchangeController dublicateRate:sender];
			}
		}
	}	
}

- (IBAction)deleteItem:(id)sender {	
	int selectedRow = [view selectedRow];
	
	if (selectedRow != -1) {
		id item = [view itemAtRow:selectedRow];
		
		if ([item isKindOfClass:[Account class]]) {			
			[accountController deleteTransaction:sender];
		}
		
		if ([item isKindOfClass:[SmartAccount class]]) {			
			[smartAccountController deleteTransaction:sender];
		}
		
		if ([item isKindOfClass:[MenuItem class]]) {
			if ([[item name] isEqualToString:@"Exchange Rates"]) {
				[exchangeController deleteRate:sender];
			}
			
			if ([[item name] isEqualToString:@"Scheduler"]) {
				[schedulerController deleteScheduler:sender];
			}
			
			if ([[item name] isEqualToString:@"Trash"]) {
				[trashController deleteTransaction:sender];
			}
		}
	}
}

- (IBAction)changeBalanceView:(id)sender {
	showTotalBalance = !showTotalBalance;
	
	if (showTotalBalance) {
		[self summaryInfo];
	} else {
		[self outlineViewSelectionDidChange:[NSNotification notificationWithName:@"NSObject" object:view]];
	}
}

- (void)dealloc {
	[accounts release];
	[currencies release];
	[editAccountController release];
	[accountController release];
	[emptyController release];
	[trashController release];
	[schedulerController release];
	[receiptsReportController release];
	[expensesReportController release];
	[formatter release];
	[groups release];
	[reports release];
	[menuItems release];
	[super dealloc];
}

@end
