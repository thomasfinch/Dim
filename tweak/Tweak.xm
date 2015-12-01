#import <libactivator/libactivator.h>
#import <dlfcn.h>
#import <objc/runtime.h>
#import "substrate.h"
#import "DimController.h"

BOOL enabledBeforeScreenshot = NO;

//Called when any preference is changed in the settings pane
void prefsChanged() {
	[[DimController sharedInstance] updateFromPreferences];
}

//These hooks are used to disable Dim temporarily when a screenshot is taken
//If these weren't here, Dim would make the screenshot dark.
%hook SBScreenShotter

- (void)saveScreenshot:(_Bool)arg1 {
	enabledBeforeScreenshot = [DimController sharedInstance].enabled;
	if (enabledBeforeScreenshot) {
		MSHookIvar<UIWindow*>([DimController sharedInstance], "dimWindow").hidden = YES;
	}

	//Give the window a small amount of time to disappear before taking the screenshot
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		%orig;
	});
}

- (void)finishedWritingScreenshot:(id)arg1 didFinishSavingWithError:(id)arg2 context:(void *)arg3 {
	%orig;

	if (enabledBeforeScreenshot) {
		MSHookIvar<UIWindow*>([DimController sharedInstance], "dimWindow").hidden = NO;
	}
}

%end

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefsChanged, CFSTR("com.thomasfinch.dim-prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	[DimController sharedInstance]; //Initialize dim controller
	
	//Set up Activator listeners if it's installed
	dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
	Class la = objc_getClass("LAActivator");
	if (la) {
		[[la sharedInstance] registerListener:[DimController sharedInstance] forName:@"com.thomasfinch.dim-on"];
		[[la sharedInstance] registerListener:[DimController sharedInstance] forName:@"com.thomasfinch.dim-off"];
		[[la sharedInstance] registerListener:[DimController sharedInstance] forName:@"com.thomasfinch.dim-up"];
		[[la sharedInstance] registerListener:[DimController sharedInstance] forName:@"com.thomasfinch.dim-down"];
		[[la sharedInstance] registerListener:[DimController sharedInstance] forName:@"com.thomasfinch.dim-toggle"];
		[[la sharedInstance] registerListener:[DimController sharedInstance] forName:@"com.thomasfinch.dim-controlPanel"];
	}
}
