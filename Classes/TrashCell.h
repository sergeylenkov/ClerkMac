//
//  TrashCell.h
//  Clerk
//
//  Created by Sergey Lenkov on 20.05.10.
//  Copyright 2010 Positive Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TrashCell : NSCell {
	NSString *name;
	NSString *date;
	NSString *fromAccountName;
	NSString *fromAmount;
	NSImage *fromAccountIcon;
	NSString *toAccountName;
	NSString *toAmount;
	NSImage *toAccountIcon;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *fromAccountName;
@property (nonatomic, copy) NSString *fromAmount;
@property (nonatomic, retain) NSImage *fromAccountIcon;
@property (nonatomic, copy) NSString *toAccountName;
@property (nonatomic, copy) NSString *toAmount;
@property (nonatomic, retain) NSImage *toAccountIcon;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView;

@end
