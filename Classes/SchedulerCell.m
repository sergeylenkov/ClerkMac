#import "SchedulerCell.h"

@implementation SchedulerCell

@synthesize name;
@synthesize description;
@synthesize nextRunAt;
@synthesize fromAccountName;
@synthesize fromAccountIcon;
@synthesize toAccountName;
@synthesize toAccountIcon;

- (id)init {
	if (self = [super init]) {
		self.name = @"";
		self.description = @"";
		self.nextRunAt = @"";
		self.fromAccountName = @"";
		self.toAccountName = @"";		
	}
	
	return self;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paragraphStyle setAlignment:NSLeftTextAlignment];
	
	NSFont *font = [NSFont boldSystemFontOfSize:11];
	
	NSColor *color = [NSColor colorWithDeviceRed:40.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1.0];
	
	if ([self isHighlighted]) {
		color = [NSColor colorWithDeviceRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
	}
	
	NSDictionary *attsDict = [NSDictionary dictionaryWithObjectsAndKeys:color, NSForegroundColorAttributeName, font, NSFontAttributeName, [NSNumber numberWithInt:NSNoUnderlineStyle], NSUnderlineStyleAttributeName, paragraphStyle, NSParagraphStyleAttributeName, nil];
	
	[name drawInRect:NSMakeRect(cellFrame.origin.x + 42, cellFrame.origin.y + 6, cellFrame.size.width - 20, 16) withAttributes:attsDict];
	
	paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];	
	[paragraphStyle setAlignment:NSLeftTextAlignment];
	
	font = [NSFont systemFontOfSize:11];
	
	color = [NSColor colorWithDeviceRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1.0];
	
	if ([self isHighlighted]) {
		color = [NSColor colorWithDeviceRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
	}
	
	attsDict = [NSDictionary dictionaryWithObjectsAndKeys:color, NSForegroundColorAttributeName, font, NSFontAttributeName, [NSNumber numberWithInt:NSNoUnderlineStyle], NSUnderlineStyleAttributeName, paragraphStyle, NSParagraphStyleAttributeName, nil];
	
	[description drawInRect:NSMakeRect(cellFrame.origin.x + 42, cellFrame.origin.y + 26, cellFrame.size.width - 20, 16) withAttributes:attsDict];
	
	[[NSImage imageNamed:@"Calendar.png"] compositeToPoint:NSMakePoint(cellFrame.origin.x + 12, cellFrame.origin.y + 22) operation:NSCompositeSourceOver];
}

- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView {
	return NSCellHitContentArea;
}

- (void)dealloc {
    [name release];
	[fromAccountName release];
	[toAccountName release];
	[description release];
	[nextRunAt release];
    [super dealloc];
}

@end

