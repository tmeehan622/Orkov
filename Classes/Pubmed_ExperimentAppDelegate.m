//
//  Pubmed_ExperimentAppDelegate.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 6/22/09.
//  Copyright The Frodis Co 2009. All rights reserved.
//

#import "Pubmed_ExperimentAppDelegate.h"
#import "SplashView.h"
#import "BasicSearch.h"
#import "BookMarksController.h"
#import "Settings.h"
#import "PDFLibraryViewController.h"
#import "Registration.h"
#import "TermsOfUse.h"
#import "Flurry.h"
#import "AboutBox.h"

@interface NSDictionary (lengthfinder)
- (int)length;
@end

@implementation NSDictionary (lengthfinder)

-(int)length {
    return 1;
}

-(int)intValue {
    return 1;
}
@end

@interface NSArray (fastencoder)
- (int)fastestEncoding;
@end

@implementation NSArray (fastencoder)

-(int)fastestEncoding {
    //NSLog(@"who's calling 2");fastestEncoding
    return 1;
}

-(int)_fastCStringContents{
    
   return 1;
}
@end

@implementation Pubmed_ExperimentAppDelegate 

@synthesize window, searchController;
@synthesize splashController, splashTimer;
@synthesize myTabBarController,logTextView;


#pragma mark -
#pragma mark Application lifecycle

-(void)dismissmodal {
   [myTabBarController.selectedViewController dismissModalViewControllerAnimated:YES]; 
}

- (IBAction)dismissOptions {
	[myTabBarController.selectedViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction) viewToggle:(id)sender {
	AboutBox    *ABView = nil;
	
	ABView = [[AboutBox alloc] initWithNibName:@"AboutBox" bundle:nil];
	ABView.controller = self;
	
	UIViewController *cvc = myTabBarController.selectedViewController;
	
	[cvc presentModalViewController:ABView animated:YES];
}

- (void) touchedAbout:(NSNotification*)notification {
	[self viewToggle:self];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchedAbout:) name:@"ABOUT_TOUCH" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchSplash:) name:@"TOUCH_SPLASH" object:nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:
	 @{@"itemsPerPage": @1,
	  @"proxyOnOff": @NO}];
	
	NSMutableArray  *controllers = [NSMutableArray array];
    UINavigationController *navController = [[UINavigationController alloc] init];
    navController.navigationBar.translucent = NO;
	navController.navigationBar.tintColor = ORKOV_TINT_COLOR;
	UIViewController *aViewController = [[BasicSearch alloc] initWithNibName:@"BasicSearch" bundle:[NSBundle mainBundle]];
	aViewController.title = @"Basic";
	aViewController.tabBarItem.image = [UIImage imageNamed:@"TabbarIcon_Search"];
    [navController pushViewController:aViewController animated:NO];
	[controllers addObject:navController];

	navController = [[UINavigationController alloc] init];
	navController.navigationBar.tintColor = ORKOV_TINT_COLOR;
    aViewController = [[SearchController alloc] initWithNibName:@"SearchController" bundle:[NSBundle mainBundle]];
	aViewController.title = @"Advanced";
	aViewController.tabBarItem.image = [UIImage imageNamed:@"TabbarIcon_SearchA"];
    [navController pushViewController:aViewController animated:NO];
	[controllers addObject:navController];
	
	navController = [[UINavigationController alloc] init];
	navController.navigationBar.tintColor = ORKOV_TINT_COLOR;
    aViewController = [[BookMarksController alloc] initWithNibName:@"BookMarksController" bundle:[NSBundle mainBundle]];
	aViewController.title = @"Favorites";
	aViewController.tabBarItem.image = [UIImage imageNamed:@"TabbarIcon_Star"];
    [navController pushViewController:aViewController animated:NO];
	[controllers addObject:navController];
		
	navController = [[UINavigationController alloc] init];
	navController.navigationBar.tintColor = ORKOV_TINT_COLOR;
    aViewController = [[PDFLibraryViewController alloc] initWithNibName:@"BookMarksController" bundle:[NSBundle mainBundle]];
	aViewController.title = @"Saved PDF";
	aViewController.tabBarItem.image = [UIImage imageNamed:@"TabbarIcon_PDF"];
    [navController pushViewController:aViewController animated:NO];
	[controllers addObject:navController];
	
	navController = [[UINavigationController alloc] init];
	navController.navigationBar.tintColor = ORKOV_TINT_COLOR;
    aViewController = [[Settings alloc] initWithNibName:@"Settings" bundle:[NSBundle mainBundle]];
	aViewController.title = @"Settings";
	aViewController.tabBarItem.image = [UIImage imageNamed:@"TabbarIcon_Settings"];
    [navController pushViewController:aViewController animated:NO];
	[controllers addObject:navController];

	[myTabBarController setViewControllers:controllers animated:NO];
	myTabBarController.delegate = self;
    myTabBarController.tabBar.translucent = NO;

	UITextView *tv = [[UITextView alloc ]initWithFrame:CGRectMake(50,50,200,100)];
	tv.font = [UIFont systemFontOfSize:8];
	tv.editable = NO;
	self.logTextView = tv;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logAdEvent:) name:@"IAD" object:nil];
    splashController = [[SplashView alloc] initWithNibName:@"SplashView" bundle:nil];
    
    // Style the navigation bar
    UIColor *navBarColor = [UIColor colorWithRed:0.58 green:0.00 blue:0.00 alpha:1.0];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UINavigationBar appearance] setBarTintColor:navBarColor];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTranslucent:NO];
    
    // Style the tab bar
    [[UITabBar appearance] setTintColor:navBarColor];
    
    // Style the toolbar
    [[UIToolbar appearance] setTintColor:navBarColor];
    
    // Style mail controller toolbar
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]] setTintColor:[UIColor whiteColor]];
    
    window.frame = [[UIScreen mainScreen] bounds];
    
    window.rootViewController = myTabBarController;
    [window makeKeyAndVisible];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"agreedToTerms"]) {
        TermsOfUse  *nextView = [[TermsOfUse alloc] initWithNibName:@"TermsOfUse" bundle:nil];
        [myTabBarController presentViewController:nextView animated:NO completion:nil];
    }
    
