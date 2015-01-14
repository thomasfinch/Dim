#import <libactivator/libactivator.h>
#include <dlfcn.h>
#import <objc/runtime.h>
#import "DimController.h"

typedef enum {
    kBrightnessUp,
    kBrightnessDown,
    kEnable,
    kDisable,
    kToggle,
    kControlPanel
} DimActivatorMode;

//Listens for activator events.
//One is created for each of the four possible events (on, off, toggle on/off, brightness up, brightness down)
@interface DimListener : NSObject <LAListener> {
	DimActivatorMode mode;
}
- (id)initWithMode:(DimActivatorMode)inMode;
@end

@implementation DimListener

- (id)initWithMode:(DimActivatorMode)inMode {
	if (self = [super init]) {
		mode = inMode;
	}
	return self;
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	[event setHandled:YES]; // To prevent the default iOS implementation

	switch (mode) {
		case kBrightnessUp:
			if ([DimController sharedInstance].enabled)
				[[DimController sharedInstance] setBrightness:[DimController sharedInstance].brightness - [DimController sharedInstance].alphaInterval];
			else
				[event setHandled:NO];
			break;
		case kBrightnessDown:
			if ([DimController sharedInstance].enabled)
				[[DimController sharedInstance] setBrightness:[DimController sharedInstance].brightness + [DimController sharedInstance].alphaInterval];
			else
				[event setHandled:NO];
			break;
		case kEnable:
			[[DimController sharedInstance] setEnabled:YES];
			break;
		case kDisable:
			[[DimController sharedInstance] setEnabled:NO];
			break;
		case kToggle:
			if ([DimController sharedInstance].enabled)
				[[DimController sharedInstance] setEnabled:NO];
			else
				[[DimController sharedInstance] setEnabled:YES];
			break;
		case kControlPanel:
			[[DimController sharedInstance] showControlPanel];
			break;
	}
}

@end

//Called when any preference is changed in the settings app
void prefsChanged() {
	[DimController sharedInstance].prefsChangedFromSettings = YES;
    [[DimController sharedInstance] updateSettings];
}

//Called by the flipswitch toggle
void dimToggleOff(){
	[[DimController sharedInstance] setEnabled:NO];
}

//Called by the flipswitch toggle
void dimToggleOn() {
	[[DimController sharedInstance] setEnabled:YES];
}

//Called by the flipswitch toggle on long hold
void dimShowControlCenter() {
	[[DimController sharedInstance] showControlPanel];
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefsChanged, CFSTR("com.thomasfinch.dim-prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)dimToggleOn, CFSTR("com.thomasfinch.dim-on"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)dimToggleOff, CFSTR("com.thomasfinch.dim-off"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)dimShowControlCenter, CFSTR("com.thomasfinch.dim-controlPanel"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	[DimController sharedInstance]; //Initialize dim controller
	
	//Create all four activator listeners
	dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
	Class la = objc_getClass("LAActivator");
	if (la) { //If activator is installed, set listeners
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		[[la sharedInstance] registerListener:[[DimListener alloc] initWithMode:kEnable] forName:@"com.thomasfinch.dim-on"];
		[[la sharedInstance] registerListener:[[DimListener alloc] initWithMode:kDisable] forName:@"com.thomasfinch.dim-off"];
		[[la sharedInstance] registerListener:[[DimListener alloc] initWithMode:kBrightnessUp] forName:@"com.thomasfinch.dim-up"];
		[[la sharedInstance] registerListener:[[DimListener alloc] initWithMode:kBrightnessDown] forName:@"com.thomasfinch.dim-down"];
		[[la sharedInstance] registerListener:[[DimListener alloc] initWithMode:kToggle] forName:@"com.thomasfinch.dim-toggle"];
		[[la sharedInstance] registerListener:[[DimListener alloc] initWithMode:kControlPanel] forName:@"com.thomasfinch.dim-controlPanel"];
		[pool drain];
	}

	NSLog(@"INITTED DIM!!!!!");
}
