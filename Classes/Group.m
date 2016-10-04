#import "Group.h"

@implementation Group

@synthesize name;

- (void)dealloc {
	[name release];
	[super dealloc];
}

@end
