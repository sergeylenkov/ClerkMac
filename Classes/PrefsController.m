#import "PrefsController.h"

#define TOOLBAR_GENERAL @"TOOLBAR_GENERAL"
#define TOOLBAR_CURRENCIES @"TOOLBAR_CURRENCIES"
#define TOOLBAR_UPDATE @"TOOLBAR_UPDATE"

@implementation PrefsController

@synthesize database;

- (id)init {
    if ((self = [super initWithWindowNibName: @"PrefsWindow"])) {
        defaults = [NSUserDefaults standardUserDefaults];
		
		if ([defaults objectForKey:@"Require Password"] == nil) {
			[defaults setBool:NO forKey:@"Require Password"];
		}
		
		if ([defaults objectForKey:@"Base Currency"] == nil) {
			[defaults setInteger:1 forKey:@"Base Currency"];
		}		
    }
    
    return self;
}

- (void)awakeFromNib {    
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier: @"Preferences Toolbar"];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:NO];
    [toolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel];
    [toolbar setSizeMode: NSToolbarSizeModeRegular];
    [toolbar setSelectedItemIdentifier:TOOLBAR_GENERAL];
    [[self window] setToolbar:toolbar];
    [toolbar release];

	[[self window] center];
		
	[requirePasswordButton setState:[[defaults objectForKey:@"Require Password"] intValue]];
	
	currenciesController.database = database;
	[currenciesController initialization];	
	
	[self setPrefView:nil];
}

- (void)refresh {	
	[currenciesController refresh];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)ident willBeInsertedIntoToolbar:(BOOL)flag {
    NSToolbarItem * item = [[NSToolbarItem alloc] initWithItemIdentifier: ident];

    if ([ident isEqualToString:TOOLBAR_GENERAL]) {
        [item setLabel:@"General"];
        [item setImage:[NSImage imageNamed:@"NSPreferencesGeneral"]];
        [item setTarget:self];
        [item setAction:@selector(setPrefView:)];
        [item setAutovalidates:NO];
	} else if ([ident isEqualToString:TOOLBAR_CURRENCIES]) {
		[item setLabel:@"Currencies"];
        [item setImage:[NSImage imageNamed:@"Dollar"]];
        [item setTarget:self];
        [item setAction:@selector(setPrefView:)];
        [item setAutovalidates:NO];
    } else if ([ident isEqualToString:TOOLBAR_UPDATE]) {
        [item setLabel:@"Update"];
        [item setImage:[NSImage imageNamed:@"PreferenceUpdate"]];
        [item setTarget:self];
        [item setAction:@selector(setPrefView:)];
        [item setAutovalidates:NO];
    } else {
        [item release];
        return nil;
    }

    return [item autorelease];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
    return [self toolbarDefaultItemIdentifiers:toolbar];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return [self toolbarAllowedItemIdentifiers:toolbar];
}

- (NSArray *)toolbarAllowedItemIdentifiers: (NSToolbar *)toolbar {
    return [NSArray arrayWithObjects:TOOLBAR_GENERAL, TOOLBAR_CURRENCIES, TOOLBAR_UPDATE, nil];
}

- (void)setPrefView:(id)sender {
    NSString *identifier;
	
    if (sender) {
        identifier = [sender itemIdentifier];
        [[NSUserDefaults standardUserDefaults] setObject:identifier forKey:@"SelectedPrefView"];
    } else {
        identifier = [[NSUserDefaults standardUserDefaults] stringForKey:@"SelectedPrefView"];
    }
	
    NSView *view;
	
    if ([identifier isEqualToString:TOOLBAR_UPDATE]) {
		 view = updateView;
	} else if ([identifier isEqualToString:TOOLBAR_CURRENCIES]) {
		view = currenciesView;
	} else {
        identifier = TOOLBAR_GENERAL;
        view = generalView;
    }
    
    [[[self window] toolbar] setSelectedItemIdentifier:identifier];
    
    NSWindow *window = [self window];
	
    if ([window contentView] == view) {
        return;
    }

    NSRect windowRect = [window frame];
    float difference = ([view frame].size.height - [[window contentView] frame].size.height) * [window userSpaceScaleFactor];
    windowRect.origin.y -= difference;
    windowRect.size.height += difference;
   
	difference = ([view frame].size.width - [[window contentView] frame].size.width) * [window userSpaceScaleFactor];
    windowRect.size.width += difference;
	
    [view setHidden:YES];
    [window setContentView:view];
    [window setFrame:windowRect display:YES animate:YES];
    [view setHidden:NO];
    
    if (sender) {
        [window setTitle:[sender label]];
    } else {
        NSToolbar *toolbar = [window toolbar];
        NSString *itemIdentifier = [toolbar selectedItemIdentifier];
        NSEnumerator *enumerator = [[toolbar items] objectEnumerator];
        NSToolbarItem *item;
		
        while ((item = [enumerator nextObject])) {
            if ([[item itemIdentifier] isEqualToString:itemIdentifier]) {
                [window setTitle:[item label]];
                break;
            }
		}
    }
}

- (IBAction)setRequirePassword:(id)sender {
	[defaults setBool:[requirePasswordButton state] forKey:@"Require Password"];
}

- (IBAction)changePassword:(id)sender {
	[passwordController showOnWindow:[self window]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
    [super dealloc];
}

@end
