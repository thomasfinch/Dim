#import <libactivator/libactivator.h>
#import <dlfcn.h>
#import <objc/runtime.h>
#import "substrate.h"
#import "DimController.h"

BOOL enabledBeforeScreenshot = NO;

//These hooks are used to disable Dim temporarily when a screenshot is taken
//If these weren't here, Dim would make the screenshot dark.
%hook SBScreenShotter

- (void)saveScreenshot:(BOOL)arg1 {
	enabledBeforeScreenshot = [DimController sharedInstance].enabled;
	[[DimController sharedInstance] window].hidden = YES;

	if (enabledBeforeScreenshot) {
		//Give the window a small amount of time to disappear before taking the screenshot
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			%orig;
		});
	}
	else
		%orig;
}

- (void)finishedWritingScreenshot:(id)arg1 didFinishSavingWithError:(id)arg2 context:(void *)arg3 {
	%orig;
	[[DimController sharedInstance] window].hidden = !enabledBeforeScreenshot;
}

%end

//Used to disable Dim during screenshots on 9.3+
%hook SBScreenshotManager

- (void)saveScreenshotsWithCompletion:(void (^)(void))arg1 {
	enabledBeforeScreenshot = [DimController sharedInstance].enabled;
	[[DimController sharedInstance] window].hidden = YES;

	void (^completionBlock)(void) = ^() {
		if (arg1)
			arg1();
		[[DimController sharedInstance] window].hidden = !enabledBeforeScreenshot;
	};

	if (enabledBeforeScreenshot) {
		//Give the window a small amount of time to disappear before taking the screenshot
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			%orig(completionBlock);
		});
	}
	else 
		%orig;
}

%end

//Called when any preference is changed in the settings pane
void prefsChanged() {
	[[DimController sharedInstance] updateFromPreferences];
}

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
