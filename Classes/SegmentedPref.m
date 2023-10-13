//
//  SegmentedPref.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/24/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "SegmentedPref.h"

@implementation SegmentedPref
@synthesize segmentedControl;
@synthesize prompt;
@synthesize segments;
@synthesize prefName;
@synthesize prefTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.hidesBottomBarWhenPushed = YES;
	}
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationItem.title = @"Settings";
	
	[segmentedControl removeAllSegments];
	int i = 0;
	for(NSString*s in segments)
		[segmentedControl insertSegmentWithTitle:s atIndex:i++ animated:NO];
	
	int index = [[NSUserDefaults standardUserDefaults] integerForKey:prefName];
	if(index > segments.count)
		index = segments.count;
	if(index < 0)
		index = 0;
	
	segmentedControl.selectedSegmentIndex = index;
	
	prompt.text = prefTitle;
} // viewDidLoad

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	int	index = segmentedControl.selectedSegmentIndex;

	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	[ud setInteger:index forKey:prefName];
	[ud synchronize];
} // viewWillDisappear


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




@end
