//
//  ScheduleController.m
//  Jiggler
//
//  Weekly schedule: when enabled, jiggling is only allowed inside each day's start/end window.
//  The window is built in code so no .xib changes are needed.
//

#import "ScheduleController.h"


static NSString *JiggleScheduleEnabledDefaultsKey = @"JiggleScheduleEnabled";	// BOOL
static NSString *JiggleScheduleDaysDefaultsKey = @"JiggleScheduleDays";			// 7 dicts, index 0 = Sunday


BOOL JigglerScheduleAllows(NSArray *days, NSInteger weekdayIndex, NSInteger minuteOfDay)
{
	if ([days count] != 7)
		return NO;

	NSDictionary *today = [days objectAtIndex:weekdayIndex];
	NSDictionary *yesterday = [days objectAtIndex:(weekdayIndex + 6) % 7];

	if ([[today objectForKey:@"on"] boolValue])
	{
		NSInteger start = [[today objectForKey:@"start"] integerValue], end = [[today objectForKey:@"end"] integerValue];

		if (start < end ? (minuteOfDay >= start && minuteOfDay < end) : (minuteOfDay >= start))
			return YES;
	}

	// The tail of yesterday's window, if it ran past midnight
	if ([[yesterday objectForKey:@"on"] boolValue])
	{
		NSInteger start = [[yesterday objectForKey:@"start"] integerValue], end = [[yesterday objectForKey:@"end"] integerValue];

		if (end <= start && minuteOfDay < end)
			return YES;
	}

	return NO;
}


@implementation ScheduleController
{
	NSWindow *window;
	NSButton *enabledCheckbox;
	NSMutableArray *dayCheckboxes, *startPickers, *endPickers;	// indexed like the defaults, 0 = Sunday
}

+ (ScheduleController *)sharedScheduleController
{
	static ScheduleController *shared = nil;

	if (!shared)
	{
		NSDictionary *weekday = @{@"on": @YES, @"start": @(9 * 60), @"end": @(17 * 60)};
		NSDictionary *weekend = @{@"on": @NO, @"start": @(9 * 60), @"end": @(17 * 60)};

		[[NSUserDefaults standardUserDefaults] registerDefaults:@{JiggleScheduleEnabledDefaultsKey: @NO,
																  JiggleScheduleDaysDefaultsKey: @[weekend, weekday, weekday, weekday, weekday, weekday, weekend]}];
		shared = [[ScheduleController alloc] init];
	}

	return shared;
}

- (BOOL)scheduleEnabled
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:JiggleScheduleEnabledDefaultsKey];
}

