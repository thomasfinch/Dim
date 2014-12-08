#import <libactivator/libactivator.h>
#import "DimController.h"

typedef enum {
    kBrightnessUp,
    kBrightnessDown,
    kEnable,
    kDisable,
    kControlPanel
} DimActivatorMode;

//Listens for activator events.
//One is created for each of the four possible events (on, off, brightness up, brightness down)
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
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefsChanged, CFSTR("com.thomasfinch.dim-prefschanged"), NULL,CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)dimToggleOn, CFSTR("com.thomasfinch.dim-on"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)dimToggleOff, CFSTR("com.thomasfinch.dim-off"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)dimShowControlCenter, CFSTR("com.thomasfinch.dim-controlPanel"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	[DimController sharedInstance]; //Initialize dim controller
	
	//Create all four activator listeners
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[LASharedActivator registerListener:[[DimListener alloc] initWithMode:kEnable] forName:@"com.thomasfinch.dim-on"];
	[LASharedActivator registerListener:[[DimListener alloc] initWithMode:kDisable] forName:@"com.thomasfinch.dim-off"];
	[LASharedActivator registerListener:[[DimListener alloc] initWithMode:kBrightnessUp] forName:@"com.thomasfinch.dim-up"];
	[LASharedActivator registerListener:[[DimListener alloc] initWithMode:kBrightnessDown] forName:@"com.thomasfinch.dim-down"];
	[LASharedActivator registerListener:[[DimListener alloc] initWithMode:kControlPanel] forName:@"com.thomasfinch.dim-controlPanel"];
	[pool drain];
}
