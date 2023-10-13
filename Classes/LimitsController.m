//
//  LimitsController.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 7/9/09.
//  Copyright 2009 The Frodis Co.. All rights reserved.
//

#import "LimitsController.h"


@implementation LimitsController
@synthesize myTable;
@synthesize cancelButton;
@synthesize segmentHeadings;
@synthesize tableValues;	// this is s stub
@synthesize cancelling;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = @"Limits";	
	cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel",@"")
													style:UIBarButtonItemStylePlain
												   target:self
												   action:@selector(cancelEnditing:)];
	
	segmentHeadings = @[@"PubMed Search History",
						@"Search by Author, Journal, Publication Date & More",
						@"Limit by Topics, Languages, and Journal Groups",
						@"Index of Fields and Field Values"];
	
	tableValues = @[@[@"My First Search"],
					@[@"Roger De Bris", @"Rat Bastardson"],
					@[@"Monkeys", @"Chi hua huas", @"Ponies", @"Unicorns"],
					@[@"Index 1", @"Index 2", @"Index 3", @"Index 4", @"Index 5"]];

	cancelling = NO;
} // viewDidLoad

- (IBAction) cancelEnditing:(id)sender
{
	cancelling = YES;
	[self.navigationController popViewControllerAnimated:YES];
} // cancelEnditing

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

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return segmentHeadings.count;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableValues[section] count];	// stub
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return segmentHeadings[section];
} // titleForHeaderInSection

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"limitCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    
	cell.textLabel.text = tableValues[indexPath.section][indexPath.row];
	//	cell.title.text = [article objectForKey:@"ArticleTitle"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
} // didSelectRowAtIndexPath

@end
