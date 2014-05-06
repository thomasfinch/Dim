#import <Flipswitch/Flipswitch.h>
#import <libactivator/libactivator.h>
#import <dlfcn.h>

extern "C" GSEventType GSEventGetType(GSEventRef event);

static float alpha = 0.0f;
static UIWindow *overlay;

static BOOL isOn()
{
	return ([[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.thomasfinch.dim"] == FSSwitchStateOn);
}

static void dimToggleOff(CFNotificationCenterRef center, void *observer,CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	[overlay release];
}

static void dimToggleOn(CFNotificationCenterRef center, void *observer,CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	overlay = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
	overlay.windowLevel = UIWindowLevelStatusBar;
	overlay.userInteractionEnabled = NO;
	overlay.alpha = alpha;
	overlay.backgroundColor = [UIColor blackColor];
	[overlay makeKeyAndVisible];
}

@interface Listener : NSObject <LAListener>
@end

@implementation Listener

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	if (!isOn())
		return;
 
	if ([[event name] isEqualToString:@"libactivator.volume.up.press"])
	{
		NSLog(@"UP");
		alpha -= 0.1f;
		if (alpha < 0)
			alpha = 0.0f;
	}
	else
	{
		NSLog(@"DOWN");
		alpha += 0.1f;
		if (alpha > 1)
			alpha = 1.0f;
	}
	overlay.alpha = alpha;
 
	[event setHandled:YES]; // To prevent the default OS implementation
}
 
+ (void)load
{
	if ([LASharedActivator isRunningInsideSpringBoard]) {
		dlopen("/Library/MobileSubstrate/DynamicLibraries/Activator.dylib", RTLD_NOW);
		id obj = [self new];
		[LASharedActivator registerListener:obj forName:@"com.thomasfinch.dim-up"];
		[LASharedActivator registerListener:obj forName:@"com.thomasfinch.dim-down"];
	}
}

@end

%ctor
{
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, dimToggleOn, CFSTR("com.thomasfinch.dim-on"), NULL,CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, dimToggleOff, CFSTR("com.thomasfinch.dim-off"), NULL,CFNotificationSuspensionBehaviorDeliverImmediately);
	[Listener load];
}
