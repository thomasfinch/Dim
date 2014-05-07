#import "DimWindow.h"

@implementation DimWindow

- (DimWindow *)init {
	self = [super initWithFrame:[UIScreen mainScreen].bounds];

	if (self) {
	    self.backgroundColor = [UIColor blackColor];
	}

	return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	return nil;
}

// - (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//	 return NO;
// }

- (BOOL)_ignoresHitTest {
	return NO;
}

@end
