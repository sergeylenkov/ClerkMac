#import "Report.h"

@implementation Report

@synthesize name;

- (void)dealloc {
	[name release];
	[super dealloc];
}

@end