#ifndef __DEBUG_OUTPUT__
	[Flurry startSession:@"ULGYL17IPI8GZWHHVIBG"];
#endif
}

-(void) checkRegistration
{
	//[Registration checkRegistration];
}


-(void) logAdEvent:(NSNotification*) notification
{
	return;
	NSDictionary*	d = notification.userInfo;
	NSString *message = [NSString stringWithFormat:@"%@ - %@\n",d[@"Controller"],d[@"Action"]];
	//NSString *mText;
	
	if(logTextView.text == nil)
		logTextView.text = [NSString stringWithString:@"BEGIN\n"];

	logTextView.text = [logTextView.text stringByAppendingString:message];
	//NSLog(@"MESSAGE: %@",message);
	
}
//UITextView
					
- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
	//NSLog(@"terminate");
	[searchController saveHistory];
}

/*
#define fadeTime 0.75
- (void) splashFade
{
	[NSTimer scheduledTimerWithTimeInterval:fadeTime target:self selector:@selector(splashDown) userInfo:nil repeats:NO];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:fadeTime];
	splashController.view.alpha = 0;
	[UIView commitAnimations];
} // splashFade

- (void) splashDown
{
	myTabBarController.view.alpha = 0;
#ifndef	ORKOV_TABBED_UI
	myTabBarController.navigationBar.tintColor = ORKOV_TINT_COLOR;
#endif
	[splashController.view removeFromSuperview];
	[window addSubview:myTabBarController.view];

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:fadeTime];
	myTabBarController.view.alpha = 1;
	[UIView commitAnimations];
	
	
	if(![[NSUserDefaults standardUserDefaults] boolForKey:@"agreedToTerms"])
	{
		TermsOfUse*	nextView = [[TermsOfUse alloc] initWithNibName:@"TermsOfUse" bundle:nil];
		[myTabBarController presentModalViewController:nextView animated:NO];
	}		
} // splashDown

- (void) touchSplash:(NSNotification*)aNotification
{
	[splashTimer invalidate];
	[self splashFade];
} // touchSplash
*/


@end

