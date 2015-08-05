#import <libactivator/libactivator.h>
#include <dlfcn.h>
#import <objc/runtime.h>
#import "DimController.h"

//Called when any preference is changed in the settings pane
void prefsChanged() {
	[[DimController sharedInstance] updateFromPreferences];
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
