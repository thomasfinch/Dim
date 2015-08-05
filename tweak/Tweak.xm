#import <libactivator/libactivator.h>
#include <dlfcn.h>
#import <objc/runtime.h>
#import "DimController.h"

//Called when any preference is changed in the settings app
void prefsChanged() {
	[[DimController sharedInstance] updateFromPreferences];
}

//Called by the flipswitch toggle
void dimToggleOff(){
	[DimController sharedInstance].enabled = NO;
}

//Called by the flipswitch toggle
void dimToggleOn() {
	[DimController sharedInstance].enabled = YES;
}

void dimToggleOnOff() {
	[DimController sharedInstance].enabled = ![DimController sharedInstance].enabled;
}

//Called by the flipswitch toggle on long hold
void dimShowControlCenter() {
	[[DimController sharedInstance] showControlPanel];
}

// //These hooks are used to disable Dim temporarily when a screenshot is taken
// //If these weren't here, Dim would make the screenshot dark.
// %hook SBScreenShotter

// - (void)saveScreenshot:(_Bool)arg1 {
// 	[UIView animateWithDuration:0 animations:^{
// 		MSHookIvar<UIWindow*>([DimController sharedInstance], "dimOverlay").hidden = YES;
// 	} completion:^(BOOL finished){
// 		%orig;
// 	}];
// }

// - (void)finishedWritingScreenshot:(id)arg1 didFinishSavingWithError:(id)arg2 context:(void *)arg3 {
// 	%orig;
// 	if ([DimController sharedInstance].enabled)
// 		MSHookIvar<UIWindow*>([DimController sharedInstance], "dimOverlay").hidden = NO;
// }

// %end

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefsChanged, CFSTR("com.thomasfinch.dim-prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)dimToggleOn, CFSTR("com.thomasfinch.dim-on"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)dimToggleOff, CFSTR("com.thomasfinch.dim-off"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)dimToggleOnOff, CFSTR("com.thomasfinch.dim-toggle"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)dimShowControlCenter, CFSTR("com.thomasfinch.dim-controlPanel"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	[DimController sharedInstance]; //Initialize dim controller
	
	//Set up ativator listeners if it's installed
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
