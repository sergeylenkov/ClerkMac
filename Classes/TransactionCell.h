#import <Cocoa/Cocoa.h>

@interface TransactionCell : NSCell {
	NSString *name;
	NSString *accountName;
	NSImage *accountIcon;
	NSString *amount;
	NSString *date;
	BOOL isIncoming;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *accountName;
@property (nonatomic, retain) NSImage *accountIcon;
@property (nonatomic, copy) NSString *amount;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, assign) BOOL isIncoming;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView;

@end
