//
//  AboutBox.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/24/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "AboutBox.h"


@implementation AboutBox
@synthesize modal,controller,tv;

-(IBAction)done:(id)sender
{
	
	[controller dismissOptions];	
	
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.hidesBottomBarWhenPushed = YES;
	}
    return self;
}

- (void)viewDidLoad {
#ifndef __DEBUG_OUTPUT__
	[Flurry logEvent:@"AboutBox"];
#endif
	[super viewDidLoad];
	self.navigationItem.title = @"About Orkov";
	[NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(done:)userInfo:nil repeats:NO];

}

@end

