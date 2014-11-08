#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"

extern CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

@interface DimSwitch : NSObject <FSSwitchDataSource> {
    BOOL isOn;
}

@end

@implementation DimSwitch

- (id)init
{
    if (self = [super init]) {
        isOn = NO;
    }
    return self;
}

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
        return @"Dim";
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
    return isOn ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier
{
    switch (newState) {
    case FSSwitchStateIndeterminate:
        return;
        break;
    case FSSwitchStateOn:
        isOn = YES;
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.thomasfinch.dim-on"), NULL, NULL, true);
        break;
    case FSSwitchStateOff:
        isOn = NO;
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.thomasfinch.dim-off"), NULL, NULL, true);
        break;
    }
}

@end