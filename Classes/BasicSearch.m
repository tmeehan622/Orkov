#import "BasicSearch.h"
//
#import "Pubmed_ExperimentAppDelegate.h"

@interface BasicSearch()


@end

@implementation BasicSearch

@synthesize portraitLogo;
@synthesize landscapeLogo;
@synthesize vsbanner;
@synthesize innerView;
@synthesize tempLabel;		
@synthesize tempLabel2;
@synthesize contentView;
@synthesize ContFrameLand;
@synthesize ContFramePort;
@synthesize VShiftLandscape;
@synthesize VShiftPortrait;
@synthesize activeLogo;

-(void)setLabelVisibility
{
	//LOG(@"%s - IN",__FUNCTION__);
	UIInterfaceOrientation orient = [UIDevice currentDevice].orientation;
	UILabel *landLabel = (UILabel*)[self.view viewWithTag:101];
	UILabel *portLabel = (UILabel*)[self.view viewWithTag:100];
	
	if((orient == UIInterfaceOrientationLandscapeLeft) || (orient == UIInterfaceOrientationLandscapeRight))
	{
		landLabel.hidden = NO;
		portLabel.hidden = YES;
	}
	else 
	{
		landLabel.hidden = YES;
		portLabel.hidden = NO;
	}
	[self.view setNeedsDisplay];
	//LOG(@"%s - OUT",__FUNCTION__);
}



-(void)viewWillAppear:(BOOL)animated 
{
	//LOG(@"%s - IN",__FUNCTION__);
	[super viewWillAppear:animated];

	[self setLabelVisibility];
	
	UIInterfaceOrientation orient = [UIDevice currentDevice].orientation;

	if((orient == UIInterfaceOrientationLandscapeLeft) || (orient == UIInterfaceOrientationLandscapeRight))
	{
	//	NSLog(@"......is Landscape");
		activeLogo = landscapeLogo;
		vsbanner.hidden = YES;
		portraitLogo.alpha = 0;
		landscapeLogo.alpha = 1;
	}
	else
	{
//		NSLog(@"......is Portrait");
		activeLogo = portraitLogo;
		vsbanner.hidden = NO;
		portraitLogo.alpha = 1;
		landscapeLogo.alpha = 0;
	}
	//LOG(@"%s - OUT",__FUNCTION__);
}

- (void)viewDidLoad 
{
	//LOG(@"%s - IN",__FUNCTION__);
    [super viewDidLoad];
	
	ContFrameLand = CGRectMake(0,0,480,219);
	ContFramePort = CGRectMake(0,0,320,367);
	VShiftLandscape = 32.0;
	VShiftPortrait = 50.0;

	self.isAdvanced = NO;
	UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;

	portraitLogo.hidden = NO;
	landscapeLogo.hidden = NO;
	if(interfaceOrientation == UIInterfaceOrientationPortrait) {
		portraitLogo.alpha = 1;
		landscapeLogo.alpha = 0;
		vsbanner.hidden = NO;
		activeLogo = portraitLogo;
	} else {
		portraitLogo.alpha = 0;
		landscapeLogo.alpha = 1;
		vsbanner.hidden = NO;
		activeLogo = landscapeLogo;
	}

	[self setLabelVisibility];

//	Pubmed_ExperimentAppDelegate *appD = [[UIApplication sharedApplication] delegate];
//	[self.view insertSubview:appD.logTextView atIndex:[[self.view subviews] count]-1];
	
	//LOG(@"%s - OUT",__FUNCTION__);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	//LOG(@"%s - IN",__FUNCTION__);
	if(fromInterfaceOrientation == UIInterfaceOrientationPortrait)
	{
//		NSLog(@"......switching to Landscape");
		activeLogo = landscapeLogo;
		vsbanner.hidden = YES;
		portraitLogo.hidden = YES;
		landscapeLogo.hidden = NO;
	}
	else
	{
//		NSLog(@"......switching to Portrait");
		activeLogo = portraitLogo;
		vsbanner.hidden = NO;
		portraitLogo.hidden = NO;
		landscapeLogo.hidden = YES;
	}
	[self setLabelVisibility];

	
	//LOG(@"%s - OUT",__FUNCTION__);

} // didRotateFromInterfaceOrientation


 
-(BOOL) isLandscape
{
	UIInterfaceOrientation orient = [UIDevice currentDevice].orientation;
	
	if((orient == UIInterfaceOrientationLandscapeLeft) || (orient == UIInterfaceOrientationLandscapeRight))
		return YES;
	else 
		return NO;
}
#pragma mark Orientation support

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	//LOG(@"%s - IN",__FUNCTION__);
 	
	[UIView beginAnimations:nil context:@"logo"];
	[UIView setAnimationDuration:duration];
	activeLogo.alpha = 0;
	if(activeLogo == portraitLogo)
		landscapeLogo.alpha = 1;
	else
		portraitLogo.alpha = 1;
	[UIView commitAnimations];
	
	//LOG(@"%s - OUT",__FUNCTION__);
} // activeLogo


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


@end
