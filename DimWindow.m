#import "DimWindow.h"

//DimWindow is a window over the entire screen that is colored different shades of gray to simulate dimming.
//It passes all touches through to views under it (with _ignoresHitTest)
@implementation DimWindow

- (DimWindow *)init {
	if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
	    self.backgroundColor = [UIColor blackColor];

	    if ([self respondsToSelector:@selector(_setSecure:)])
	    	[self _setSecure:YES]; //Allows Dim on the lockscreen when a passcode is set (iOS 8 only)
	}
	return self;
}

//Prevents touches from interacting with this window
//	(we want them to go through)
- (BOOL)_ignoresHitTest {
	return YES;
}

@end
