//
//  EZProxySettings.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/11/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "EZProxySettings.h"


@implementation EZProxySettings
@synthesize ezProxyURL;
@synthesize ezProxyUser;
@synthesize ezProxyPassword;
@synthesize proxyOnOff;
@synthesize activeBox;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.hidesBottomBarWhenPushed = YES;
	}
    return self;
}

- (void)viewDidLoad {
#ifndef __DEBUG_OUTPUT__
	[Flurry logEvent:@"EZProxySettings"];
#endif
    [super viewDidLoad];
	self.navigationItem.title = @"EZProxy Settings";

	activeBox = nil;
	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	proxyOnOff.on = [ud boolForKey:@"proxyOnOff"];
	NSString*	x = [ud stringForKey:@"ezProxyURL"];
	if(x)
		ezProxyURL.text = x;

	x = [ud stringForKey:@"ezProxyUser"];
	if(x)
		ezProxyUser.text = x;

	x = [ud stringForKey:@"ezProxyPassword"];
	if(x)
		ezProxyPassword.text = [ud stringForKey:@"ezProxyPassword"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	[ud setBool:proxyOnOff.on forKey:@"proxyOnOff"];
	[ud setValue:ezProxyURL.text forKey:@"ezProxyURL"];
	[ud setValue:ezProxyUser.text forKey:@"ezProxyUser"];
	[ud setValue:ezProxyPassword.text forKey:@"ezProxyPassword"];
	
	[ud synchronize];
} // viewWillDisappear

-(IBAction) toggleOnOff:(id)sender
{
	if(proxyOnOff.on)
	{
		BOOL		good = YES;
		NSString*	message = @"EZProxy cannot be turned on without your URL, ID and Password.";
		if(![ezProxyURL.text hasPrefix:@"http"])
		{
			message = @"Please check the URL.";
			good = NO;
		}
		else if (!(ezProxyUser.text).length)
			good = NO;
		else if (!(ezProxyPassword.text).length)
			good = NO;
		
		if(!good)
		{
			proxyOnOff.on = NO;
			UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"Error"
															message:message
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
			//•
			
		}
		
	}
} // toggleOnOff

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
	[activeBox resignFirstResponder];
	if(activeBox == ezProxyURL)
		activeBox = ezProxyUser;
	else if(activeBox == ezProxyUser)
		activeBox = ezProxyPassword;
	else if(activeBox == ezProxyPassword)
		activeBox = ezProxyURL;

	[activeBox becomeFirstResponder];
	return YES;
} // textFieldShouldReturn

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	activeBox = textField;
} // textFieldDidBeginEditing

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	activeBox = nil;
} // textFieldDidEndEditing


@end
