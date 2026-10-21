//
//  ScheduleController.h
//  Jiggler
//
//  Weekly schedule: when enabled, jiggling is only allowed inside each day's start/end window.
//

#import <Cocoa/Cocoa.h>


// Pure check, exposed for testing.  days: 7 dicts (index 0 = Sunday) with keys "on" (BOOL), "start"/"end" (minutes
// after midnight).  end <= start means the window runs past midnight into the next day.
BOOL JigglerScheduleAllows(NSArray *days, NSInteger weekdayIndex, NSInteger minuteOfDay);

@interface ScheduleController : NSObject

+ (ScheduleController *)sharedScheduleController;

- (void)showWindow;
- (BOOL)scheduleEnabled;
- (BOOL)scheduleAllowsJigglingNow;	// YES when the schedule is off, or now is inside a window

@end
