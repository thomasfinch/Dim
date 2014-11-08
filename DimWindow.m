#import "DimWindow.h"

@implementation DimWindow

- (DimWindow *)init {
	self = [super initWithFrame:[UIScreen mainScreen].bounds];

	if (self) {
	    self.backgroundColor = [UIColor blackColor];
	}

	return self;
}

- (BOOL)_ignoresHitTest {
	return YES;
}

@end
