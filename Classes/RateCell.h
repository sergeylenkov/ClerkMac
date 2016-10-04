//
//  ExchangeCell.h
//  Clerk
//
//  Created by Sergey Lenkov on 20.05.10.
//  Copyright 2010 Positive Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RateCell : NSCell {
	NSString *fromCurrency;
	NSString *toCurrency;
	NSString *date;
	NSString *rate;
	NSImage *arrowIcon;
}

@property (nonatomic, copy) NSString *fromCurrency;
@property (nonatomic, copy) NSString *toCurrency;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *rate;
@property (nonatomic, retain) NSImage *arrowIcon;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView;

@end