- (BOOL)scheduleAllowsJigglingNow
{
	if (![self scheduleEnabled])
		return YES;

	NSDateComponents *now = [[NSCalendar currentCalendar] components:(NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
	NSArray *days = [[NSUserDefaults standardUserDefaults] arrayForKey:JiggleScheduleDaysDefaultsKey];

	return JigglerScheduleAllows(days, [now weekday] - 1, [now hour] * 60 + [now minute]);
}

#pragma mark Window

static NSDate *DateForMinutes(NSInteger minutes)
{
	NSDateComponents *c = [[[NSDateComponents alloc] init] autorelease];

	[c setYear:2001]; [c setMonth:1]; [c setDay:1];
	[c setHour:minutes / 60]; [c setMinute:minutes % 60];
	return [[NSCalendar currentCalendar] dateFromComponents:c];
}

static NSInteger MinutesForDate(NSDate *date)
{
	NSDateComponents *c = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];

	return [c hour] * 60 + [c minute];
}

- (NSDatePicker *)timePickerAt:(NSPoint)origin minutes:(NSInteger)minutes
{
	NSDatePicker *picker = [[[NSDatePicker alloc] initWithFrame:NSMakeRect(origin.x, origin.y, 90, 24)] autorelease];

	[picker setDatePickerStyle:NSDatePickerStyleTextFieldAndStepper];
	[picker setDatePickerElements:NSDatePickerElementFlagHourMinute];
	[picker setDateValue:DateForMinutes(minutes)];
	[picker setTarget:self];
	[picker setAction:@selector(scheduleChanged:)];
	return picker;
}

- (void)buildWindow
{
	NSArray *days = [[NSUserDefaults standardUserDefaults] arrayForKey:JiggleScheduleDaysDefaultsKey];
	NSArray *dayNames = [[[[NSDateFormatter alloc] init] autorelease] weekdaySymbols];	// localized, index 0 = Sunday
	NSInteger displayOrder[7] = {1, 2, 3, 4, 5, 6, 0};	// Monday first
	CGFloat rowHeight = 30, height = 7 * rowHeight + 125;

	window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 380, height) styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable) backing:NSBackingStoreBuffered defer:YES];
	[window setTitle:@"Jiggler Schedule"];
	[window setReleasedWhenClosed:NO];

	NSView *content = [window contentView];

	enabledCheckbox = [NSButton checkboxWithTitle:@"Only jiggle during these hours" target:self action:@selector(scheduleChanged:)];
	[enabledCheckbox setFrameOrigin:NSMakePoint(20, height - 40)];
	[enabledCheckbox setState:[self scheduleEnabled] ? NSControlStateValueOn : NSControlStateValueOff];
	[content addSubview:enabledCheckbox];

	dayCheckboxes = [[NSMutableArray alloc] initWithCapacity:7];
	startPickers = [[NSMutableArray alloc] initWithCapacity:7];
	endPickers = [[NSMutableArray alloc] initWithCapacity:7];

	for (int i = 0; i < 7; ++i)
	{
		[dayCheckboxes addObject:[NSNull null]];
		[startPickers addObject:[NSNull null]];
		[endPickers addObject:[NSNull null]];
	}

	for (int row = 0; row < 7; ++row)
	{
		NSInteger d = displayOrder[row];
		NSDictionary *day = [days objectAtIndex:d];
		CGFloat y = height - 80 - row * rowHeight;

		NSButton *dayCheckbox = [NSButton checkboxWithTitle:[dayNames objectAtIndex:d] target:self action:@selector(scheduleChanged:)];
		[dayCheckbox setFrameOrigin:NSMakePoint(40, y + 3)];
		[dayCheckbox setState:[[day objectForKey:@"on"] boolValue] ? NSControlStateValueOn : NSControlStateValueOff];
		[content addSubview:dayCheckbox];

		NSDatePicker *startPicker = [self timePickerAt:NSMakePoint(160, y) minutes:[[day objectForKey:@"start"] integerValue]];
		NSDatePicker *endPicker = [self timePickerAt:NSMakePoint(275, y) minutes:[[day objectForKey:@"end"] integerValue]];
		NSTextField *toLabel = [NSTextField labelWithString:@"to"];

		[toLabel setFrameOrigin:NSMakePoint(255, y + 4)];
		[content addSubview:startPicker];
		[content addSubview:toLabel];
		[content addSubview:endPicker];

		[dayCheckboxes replaceObjectAtIndex:d withObject:dayCheckbox];
		[startPickers replaceObjectAtIndex:d withObject:startPicker];
		[endPickers replaceObjectAtIndex:d withObject:endPicker];
	}

	NSTextField *note = [NSTextField wrappingLabelWithString:@"Uses this Mac's clock. An end time earlier than the start time runs past midnight. The Jiggler Enabled menu item still turns jiggling off entirely."];
	[note setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
	[note setTextColor:[NSColor secondaryLabelColor]];
	[note setFrame:NSMakeRect(20, 12, 340, 44)];
	[content addSubview:note];

	[self fixEnabledState];
}

- (void)fixEnabledState
{
	BOOL enabled = ([enabledCheckbox state] == NSControlStateValueOn);

	for (int i = 0; i < 7; ++i)
	{
		BOOL dayOn = enabled && ([[dayCheckboxes objectAtIndex:i] state] == NSControlStateValueOn);

		[[dayCheckboxes objectAtIndex:i] setEnabled:enabled];
		[[startPickers objectAtIndex:i] setEnabled:dayOn];
		[[endPickers objectAtIndex:i] setEnabled:dayOn];
	}
}

- (IBAction)scheduleChanged:(id)sender
{
	NSMutableArray *days = [NSMutableArray arrayWithCapacity:7];

	for (int i = 0; i < 7; ++i)
		[days addObject:@{@"on": @([[dayCheckboxes objectAtIndex:i] state] == NSControlStateValueOn),
						  @"start": @(MinutesForDate([[startPickers objectAtIndex:i] dateValue])),
						  @"end": @(MinutesForDate([[endPickers objectAtIndex:i] dateValue]))}];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	[userDefaults setBool:([enabledCheckbox state] == NSControlStateValueOn) forKey:JiggleScheduleEnabledDefaultsKey];
	[userDefaults setObject:days forKey:JiggleScheduleDaysDefaultsKey];
	[self fixEnabledState];
}

- (void)showWindow
{
	if (!window)
		[self buildWindow];

	[window center];
	[NSApp activateIgnoringOtherApps:YES];
	[window makeKeyAndOrderFront:nil];
}

@end
