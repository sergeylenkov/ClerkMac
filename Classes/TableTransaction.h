//
//  TableTransaction.h
//  Clerk
//
//  Created by Sergey Lenkov on 15.06.10.
//  Copyright 2010 Positive Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Transaction.h"

@interface TableTransaction : NSObject {
	NSString *name;
	NSString *accountName;
	NSImage *accountIcon;
	NSNumber *amount;
	NSDate *date;
	BOOL isIncoming;
	Transaction *accountTransaction;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *accountName;
@property (nonatomic, retain) NSImage *accountIcon;
@property (nonatomic, retain) NSNumber *amount;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, assign) BOOL isIncoming;
@property (nonatomic, retain) Transaction *accountTransaction;

- (NSComparisonResult)compareAmount:(TableTransaction *)transaction;
- (NSComparisonResult)compareAccountName:(TableTransaction *)transaction;
- (NSComparisonResult)compareDate:(TableTransaction *)transaction;

@end
