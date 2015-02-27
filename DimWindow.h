#import <UIKit/UIKit.h>

@interface UIWindow (Private)
- (BOOL)_ignoresHitTest;
- (void)_setSecure:(BOOL)secure;
@end

@interface DimWindow : UIWindow
@end