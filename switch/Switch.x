#import <Flipswitch/Flipswitch.h>
#import <objc/runtime.h>

extern CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

@interface DimSwitch : NSObject <FSSwitchDataSource>
@end

@implementation DimSwitch

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
        return @"Dim";
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
    //NSLog(@"DIM ENABLED: %d",(int)[[objc_getClass("DimController") performSelector:@selector(sharedInstance)] performSelector:@selector(enabled)]);
    return [[objc_getClass("DimController") performSelector:@selector(sharedInstance)] performSelector:@selector(enabled)] ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.thomasfinch.dim-toggle"), NULL, NULL, true);
}

//Show the control panel when the toggle is held
- (void)applyAlternateActionForSwitchIdentifier:(NSString *)switchIdentifier {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.thomasfinch.dim-controlPanel"), NULL, NULL, true);
}

@end