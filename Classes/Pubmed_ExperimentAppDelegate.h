#import "AboutBox.h"

@class SplashView;
@class SearchController;

@interface Pubmed_ExperimentAppDelegate : NSObject <UIApplicationDelegate,modalDelegate, UITabBarControllerDelegate> 
{
}

@property (nonatomic, strong)           UIWindow			*window;
@property (nonatomic, weak) IBOutlet	UITabBarController	*myTabBarController;
@property (nonatomic, strong)           SplashView			*splashController;
@property (nonatomic, strong)           NSTimer				*splashTimer;
@property (nonatomic, weak) IBOutlet	SearchController	*searchController;
@property (nonatomic, weak) IBOutlet	UITextView			*logTextView;

- (void) checkRegistration;

- (void) splashFade;
- (void) splashDown;
- (void) touchSplash:(NSNotification*)aNotification;
- (void) dismissmodal;
- (IBAction)dismissOptions;
@end

