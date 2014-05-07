#import <GraphicsServices/GSEvent.h>
#import <Flipswitch/Flipswitch.h>
#import <libactivator/libactivator.h>
#import <dlfcn.h>

#ifdef DEBUG
	#define DimLog(fmt, ...) NSLog((@"[Dim] %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
	#define DimLog(fmt, ...)
#endif

@interface UIWindow (Private)
	// UIView *_exclusiveTouchView;
+ (id)keyWindow;
+ (id)allWindowsIncludingInternalWindows:(BOOL)arg1 onlyVisibleWindows:(BOOL)arg2;
+ (id)allWindowsIncludingInternalWindows:(BOOL)arg1 onlyVisibleWindows:(BOOL)arg2 forScreen:(id)arg3;
@end

extern "C" GSEventType GSEventGetType(GSEventRef event);

static UIWindow *dimOverlay;
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
    dimOverlay = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    dimOverlay.windowLevel = UIWindowLevelStatusBar;
    dimOverlay.backgroundColor = [UIColor blackColor];
    dimOverlay.alpha = dimAlpha;

	DimLog(@"Adding Dim window %@ with alpha: %f", dimOverlay, dimAlpha);
	[dimOverlay makeKeyAndVisible];
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
	/*NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *block) {
		if (dimOverlayActive()) {
			dimOverlay = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
			dimOverlay.backgroundColor = [UIColor blackColor];
			dimOverlay.alpha = dimAlpha;
			dimOverlay.windowLevel = 100000.0f;
			dimOverlay.userInteractionEnabled = NO;
			dimOverlay.hidden = NO;
		}
	}];
	[pool drain];*/

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &dimToggleOn, CFSTR("com.thomasfinch.dim-on"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &dimToggleOff, CFSTR("com.thomasfinch.dim-off"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	[DimListener load];
}
