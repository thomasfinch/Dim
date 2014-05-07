#import <Flipswitch/Flipswitch.h>
#import <libactivator/libactivator.h>
#import "DimWindow.h"

static DimWindow *dimOverlay;
static CGFloat dimAlpha = 0.1;

// Checks if Dim is current enabled via FlipSwitch
static BOOL dimOverlayActive() {
	return ([[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.thomasfinch.dim"] == FSSwitchStateOn);
}

// Toggles Dim off via FlipSwitch, removing it from current window
static void dimToggleOff(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
	[dimOverlay release];
}

// Toggles Dim on via FlipSwitch, adding it to the current window
static void dimToggleOn(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    dimOverlay = [[DimWindow alloc] init];
	dimOverlay.windowLevel = UIWindowLevelStatusBar;
    dimOverlay.alpha = dimAlpha;
    dimOverlay.hidden = NO;

	DimLog(@"Added Dim window %@ with alpha: %f", dimOverlay, dimAlpha);
}

@interface DimListener : NSObject <LAListener>
@property(nonatomic, readwrite) BOOL dimUp;
+ (DimListener *)listenerForUp:(BOOL)up;
@end

@implementation DimListener

// Initializes a new listener with "dimUp" property to control activation result
+ (DimListener *)listenerForUp:(BOOL)up {
	DimListener *listener = [self new];
	listener.dimUp = up;
	return listener;
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	if (!dimOverlayActive()) {	// If FlipSwitch isn't turned on...
		UIAlertView *dimDisabled = [[UIAlertView alloc] initWithTitle:@"Dim" message:@"Enable Dim using the built-in FlipSwitch to adjust its opacity." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[dimDisabled show];
		[dimDisabled release];
		return;
	}

	else if (self.dimUp) {	// If initialized with dimUp = YES, make more opaque...
		DimLog(@"Opacity (%f) up...", dimAlpha);
		dimAlpha = fmin(dimAlpha + 0.1, 1.0);
	}

	else {
		DimLog(@"Opacity (%f) down...", dimAlpha);
		dimAlpha = fmax(dimAlpha - 0.1, 0.0);
	}

	dimOverlay.alpha = dimAlpha;
	[event setHandled:YES]; // To prevent the default iOS implementation
}
 
+ (void)load {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // rpetrich-style
	[LASharedActivator registerListener:[self listenerForUp:YES] forName:@"com.thomasfinch.dim-up"];
	[LASharedActivator registerListener:[self listenerForUp:NO] forName:@"com.thomasfinch.dim-down"];
	[pool drain];
}

@end

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &dimToggleOn, CFSTR("com.thomasfinch.dim-on"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &dimToggleOff, CFSTR("com.thomasfinch.dim-off"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	[DimListener load];
}
