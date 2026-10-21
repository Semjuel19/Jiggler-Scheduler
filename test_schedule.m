// Self-check for JigglerScheduleAllows.  Run: ./build.sh test
#import "ScheduleController.h"
#include <assert.h>

int main(void)
{
	NSDictionary *off = @{@"on": @NO, @"start": @0, @"end": @0};
	NSDictionary *work = @{@"on": @YES, @"start": @(9 * 60), @"end": @(17 * 60)};
	NSDictionary *night = @{@"on": @YES, @"start": @(22 * 60), @"end": @(2 * 60)};
	NSArray *days = @[off, work, work, work, work, night, off];	// Sun..Sat; Friday runs past midnight

	assert(JigglerScheduleAllows(days, 1, 9 * 60));			// Mon 09:00 start is inclusive
	assert(JigglerScheduleAllows(days, 1, 16 * 60 + 59));
	assert(!JigglerScheduleAllows(days, 1, 17 * 60));		// end is exclusive
	assert(!JigglerScheduleAllows(days, 1, 8 * 60));
	assert(!JigglerScheduleAllows(days, 0, 12 * 60));		// Sunday off
	assert(JigglerScheduleAllows(days, 5, 23 * 60));		// Fri 23:00
	assert(JigglerScheduleAllows(days, 6, 1 * 60));			// Sat 01:00 is Friday's tail
	assert(!JigglerScheduleAllows(days, 6, 3 * 60));
	assert(!JigglerScheduleAllows(days, 5, 1 * 60));		// Thu has no overnight tail
	assert(!JigglerScheduleAllows(@[], 1, 600));			// bad data -> off
	puts("schedule ok");
	return 0;
}
