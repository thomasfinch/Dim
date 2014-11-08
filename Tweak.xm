#import <libactivator/libactivator.h>
#import "DimWindow.h"

static BOOL enabled = NO;
static CGFloat dimAlpha = 0.3, alphaInterval = 0.1;
static DimWindow *dimOverlay;

void setEnabled(BOOL isEnabled) {
	enabled = isEnabled;

	if (enabled) {
		dimOverlay = [[DimWindow alloc] init];
		dimOverlay.windowLevel = 1000001; //Beat that ryan petrich
	    dimOverlay.alpha = dimAlpha;
	    dimOverlay.hidden = NO;
	}
	else
		[dimOverlay release];


	//Update settings
}

void changeBrightness(BOOL brighter) {
	if (brighter)
		dimAlpha = fmin(dimAlpha - alphaInterval, 1.0);
	else
		dimAlpha = fmax(dimAlpha + alphaInterval, 0.0);

	dimOverlay.alpha = dimAlpha;

	//Update settings
}

@interface DimListener : NSObject <LAListener> {
	int mode;
}
- (id)initWithMode:(int)inMode;
@end

@implementation DimListener

- (id)initWithMode:(int)inMode {
	if (self = [super init]) {
		mode = inMode;
	}
	return self;
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	[event setHandled:YES]; // To prevent the default iOS implementation

	switch (mode) {
		case 0: //Brightness up
			if (enabled)
				changeBrightness(YES);
			else
				[event setHandled:NO];
			break;
		case 1: //Brightness down
			if (enabled)
				changeBrightness(NO);
			else
				[event setHandled:NO];
			break;
		case 2: //Enable
			setEnabled(YES);
			break;
		case 3: //Disable
			setEnabled(NO);
			break;
	}
}

@end

static void dimToggleOff(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
	setEnabled(NO);
}

static void dimToggleOn(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	setEnabled(YES);
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &dimToggleOn, CFSTR("com.thomasfinch.dim-on"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &dimToggleOff, CFSTR("com.thomasfinch.dim-off"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	
	[LASharedActivator registerListener:[[DimListener alloc] initWithMode:2] forName:@"com.thomasfinch.dim-on"];
	[LASharedActivator registerListener:[[DimListener alloc] initWithMode:3] forName:@"com.thomasfinch.dim-off"];
	[LASharedActivator registerListener:[[DimListener alloc] initWithMode:0] forName:@"com.thomasfinch.dim-up"];
	[LASharedActivator registerListener:[[DimListener alloc] initWithMode:1] forName:@"com.thomasfinch.dim-down"];
}
