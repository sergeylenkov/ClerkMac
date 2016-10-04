#import "NSDate+Format.h"

@implementation NSDate (Format)

- (NSString *)formattedDateWithYear:(BOOL)year {	
	NSString *day;
		
	if (year) {
		day = [self descriptionWithCalendarFormat:@"%e, %Y" timeZone:nil locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
	} else {
		day = [self descriptionWithCalendarFormat:@"%e" timeZone:nil locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
	}
		
	NSString *month = [self descriptionWithCalendarFormat:@"%m" timeZone:nil locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
		
	switch ([month intValue]) {
		case 1:
			month = @"Jan";
			break;
		case 2:
			month = @"Feb";
			break;
		case 3:
			month = @"Mar";
			break;
		case 4:
			month = @"Apr";
			break;
		case 5:
			month = @"May";
			break;
		case 6:
			month = @"Jun";
			break;
		case 7:
			month = @"Jul";
			break;
		case 8:
			month = @"Aug";
			break;
		case 9:
			month = @"Sep";
			break;
		case 10:
			month = @"Oct";
			break;
		case 11:
			month = @"Nov";
			break;
		case 12:
			month = @"Dec";
			break;
		default:
			break;
	}
		
	return [NSString stringWithFormat:@"%@ %@", month, day];
}

- (NSString *)formattedMonth {
	NSString *year = [self descriptionWithCalendarFormat:@"%Y" timeZone:nil locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];	
	NSString *month = [self descriptionWithCalendarFormat:@"%m" timeZone:nil locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
	
	switch ([month intValue]) {
		case 1:
			month = @"Jan";
			break;
		case 2:
			month = @"Feb";
			break;
		case 3:
			month = @"Mar";
			break;
		case 4:
			month = @"Apr";
			break;
		case 5:
			month = @"May";
			break;
		case 6:
			month = @"Jun";
			break;
		case 7:
			month = @"Jul";
			break;
		case 8:
			month = @"Aug";
			break;
		case 9:
			month = @"Sep";
			break;
		case 10:
			month = @"Oct";
			break;
		case 11:
			month = @"Nov";
			break;
		case 12:
			month = @"Dec";
			break;
		default:
			break;
	}
	
	return [NSString stringWithFormat:@"%@ %@", month, year];
}

- (NSDate *)truncate {
	NSCalendar *calendar = [NSCalendar currentCalendar];		
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:self];
	
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	
	return [calendar dateFromComponents:components];
}

- (NSDate *)dateByAddingDays:(NSInteger)days {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
	
	[components setDay:days];
	
	return [calendar dateByAddingComponents:components toDate:self options:0];
}

@end
