#import <UIKit/UIKit.h>

@interface UIWindow (Private)
+ (id)keyWindow;
+ (id)allWindowsIncludingInternalWindows:(BOOL)arg1 onlyVisibleWindows:(BOOL)arg2;
+ (id)allWindowsIncludingInternalWindows:(BOOL)arg1 onlyVisibleWindows:(BOOL)arg2 forScreen:(id)arg3;
- (BOOL)_ignoresHitTest;
@end

@interface DimWindow : UIWindow
@end