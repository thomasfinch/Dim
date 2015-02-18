#import "DimWindow.h"

@interface DimController : NSObject {
	DimWindow *dimOverlay;
	NSUserDefaults *prefs;
	NSTimer *disableTimer;
}

@property (nonatomic) BOOL enabled;
@property (nonatomic) CGFloat brightness;
@property (nonatomic) CGFloat alphaInterval;
@property (nonatomic) BOOL prefsChangedFromSettings;

+ (DimController*)sharedInstance;
- (void)updateSettings;
- (void)setEnabled:(BOOL)enabled;
- (void)setBrightness:(CGFloat)brightness;
- (void)showControlPanel;

@end