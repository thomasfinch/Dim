#import "DimWindow.h"

@interface UIWindow (private)
- (void)_setSecure:(BOOL)secure;
@end

//DimWindow is a window over the entire screen that is colored different shades of gray to simulate dimming.
//It passes all touches through to views under it (with _ignoresHitTest)
@implementation DimWindow

- (DimWindow *)init {
	if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
	    self.backgroundColor = [UIColor blackColor];

	    #ifdef __IPHONE_8_0
	    [self _setSecure:YES]; //Allows Dim on the lockscreen with a passcode (iOS 8 only)
	    #endif
	}
	return self;
}

//Prevents touches from interacting with this window
//	(we want them to go through)
- (BOOL)_ignoresHitTest {
	return YES;
}

@end
