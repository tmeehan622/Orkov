//
//  History.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/25/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "History.h"
#import "SearchController.h"


@implementation History
@synthesize history, delegate, myTable, recordIndex;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.history = @[];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = @"Search History";
	
	UIBarButtonItem*	clearButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear",@"")
													style:UIBarButtonItemStylePlain
												   target:self
												   action:@selector(clearHistory:)];
	
	self.navigationItem.rightBarButtonItem = clearButton;
	myTable.backgroundColor = [UIColor clearColor];
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



- (IBAction)clearHistory:(id) sender
{
	UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"Confirm"
													message:@"Are you sure you want to clear the history?"
												   delegate:self
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"Yes", nil];
	[alert show];
	//•
} // deleteSearchTerm

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex != 0)
	{
		[delegate clearHistory];
		[self.navigationController popViewControllerAnimated:YES];
	}
	
} // alertView:clickedButtonAtIndex:

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return history.count;	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"HistoryCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
 		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    
	cell.textLabel.text = history[indexPath.row][@"text"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	delegate.historySearchIndex = indexPath.row;
	recordIndex = indexPath.row;
	[self.navigationController popViewControllerAnimated:NO];	
} // didSelectRowAtIndexPath


@end
