#import <libactivator/libactivator.h>
#import "DimController.h"

//Listens for activator events, and shows the control panel when it recieves one
@interface DimListener : NSObject <LAListener>
@end

@implementation DimListener

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	[event setHandled:YES]; // To prevent the default iOS implementation

	//Show the control panel
	UIAlertView *controlPanel = [[UIAlertView alloc] initWithTitle:@"Dim Control Panel" message:nil delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil];
	UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 100)];
	[controlPanel setValue:containerView forKey:@"accessoryView"];

	UILabel *enabledLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 15, containerView.frame.size.width, 20)];
	enabledLabel.text = @"Enabled";
	enabledLabel.font = [UIFont systemFontOfSize:16];
	[containerView addSubview:enabledLabel];

	UISwitch *enabledSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(155, 10, 30, 20)];
	enabledSwitch.on = [DimController sharedInstance].enabled;
	[enabledSwitch addTarget:self action:@selector(controlPanelSwitchChanged:) forControlEvents:UIControlEventValueChanged];
	[containerView addSubview:enabledSwitch];


	UISlider *brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(15, 65, containerView.frame.size.width-30, 30)];
	brightnessSlider.minimumValue = 0.0;
	brightnessSlider.maximumValue = 1.0;
	brightnessSlider.minimumValueImage = [UIImage imageNamed:@"Brightness.png" inBundle:[NSBundle bundleWithPath:@"/Library/PreferenceBundles/Dim.bundle"] compatibleWithTraitCollection:nil];
	brightnessSlider.value = 1 - [DimController sharedInstance].brightness;
	[brightnessSlider addTarget:self action:@selector(controlPanelSliderChanged:) forControlEvents:UIControlEventValueChanged];
	[containerView addSubview:brightnessSlider];

	[controlPanel show];
}

- (void)controlPanelSwitchChanged:(UISwitch*)enabledSwitch {
	[[DimController sharedInstance] setEnabled:enabledSwitch.on];
}

- (void)controlPanelSliderChanged:(UISlider*)slider {
	[[DimController sharedInstance] setBrightness:1-slider.value];
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

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefsChanged, CFSTR("com.thomasfinch.dim-prefschanged"), NULL,CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)dimToggleOn, CFSTR("com.thomasfinch.dim-on"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)dimToggleOff, CFSTR("com.thomasfinch.dim-off"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	[DimController sharedInstance]; //Initialize dim controller
	
	//Create the activator listener
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[LASharedActivator registerListener:[[DimListener alloc] init] forName:@"com.thomasfinch.dim-controlPanel"];
	[pool drain];
}
