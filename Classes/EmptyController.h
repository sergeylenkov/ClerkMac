#import <Cocoa/Cocoa.h>

@interface EmptyController : NSViewController {	
	IBOutlet NSButton *button;
	NSInteger type;
}

@property (nonatomic, assign) NSInteger type;

- (void)setText:(NSString *)text;
- (void)hideButton;

- (IBAction)buttonPressed:(id)sender;

@end
