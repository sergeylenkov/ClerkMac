#import <Cocoa/Cocoa.h>

@interface SchedulerCell : NSCell {
	NSString *name;
	NSString *fromAccountName;
	NSString *toAccountName;
	NSImage *fromAccountIcon;
	NSImage *toAccountIcon;
	NSString *description;
	NSString *nextRunAt;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *fromAccountName;
@property (nonatomic, copy) NSString *toAccountName;
@property (nonatomic, retain) NSImage *fromAccountIcon;
@property (nonatomic, retain) NSImage *toAccountIcon;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *nextRunAt;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView;

@end
