#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>

@interface DimListController: PSListController
@end

@implementation DimListController

-(void)TFTwitterButtonTapped {
	UIApplication *app = [UIApplication sharedApplication];
	NSURL *tweetbot = [NSURL URLWithString:@"tweetbot:///user_profile/tomf64"];
	if ([app canOpenURL:tweetbot])
		[app openURL:tweetbot options:@{} completionHandler:nil];
	else {
		NSURL *twitterapp = [NSURL URLWithString:@"twitter:///user?screen_name=tomf64"];
		if ([app canOpenURL:twitterapp])
			[app openURL:twitterapp  options:@{} completionHandler:nil];
		else {
			NSURL *twitterweb = [NSURL URLWithString:@"http://twitter.com/tomf64"];
			[app openURL:twitterweb  options:@{} completionHandler:nil];
		}
	}
}

-(void)GithubButtonTapped {
	NSURL *githubURL = [NSURL URLWithString:@"https://github.com/thomasfinch/Dim"];
	[[UIApplication sharedApplication] openURL:githubURL  options:@{} completionHandler:nil];
}

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Dim" target:self] retain];
	}
	return _specifiers;
}

@end
