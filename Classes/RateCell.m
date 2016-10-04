//
//  ExchangeCell.m
//  Clerk
//
//  Created by Sergey Lenkov on 20.05.10.
//  Copyright 2010 Positive Team. All rights reserved.
//

#import "RateCell.h"

#define CELL_HEIGHT 28
#define LABEL_OFFSET 7
#define ICON_OFFSET 22

@implementation RateCell

@synthesize fromCurrency;
@synthesize toCurrency;
@synthesize date;
@synthesize rate;
@synthesize arrowIcon;

- (id)init {
	if (self = [super init]) {
		self.fromCurrency = @"";
		self.toCurrency = @"";
		self.date = @"";
		self.rate = @"";
	}
	
	return self;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	[[NSColor colorWithDeviceRed:182.0/255.0 green:193.0/255.0 blue:193.0/255.0 alpha:1.0] set];
	NSRectFill(cellFrame);
	
	[[NSGraphicsContext currentContext] saveGraphicsState];
	
	float yOffset = cellFrame.origin.y;
	
	if ([controlView isFlipped]) {
		NSAffineTransform *xform = [NSAffineTransform transform];
		[xform translateXBy:0.0 yBy:cellFrame.size.height];
		[xform scaleXBy:1.0 yBy:-1.0];
		[xform concat];		
		yOffset = 0 - cellFrame.origin.y;
	}
	
	NSImageInterpolation interpolation = [[NSGraphicsContext currentContext] imageInterpolation];
	[[NSGraphicsContext currentContext] setImageInterpolation: NSImageInterpolationHigh];	
	
	NSColor *textColor = [NSColor blackColor];
	NSColor *descriptionColor = [NSColor colorWithDeviceRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0];
	
	if ([self isHighlighted]) {
		[[NSImage imageNamed:@"RowBgLeftSelected.png"] drawInRect:NSMakeRect(cellFrame.origin.x + 10, yOffset, 20, CELL_HEIGHT) fromRect:NSMakeRect(0, 0, 20, CELL_HEIGHT) operation:NSCompositeSourceOver fraction:1.0];
		[[NSImage imageNamed:@"RowBgCenterSelected.png"] drawInRect:NSMakeRect(cellFrame.origin.x + 30, yOffset, cellFrame.size.width - 60, CELL_HEIGHT) fromRect:NSMakeRect(0, 0, 20, CELL_HEIGHT) operation:NSCompositeSourceOver fraction:1.0];
		[[NSImage imageNamed:@"RowBgRightSelected.png"] drawInRect:NSMakeRect(cellFrame.size.width - 30, yOffset, 20, CELL_HEIGHT) fromRect:NSMakeRect(0, 0, 20, CELL_HEIGHT) operation:NSCompositeSourceOver fraction:1.0];
		
		textColor = [NSColor whiteColor];
		descriptionColor = [NSColor whiteColor];
	} else {
		[[NSImage imageNamed:@"RowBgLeft.png"] drawInRect:NSMakeRect(cellFrame.origin.x + 10, yOffset, 20, CELL_HEIGHT) fromRect:NSMakeRect(0, 0, 20, CELL_HEIGHT) operation:NSCompositeSourceOver fraction:1.0];
		[[NSImage imageNamed:@"RowBgCenter.png"] drawInRect:NSMakeRect(cellFrame.origin.x + 30, yOffset, cellFrame.size.width - 60, CELL_HEIGHT) fromRect:NSMakeRect(0, 0, 20, CELL_HEIGHT) operation:NSCompositeSourceOver fraction:1.0];
		[[NSImage imageNamed:@"RowBgRight.png"] drawInRect:NSMakeRect(cellFrame.size.width - 30, yOffset, 20, CELL_HEIGHT) fromRect:NSMakeRect(0, 0, 20, CELL_HEIGHT) operation:NSCompositeSourceOver fraction:1.0];
	}
	
	[[NSGraphicsContext currentContext] setImageInterpolation:interpolation];
	
	[[NSGraphicsContext currentContext] restoreGraphicsState];	
	
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paragraphStyle setAlignment:NSLeftTextAlignment];
	
	NSFont *font = [NSFont boldSystemFontOfSize:11];
	NSDictionary *attsDict = [NSDictionary dictionaryWithObjectsAndKeys:textColor, NSForegroundColorAttributeName, font, NSFontAttributeName, [NSNumber numberWithInt:NSNoUnderlineStyle], NSUnderlineStyleAttributeName, paragraphStyle, NSParagraphStyleAttributeName, nil];
	
	paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];	
	[paragraphStyle setAlignment:NSLeftTextAlignment];
		
	font = [NSFont boldSystemFontOfSize:11];
	attsDict = [NSDictionary dictionaryWithObjectsAndKeys:textColor, NSForegroundColorAttributeName, font, NSFontAttributeName, [NSNumber numberWithInt:NSNoUnderlineStyle], NSUnderlineStyleAttributeName, paragraphStyle, NSParagraphStyleAttributeName, nil];
	
	NSSize dateSize = [date sizeWithAttributes:attsDict];
	
	[date drawInRect:NSMakeRect(cellFrame.origin.x + 30, cellFrame.origin.y + LABEL_OFFSET, dateSize.width, 16) withAttributes:attsDict];
	
	font = [NSFont systemFontOfSize:11];
	attsDict = [NSDictionary dictionaryWithObjectsAndKeys:textColor, NSForegroundColorAttributeName, font, NSFontAttributeName, [NSNumber numberWithInt:NSNoUnderlineStyle], NSUnderlineStyleAttributeName, paragraphStyle, NSParagraphStyleAttributeName, nil];
	
	int x = cellFrame.origin.x + dateSize.width + 60;
	
	if (x < 160) {
		x = 160;
	}
	
	[fromCurrency drawInRect:NSMakeRect(x, cellFrame.origin.y + LABEL_OFFSET, 200, 16) withAttributes:attsDict];
	[toCurrency drawInRect:NSMakeRect(x + 110, cellFrame.origin.y + LABEL_OFFSET, 200, 16) withAttributes:attsDict];
	
	[[NSImage imageNamed:@"Right.png"] compositeToPoint:NSMakePoint(x + 60, cellFrame.origin.y + ICON_OFFSET) operation:NSCompositeSourceOver];
	
	paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];	
	[paragraphStyle setAlignment:NSRightTextAlignment];
	
	font = [NSFont boldSystemFontOfSize:11];
	attsDict = [NSDictionary dictionaryWithObjectsAndKeys:textColor, NSForegroundColorAttributeName, font, NSFontAttributeName, [NSNumber numberWithInt:NSNoUnderlineStyle], NSUnderlineStyleAttributeName, paragraphStyle, NSParagraphStyleAttributeName, nil];
	
	[rate drawInRect:NSMakeRect(cellFrame.size.width - 230, cellFrame.origin.y + LABEL_OFFSET, 200, 16) withAttributes:attsDict];
	
	//[arrowIcon compositeToPoint:NSMakePoint(cellFrame.size.width - 40, cellFrame.origin.y + ICON_OFFSET) operation:NSCompositeSourceOver];
}

- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView {
	NSInteger result = NSCellHitContentArea;		
	return result;
}

- (void)dealloc {
    [fromCurrency release];
	[toCurrency release];
	[date release];
	[rate release];
	[arrowIcon release];
    [super dealloc];
}

@end