#import <UIKit/UIKit.h>

#ifdef DEBUG
	#define DimLog(fmt, ...) NSLog((@"[Dim] %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
	#define DimLog(fmt, ...)
#endif

@interface UIWindow (Private)
	// UIView *_exclusiveTouchView;
+ (id)keyWindow;
+ (id)allWindowsIncludingInternalWindows:(BOOL)arg1 onlyVisibleWindows:(BOOL)arg2;
+ (id)allWindowsIncludingInternalWindows:(BOOL)arg1 onlyVisibleWindows:(BOOL)arg2 forScreen:(id)arg3;
- (BOOL)_ignoresHitTest;
@end

@interface DimWindow : UIWindow
@end