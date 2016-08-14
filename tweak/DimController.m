#import "DimController.h"
#import <objc/runtime.h>

const CGFloat MAX_ALPHA = 0.8; //So the user can see their screen, even at max darkness

@implementation DimController

+ (DimController*)sharedInstance {
	static dispatch_once_t p = 0;
    __strong static DimController* sharedObject = nil;
    dispatch_once(&p, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

- (id)init {
	if (self = [super init]) {
		prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.thomasfinch.dim"];
		[prefs registerDefaults:@{
			@"enabled": @NO,
			@"brightness": [NSNumber numberWithFloat:0.5],
			@"alphaInterval": [NSNumber numberWithFloat:0.1],
			@"flipswitchHoldAction": [NSNumber numberWithInt:0]
		}];
	}
	return self;
}

// Used for lazy initialization of the window.
// If the window is loaded too quickly as SpringBoard is launching, it won't appear.
// Also, this fixes a bug causing a respring after using the 9.3.3 jailbreak
- (DimWindow*)window {
	static DimWindow* dimWindow = nil;
	if (!dimWindow) {
		dimWindow = [[DimWindow alloc] init];
	}
	return dimWindow;
}

- (float)alphaForBrightness:(float)b {
	return (1 - b) * MAX_ALPHA; //alpha = 1 means fully opaque (fully dark)
}

- (void)updateFromPreferences {
	[self window].hidden = ![prefs boolForKey:@"enabled"];
	[self window].alpha = [self alphaForBrightness:[prefs floatForKey:@"brightness"]];
}

- (void)setEnabled:(BOOL)e {
	[self window].hidden = !e;
	[prefs setBool:e forKey:@"enabled"];
}

- (BOOL)enabled {
	return ![self window].hidden;
}

- (void)setBrightness:(float)b {
	if (b > 1)
		b = 1;
	else if (b < 0)
		b = 0;

	[self window].alpha = [self alphaForBrightness:b];
	[prefs setFloat:b forKey:@"brightness"];
}

- (float)brightness {
	return 1 - ([self window].alpha / MAX_ALPHA);
}

- (void)showControlPanel {
	UIAlertView *controlPanel = [[UIAlertView alloc] initWithTitle:@"Dim Control Panel" message:nil delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil];
	UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 100)];
	[controlPanel setValue:containerView forKey:@"accessoryView"];

	UILabel *enabledLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 15, containerView.frame.size.width, 20)];
	enabledLabel.text = @"Enabled";
	enabledLabel.font = [UIFont systemFontOfSize:16];
	[containerView addSubview:enabledLabel];

	UISwitch *enabledSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(155, 10, 30, 20)];
	enabledSwitch.on = self.enabled;
	[enabledSwitch addTarget:self action:@selector(controlPanelSwitchChanged:) forControlEvents:UIControlEventValueChanged];
	[containerView addSubview:enabledSwitch];

	UISlider *brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(15, 65, containerView.frame.size.width-30, 30)];
	brightnessSlider.minimumValue = 0.0;
	brightnessSlider.maximumValue = 1.0;
	brightnessSlider.minimumValueImage = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/Dim.bundle/Brightness.png"];
	brightnessSlider.value = self.brightness;
	[brightnessSlider addTarget:self action:@selector(controlPanelSliderChanged:) forControlEvents:UIControlEventValueChanged];
	[containerView addSubview:brightnessSlider];

	[controlPanel show];
}

- (void)controlPanelSwitchChanged:(UISwitch*)enableSwitch {
	self.enabled = enableSwitch.on;
}

- (void)controlPanelSliderChanged:(UISlider*)slider {
	self.brightness = slider.value;
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	[event setHandled:YES]; // To prevent the default iOS action

	NSString *eventName = [activator assignedListenerNameForEvent:event];

	if ([eventName isEqualToString:@"com.thomasfinch.dim-on"]) {
		self.enabled = YES;
	}
	else if ([eventName isEqualToString:@"com.thomasfinch.dim-off"]) {
		self.enabled = NO;
	}
	else if ([eventName isEqualToString:@"com.thomasfinch.dim-up"]) {
		float newBrightness = self.brightness + [prefs floatForKey:@"alphaInterval"];
		if (newBrightness > 1)
			newBrightness = 1;
		self.brightness = newBrightness;
	}
	else if ([eventName isEqualToString:@"com.thomasfinch.dim-down"]) {
		float newBrightness = self.brightness - [prefs floatForKey:@"alphaInterval"];
		if (newBrightness < 0)
			newBrightness = 0;
		self.brightness = newBrightness;
	}
	else if ([eventName isEqualToString:@"com.thomasfinch.dim-toggle"]) {
		self.enabled = !self.enabled;
	}
	else if ([eventName isEqualToString:@"com.thomasfinch.dim-controlPanel"]) {
		[self showControlPanel];
	}
	else {
		[event setHandled:NO];
	}
}

@end