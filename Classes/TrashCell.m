//
//  TrashCell.m
//  Clerk
//
//  Created by Sergey Lenkov on 20.05.10.
//  Copyright 2010 Positive Team. All rights reserved.
//

#import "TrashCell.h"

@implementation TrashCell

@synthesize name;
@synthesize date;
@synthesize fromAccountName;
@synthesize fromAmount;
@synthesize fromAccountIcon;
@synthesize toAccountName;
@synthesize toAmount;
@synthesize toAccountIcon;

- (id)init {
	if (self = [super init]) {
		self.name = @"";
		self.date = @"";
		self.fromAccountName = @"";
		self.fromAmount = @"";
		self.toAccountName = @"";
		self.toAmount = @"";
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
		
	[fromAccountIcon compositeToPoint:NSMakePoint(cellFrame.origin.x + 12, cellFrame.origin.y + 22) operation:NSCompositeSourceOver];
	[fromAccountName drawInRect:NSMakeRect(cellFrame.origin.x + 42, cellFrame.origin.y + 6, cellFrame.size.width - 20, 16) withAttributes:attsDict];
		
	NSSize accountSize = [fromAccountName sizeWithAttributes:attsDict];
	
	int x = cellFrame.origin.x + accountSize.width + 64;

	[[NSImage imageNamed:@"Right.png"] compositeToPoint:NSMakePoint(x, cellFrame.origin.y + 22) operation:NSCompositeSourceOver];
	
	x = x + 24;
	
	[toAccountIcon compositeToPoint:NSMakePoint(x + 12, cellFrame.origin.y + 22) operation:NSCompositeSourceOver];
	[toAccountName drawInRect:NSMakeRect(x + 42, cellFrame.origin.y + 6, cellFrame.size.width - 20, 16) withAttributes:attsDict];
	
	paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];	
	[paragraphStyle setAlignment:NSLeftTextAlignment];
	
	font = [NSFont systemFontOfSize:11];
	
	color = [NSColor colorWithDeviceRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1.0];
	
	if ([self isHighlighted]) {
		color = [NSColor colorWithDeviceRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
	}
	
	attsDict = [NSDictionary dictionaryWithObjectsAndKeys:color, NSForegroundColorAttributeName, font, NSFontAttributeName, [NSNumber numberWithInt:NSNoUnderlineStyle], NSUnderlineStyleAttributeName, paragraphStyle, NSParagraphStyleAttributeName, nil];
	
	[name drawInRect:NSMakeRect(cellFrame.origin.x + 42, cellFrame.origin.y + 26, cellFrame.size.width - 20, 16) withAttributes:attsDict];
}

- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView {
	return NSCellHitContentArea;
}

- (void)dealloc {
    [name release];
	[date release];
	[fromAccountName release];
	[fromAmount release];
	[fromAccountIcon release];
	[toAccountName release];
	[toAmount release];
	[toAccountIcon release];
    [super dealloc];
}

@end
