#import "DimWindow.h"
#import <libactivator/libactivator.h>

@interface DimController : NSObject <LAListener> {
	DimWindow *dimWindow;
	NSUserDefaults *prefs;
}

@property (nonatomic) BOOL enabled;
@property (nonatomic) float brightness;

+ (DimController*)sharedInstance;
- (void)updateFromPreferences;
- (void)showControlPanel;

@end