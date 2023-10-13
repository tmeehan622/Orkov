//
//  RelatedResults.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/12/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "RelatedResults.h"
#import "QueryAgent.h"
#import "GenericParser.h"


@implementation RelatedResults
@synthesize relatedList;
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



-(void)searchForRelated:(NSString*)term
{
	self.searchTerm = term;
	[self _searchRelated];
} // searchFor

-(void)_searchRelated
{
	[self disableNavigation:YES];
	self.noHits.hidden = YES;
	self.searchListView.alpha = 0.4;
	
	QueryAgent*	pubmedQuery = [[QueryAgent alloc] initForDB:self.dbName];
	pubmedQuery.retstart = 0;
	pubmedQuery.retmax = self.recordsPerPage;
	[pubmedQuery fetchRelated:@[self.searchTerm] usingDelegate:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getRelatedResults:) name:@"PUBMED_RELATED_COMPLETE" object:pubmedQuery];
} //_search

-(void)_search
{
	[self disableNavigation:YES];
	self.noHits.hidden = YES;
	self.searchListView.alpha = 0.4;
	
	int start = (self.startingRecordNumber).intValue-1;
	int end = start + self.recordsPerPage;
	if(end >= (self.totalRecordNumber).intValue)
		end = (self.totalRecordNumber).intValue -1;
	int count = end - start;
	
	self.endingRecordNumber = @(end);
	
	NSArray* ids = [relatedList subarrayWithRange:NSMakeRange(start, count)];
	
	QueryAgent*	xAgent = [[QueryAgent alloc] initForDB:self.dbName];
	[xAgent fetchIDs:ids usingDelegate:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFetchResults:) name:@"PUBMED_FETCH_COMPLETE" object:xAgent];
	
	self.statsText = [NSString stringWithFormat:@"Displaying records\n%@ to %@ of %@", 
					  [self.decimalFormatter stringFromNumber:self.startingRecordNumber], 
					  [self.decimalFormatter stringFromNumber:self.endingRecordNumber], 
					  [self.decimalFormatter stringFromNumber:self.totalRecordNumber]];
	
	self.statsLabel.text = self.statsText;
	
	[self adjustToobar];
} //_search


-(void) getRelatedResults:(NSNotification*)notification
{
	NSDictionary*	tResults = notification.userInfo;
	[self _getRelatedResults:tResults];
} // getRelatedResults

-(void) _getRelatedResults:(NSDictionary*)tResults
{
	self.searchResults = tResults;
	
	//NSArray*		relatedIDs = [tResults objectAtPath:@"LinkSet/LinkSetDb/Link"];
    NSArray *relatedIDs = tResults[@"LinkSet"][@"LinkSetDb"][0][@"Link"];
	NSDictionary*	linkset = relatedIDs[0];
	NSArray*		linksetArray = linkset[@"Link"];
	//	NSDictionary*	baz = [linksetArray objectAtIndex:0];
	NSMutableArray* finalLinkIDsArray = [NSMutableArray arrayWithCapacity:linksetArray.count];
	
	//for(NSDictionary*d in relatedIDs) //linksetArray)
    for(NSDictionary*d in relatedIDs)
	{
		NSString* thisID = d[@"Id"];
//        NSString *thisID = d[@"Link"][@"Id"];
		if(self.searchTerm && [self.searchTerm isEqualToString:thisID])
		{
#ifdef __DEBUG_OUTPUT__
			NSLog(@"Discarded related article (%@) because it is this one %@", thisID, self.searchTerm);
#endif
			continue;
		}
		
		[finalLinkIDsArray addObject:thisID];
	}
	
	self.relatedList = finalLinkIDsArray;
	
	
	self.totalRecordNumber = [NSNumber numberWithInt:finalLinkIDsArray.count];
	self.startingRecordNumber = @1;
	
	
	if(finalLinkIDsArray.count < self.recordsPerPage)
		self.endingRecordNumber = [NSNumber numberWithInt:(self.startingRecordNumber).intValue + finalLinkIDsArray.count];
	
	if((self.totalRecordNumber).intValue == 0)
	{
		self.startingRecordNumber = @0;
		self.endingRecordNumber = @0;
		self.totalRecordNumber = @0;
		
		UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"Search Results"
														message:@"No items found."
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		//•
		self.busy.hidden = YES;
		self.navigationItem.hidesBackButton = NO;
		return;
	}
	
	int start = (self.startingRecordNumber).intValue-1;
	int end = start + self.recordsPerPage;
	if(end > (self.totalRecordNumber).intValue)
		end = (self.totalRecordNumber).intValue;
	
	int count = end - start;
	self.endingRecordNumber = @(end);
	
	NSArray* ids = [relatedList subarrayWithRange:NSMakeRange(start, count)];

	QueryAgent*	xAgent = [[QueryAgent alloc] initForDB:self.dbName];
	[xAgent fetchIDs:ids usingDelegate:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFetchResults:) name:@"PUBMED_FETCH_COMPLETE" object:xAgent];

	self.statsText = [NSString stringWithFormat:@"Displaying records\n%@ to %@ of %@", 
					  [self.decimalFormatter stringFromNumber:self.startingRecordNumber], 
					  [self.decimalFormatter stringFromNumber:self.endingRecordNumber], 
					  [self.decimalFormatter stringFromNumber:self.totalRecordNumber]];
	
	self.statsLabel.text = self.statsText;
	
	[self adjustToobar];
} // getRelatedResults

@end
