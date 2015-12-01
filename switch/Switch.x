#import <Flipswitch/Flipswitch.h>

@interface DimController : NSObject
@property (nonatomic) BOOL enabled;
+ (DimController*)sharedInstance;
- (void)showControlPanel;
@end


@interface DimSwitch : NSObject <FSSwitchDataSource>
@end

@implementation DimSwitch

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
	return @"Dim";
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
	return [%c(DimController) sharedInstance].enabled ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
	[%c(DimController) sharedInstance].enabled = ![%c(DimController) sharedInstance].enabled;
}

//Show the control panel or go to preferences when the toggle is held
- (void)applyAlternateActionForSwitchIdentifier:(NSString *)switchIdentifier {
	if ([[[NSUserDefaults alloc] initWithSuiteName:@"com.thomasfinch.dim"] integerForKey:@"flipswitchHoldAction"] == 0)
		[[%c(DimController) sharedInstance] showControlPanel];
	else
	    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Dim"]];
}

@end