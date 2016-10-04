//
//  CenterCell.m
//  Clerk
//
//  Created by Sergey Lenkov on 15.06.10.
//  Copyright 2010 Positive Team. All rights reserved.
//

#import "CenterCell.h"


@implementation CenterCell

- (NSRect)titleRectForBounds:(NSRect)theRect {
    NSRect titleFrame = [super titleRectForBounds:theRect];
    NSSize titleSize = [[self attributedStringValue] size];
	
    titleFrame.origin.y = theRect.origin.y + (theRect.size.height - titleSize.height) / 2.0;

	titleFrame.origin.x = titleFrame.origin.x + 8;
	titleFrame.size.width = titleFrame.size.width - 16;
	
    return titleFrame;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSRect titleRect = [self titleRectForBounds:cellFrame];
    [[self attributedStringValue] drawInRect:titleRect];
}

@end
