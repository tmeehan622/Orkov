//
//  SearchFieldEditor.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 7/16/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "SearchFieldEditor.h"
#import "SearchController.h"

@implementation SearchFieldEditor
@synthesize picker;
@synthesize termBox;
@synthesize removeButton;
@synthesize addingNewTerm;
@synthesize cancelled;
@synthesize pickerTop;
@synthesize advancedSearchOptions;
@synthesize info;
@synthesize myController;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad
{
	[super viewDidLoad];
	
 	UIBarButtonItem*	cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel",@"")
													style:UIBarButtonItemStylePlain
												   target:self
												   action:@selector(cancelEnditing:)];
	
	self.navigationItem.rightBarButtonItem = cancelButton;
	
	UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
	if(interfaceOrientation != UIInterfaceOrientationPortrait)
		pickerTop = 50;
	else
		pickerTop = 106;
		
	CGRect r = picker.frame;
	r.origin.y = pickerTop;
	picker.frame = r;

	advancedSearchOptions = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"advancedSearchOptions" ofType:@"plist"]];
	NSArray*	searchFields = advancedSearchOptions[@"searchFields"];
#ifdef __DEBUG_OUTPUT__
	NSString*	searchField = @"Author";
#else
	NSString*	searchField = @"All Fields";
#endif
	cancelled = NO;
	addingNewTerm = (info == nil);
	removeButton.hidden = addingNewTerm;
	
	if(info)
	{
		NSString*	s = info[@"term"];
		if(s)
			termBox.text =  s;
		
		searchField = info[@"field"];
	}
#ifdef __DEBUG_OUTPUT__
	else
		termBox.text = @"George";
#endif

	int index = 0;
	for(NSDictionary*d in searchFields)
	{
		if([d[@"description"] isEqualToString:searchField])
		{
			[picker selectRow:index inComponent:0 animated:YES];
			break;
		}
		index++;
	}
} // viewDidLoad

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if(fromInterfaceOrientation == UIInterfaceOrientationPortrait)
		pickerTop = 50;
	else
		pickerTop = 106;
	
	CGRect r = picker.frame;
	r.origin.y = pickerTop;
	picker.frame = r;
	
} // didRotateFromInterfaceOrientation

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



- (IBAction) cancelEnditing:(id)sender
{
	cancelled = YES;
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if(cancelled)
		return;
	
	NSString*	term = termBox.text;
	if(term.length == 0)
		return;
	
	NSArray*		searchFields = advancedSearchOptions[@"searchFields"];
	NSDictionary*	xTerm = searchFields[[picker selectedRowInComponent:0]];
	NSString*		field = xTerm[@"description"];
	NSString*		tag = xTerm[@"tag"];
	
	NSDictionary*	newInfo = @{@"term": term, @"field": field, @"tag": tag};
	if(addingNewTerm)
		[myController addSearchField:newInfo];
	else
		[myController replaceSearchField:info with:newInfo];
} // viewWillDisappear

- (IBAction)deleteSearchTerm:(id) sender
{
	UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"Confirm"
											message:@"Are you sure you want to remove this search term?"
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
		[myController removeTerm:info];
		cancelled = YES;
		[self.navigationController popViewControllerAnimated:YES];
	}
	
} // alertView:clickedButtonAtIndex:

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
} // numberOfComponentsInPickerView

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [advancedSearchOptions[@"searchFields"] count];
} // numberOfRowsInComponent

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return advancedSearchOptions[@"searchFields"][row][@"description"];
} // titleForRow

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
	[textField resignFirstResponder];
	return YES;
} // textFieldShouldReturn

@end
