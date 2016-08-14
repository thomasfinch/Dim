#import "DimWindow.h"
#import <libactivator/libactivator.h>

@interface DimController : NSObject <LAListener> {
	NSUserDefaults *prefs;
}

@property (nonatomic) BOOL enabled;
@property (nonatomic) float brightness;

+ (DimController*)sharedInstance;
- (DimWindow*)window;
- (void)updateFromPreferences;
- (void)showControlPanel;

@end