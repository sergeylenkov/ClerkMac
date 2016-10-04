#import "MenuItem.h"

@implementation MenuItem

@synthesize name;

- (void)dealloc {
	[name release];
	[super dealloc];
}

@end
