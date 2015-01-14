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
    return [[objc_getClass("DimController") performSelector:@selector(sharedInstance)] performSelector:@selector(enabled)] ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier
{
    switch (newState) {
    case FSSwitchStateIndeterminate:
        break;
    case FSSwitchStateOn:
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.thomasfinch.dim-on"), NULL, NULL, true);
        break;
    case FSSwitchStateOff:
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.thomasfinch.dim-off"), NULL, NULL, true);
        break;
    }
}

//Show the control panel when the toggle is held
- (void)applyAlternateActionForSwitchIdentifier:(NSString *)switchIdentifier {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.thomasfinch.dim-controlPanel"), NULL, NULL, true);
}

@end