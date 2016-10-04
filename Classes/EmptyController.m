#import "EmptyController.h"

@implementation EmptyController

@synthesize type;

- (void)setText:(NSString *)text {
	[button setHidden:NO];
	[button setTitle:text];
}

- (void)hideButton {
	[button setHidden:YES];
}

- (IBAction)buttonPressed:(id)sender {
	if (type == 0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AddReceipt" object:nil];
	}
	
	if (type == 1) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AddDeposit" object:nil];
	}
	
	if (type == 2) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AddExpense" object:nil];
	}
}

@end
