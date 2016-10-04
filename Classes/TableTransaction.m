//
//  TableTransaction.m
//  Clerk
//
//  Created by Sergey Lenkov on 15.06.10.
//  Copyright 2010 Positive Team. All rights reserved.
//

#import "TableTransaction.h"

@implementation TableTransaction

@synthesize name;
@synthesize accountName;
@synthesize accountIcon;
@synthesize amount;
@synthesize date;
@synthesize isIncoming;
@synthesize accountTransaction;

- (id)init {
	if (self == [super init]) {
		self.name = @"";
		self.accountName = @"";
		self.amount = [NSNumber numberWithInt:0];
		self.date = [NSDate date];
	}
	
	return self;
}

- (NSComparisonResult)compareAmount:(TableTransaction *)transaction {
	if ([amount floatValue] < [transaction.amount floatValue]) {
		return NSOrderedAscending;
	} else if ([amount floatValue] > [transaction.amount floatValue]) {
		return NSOrderedDescending;
	}
	
	return NSOrderedSame;
}

- (NSComparisonResult)compareAccountName:(TableTransaction *)transaction {
	return [accountName localizedCompare:transaction.accountName];
}

- (NSComparisonResult)compareDate:(TableTransaction *)transaction {
	if ([date timeIntervalSince1970] < [transaction.date timeIntervalSince1970]) {
		return NSOrderedAscending;
	} else if ([date timeIntervalSince1970] > [transaction.date timeIntervalSince1970]) {
		return NSOrderedDescending;
	}
	
	return NSOrderedSame;
}

- (void)dealloc {
	[name release];
	[accountName release];
	[accountIcon release];
	[amount release];
	[date release];
	[accountTransaction release];
	[super dealloc];
}

@end
