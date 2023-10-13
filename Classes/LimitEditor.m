//
//  LimitEditor.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 7/16/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "LimitEditor.h"
#import "SearchController.h"


@implementation LimitEditor
@synthesize myController;
@synthesize myTable;		
@synthesize infoContainer;
@synthesize info;
@synthesize index;

- (void) setInfo:(NSMutableArray*)newInfo atIndex:(int)newIndex
{
	
	
	index = newIndex;
	
	infoContainer = newInfo;
	NSDictionary*	d = infoContainer[index];
	NSArray*		a = d[@"items"];

	info = [[NSMutableArray alloc] initWithArray:a];
} // setInfo

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
	self.navigationItem.title = @"Limits";	
	myTable.backgroundColor = [UIColor clearColor];

 	UIBarButtonItem*	clearButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear",@"")
																	 style:UIBarButtonItemStylePlain
																	target:self
																	action:@selector(clearFields:)];
	
	self.navigationItem.rightBarButtonItem = clearButton;

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
	[myController replaceLimits:infoContainer];
} // viewWillDisappear


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return info.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"LimitCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
  		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
      
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    }
	
	cell.textLabel.text = info[indexPath.row][@"title"];
	cell.accessoryType = [info[indexPath.row][@"selected"] boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
   
	return cell;
} // cellForRowAtIndexPath

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableDictionary*	selectionDict = [NSMutableDictionary dictionaryWithDictionary:info[indexPath.row]];
	BOOL					selected = ![selectionDict[@"selected"] boolValue];
	selectionDict[@"selected"] = @(selected);
	info[indexPath.row] = selectionDict;
	
	NSMutableDictionary*	itemDict = [NSMutableDictionary dictionaryWithDictionary:infoContainer[index]];
	itemDict[@"items"] = info;
	
	infoContainer[index] = itemDict;
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	UITableViewCell*	cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
} // didSelectRowAtIndexPath

- (IBAction) clearFields:(id)sender
{
	int row = 0;
	NSArray*	tmpArray = [NSArray arrayWithArray:info];
	for(NSDictionary*d in tmpArray)
	{
		NSMutableDictionary*	selectionDict = [NSMutableDictionary dictionaryWithDictionary:d];
		selectionDict[@"selected"] = @NO;
		info[row++] = selectionDict;		
	} // for d
	
	NSMutableDictionary*	itemDict = [NSMutableDictionary dictionaryWithDictionary:infoContainer[index]];
	itemDict[@"items"] = info;
	
	infoContainer[index] = itemDict;
	[myTable reloadData];
	
} // clearFields

@end
