#import <Flipswitch/Flipswitch.h>

extern CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

@interface DimSwitch : NSObject <FSSwitchDataSource>
@end

@implementation DimSwitch

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
        return @"Dim";
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
    return [[[NSUserDefaults alloc] initWithSuiteName:@"com.thomasfinch.dim"] boolForKey:@"enabled"] ? FSSwitchStateOn : FSSwitchStateOff;
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

@end