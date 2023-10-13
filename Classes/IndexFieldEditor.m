//
//  IndexFieldEditor.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 7/17/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "IndexFieldEditor.h"
#import "SearchController.h"


@implementation IndexFieldEditor

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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



- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if(self.cancelled)
		return;
	
	NSString    *term = self.termBox.text;
	if(term.length == 0)
		return;
	
	NSArray         *searchFields = (self.advancedSearchOptions)[@"searchFields"];
	NSString        *field = searchFields[[self.picker selectedRowInComponent:0]];
	NSDictionary    *newInfo = @{@"term": term, @"field": field};
	
	[self.myController replaceTermField:newInfo];
} // viewWillDisappear

- (IBAction)deleteSearchTerm:(id) sender
{
	UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"Confirm"
													message:@"Are you sure you want to remove this index term?"
												   delegate:self
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"Remove", nil];
	[alert show];
	//•
} // deleteSearchTerm

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex != 0)
	{
		[self.myController removeIndexTerm:self.info];
		self.cancelled = YES;
		[self.navigationController popViewControllerAnimated:YES];
	}
	
} // alertView:clickedButtonAtIndex:

@end
