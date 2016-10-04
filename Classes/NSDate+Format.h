#import <Cocoa/Cocoa.h>

@interface NSDate (Format)

- (NSString *)formattedDateWithYear:(BOOL)year;
- (NSString *)formattedMonth;
- (NSDate *)truncate;
- (NSDate *)dateByAddingDays:(NSInteger)days;

@end
