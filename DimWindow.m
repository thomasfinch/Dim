#import "DimWindow.h"

//DimWindow is a window over the entire screen that is colored different shades of gray to simulate dimming.
//It passes all touches through to views under it (with _ignoresHitTest)
@implementation DimWindow

- (DimWindow *)init {
	if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
	    self.backgroundColor = [UIColor blackColor];
	}
	return self;
}

- (BOOL)_ignoresHitTest {
	return YES;
}

@end
