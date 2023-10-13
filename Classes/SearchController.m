//
//  SearchController.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 7/9/09.
//  Copyright 2009 The Frodis Co.. All rights reserved.
//

#import "SearchController.h"
#import "ResultsController.h"
#import "LimitsController.h"
#import "IndexFieldEditor.h"
#import "LimitEditor.h"
#import "TextEditCell.h"
#import "BookMarksController.h"
#import "Settings.h"
#import "History.h"
//#import "Registration.h"

enum {kAllFields, kSearchHistory, kSearchFields, kLimits, kIndices};
@implementation SearchController
@synthesize advancedView;
@synthesize advancedViewContainer;
@synthesize searchBox;
@synthesize utilityBox;
@synthesize shouldSearch;	
@synthesize isEditingWithPicker;
@synthesize weAreANDingTerms;
@synthesize historySearchIndex;
@synthesize isAdvanced;
@synthesize segmentHeadings;
@synthesize cancelButton;
@synthesize searchButton;
@synthesize advancedSearchOptions;
@synthesize allFields;
@synthesize searchHistory;
@synthesize limitFields;
@synthesize searchFields;
@synthesize indexField;
@synthesize andOrAlert;
@synthesize activeBox,contentView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
    {
		advancedSearchOptions = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"advancedSearchOptions" ofType:@"plist"]];
        
		limitFields = [[NSMutableArray alloc] initWithArray:advancedSearchOptions[@"limits"]];
        
		searchFields = [NSMutableArray array];
		indexField = nil;

		[self loadHistory];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addToHistoryListner:) name:@"ADD_HISTORY" object:nil];
       // Custom initialization
    }
    return self;
}

- (void) clearHistory
{
	[searchHistory removeAllObjects];
	[self saveHistory];
#ifndef __DEBUG_OUTPUT__
	[Flurry logEvent:@"clearHistory"];
#endif
} // clearHistory

- (void) adjustNavBar
{
	if(isAdvanced && (allFields.length || searchFields.count))
		self.navigationItem.rightBarButtonItem = searchButton;
	else if (!isAdvanced && (searchBox.text).length)
		self.navigationItem.rightBarButtonItem = searchButton;		
	else
		self.navigationItem.rightBarButtonItem = nil;
		
} // adjustNavBar

- (void)viewDidLoad {
 	//LOG(@"%s - IN",__FUNCTION__);
   [super viewDidLoad];
	
    isAdvanced = YES;
	historySearchIndex = -1;
	advancedView.hidden = YES;
	weAreANDingTerms = YES;
	self.allFields = @"";
	
	self.navigationItem.title = @"PubMed Search Authority";

	cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel",@"")
													style:UIBarButtonItemStylePlain
												   target:self
												   action:@selector(cancelEnditing:)];
	
	searchButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Search",@"")
													style:UIBarButtonItemStylePlain
												   target:self
												   action:@selector(doAdvancedSearch:)];
	
	segmentHeadings = @[@"Search All Fields for this term",
						@"PubMed Search History",
						@"Search by Author, Journal, Publication Date & More",
						@"Limit by Topics, Languages, and Journal Groups"];

//	advancedView.backgroundColor = ORKOV_BG_COLOR;
	advancedView.backgroundColor = [UIColor clearColor];
	//LOG(@"%s - OUT",__FUNCTION__);
	
} // viewDidLoad

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisAppear:(BOOL)animated {
	
	[super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
 	//LOG(@"%s - IN",__FUNCTION__);
   [super viewDidAppear:animated];
	
#ifndef __DEBUG_OUTPUT__
	[Flurry logEvent:@"Search View Open"];
#endif
	advancedView.hidden = !isAdvanced;

	if(isAdvanced)
		[advancedView reloadData];
	
	[self adjustNavBar];
	
	if(historySearchIndex >= 0)
		[self doHistorySearch:historySearchIndex];
	
	historySearchIndex = -1;
	//LOG(@"%s - OUT",__FUNCTION__);
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


- (void) addToHistory:(NSDictionary*)searchDictionary
{
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ADD_HISTORY"
																						 object:self
																					   userInfo:searchDictionary]];
} // addToHistory

- (void) addToHistoryListner:(NSNotification*)notification
{
	[self _addToHistory:notification.userInfo];
} // addToHistoryListner

- (void) _addToHistory:(NSDictionary*)searchDictionary
{
	if(searchHistory.count > 10)
		[searchHistory removeLastObject];
	
	[searchHistory insertObject:searchDictionary atIndex:0];		// put it on top
	[self saveHistory];
} // addToHistory

- (void) loadHistory
{
	searchHistory = [NSMutableArray array];
	NSArray*	savedHistory = [[NSUserDefaults standardUserDefaults] objectForKey:@"history"];
	if(savedHistory)
		[searchHistory addObjectsFromArray:savedHistory];
} // loadHistory

- (void) saveHistory
{
	[[NSUserDefaults standardUserDefaults] setObject:searchHistory forKey:@"history"];
	[[NSUserDefaults standardUserDefaults] synchronize];
} // saveHistory

#pragma mark text view methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	activeBox = textField;
	self.navigationItem.rightBarButtonItem = cancelButton;
} // textFieldDidBeginEditing

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
	if(activeBox == searchBox)
		shouldSearch = YES;
	else		// all fields
	{
		self.allFields = textField.text;
		shouldSearch = NO;
	}
	[textField resignFirstResponder];
	[self adjustNavBar];
	
	return YES;
} // textFieldShouldReturn

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if(shouldSearch)
		[self doBasicSearch:self];
	
	self.allFields = textField.text;
	activeBox = nil;
} // textFieldDidEndEditing

- (IBAction) cancelEnditing:(id)sender
{
	self.navigationItem.rightBarButtonItem = nil;
	[activeBox resignFirstResponder];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.50];
	shouldSearch = NO;
	[UIView commitAnimations];
	activeBox = nil;
} // cancelEnditing

-(void)doHistorySearch:(int)row
{
#ifndef __DEBUG_OUTPUT__
	[Flurry logEvent:@"doHistorySearch"];
#endif
	ResultsController*	aViewController = [[ResultsController alloc] initWithNibName:@"ResultsController" bundle:nil];
	[self.navigationController pushViewController:aViewController animated:YES];
	NSDictionary*	savedSearch = searchHistory[row];
	NSString*	searchCriteria = savedSearch[@"searchTerms"];
	[aViewController searchFor:searchCriteria];
} // doHistorySearch



-(IBAction)doBasicSearch:(id)sender
{
#ifndef __DEBUG_OUTPUT__
	[Flurry logEvent:@"doBasicSearch"];
#endif
	//LOG(@"%s - IN",__FUNCTION__);
	
    NSString*	searchTerm = searchBox.text;
	if(![self screenSearch:searchTerm])
	{
		UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:@"Please check your search term"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		//•
		return;
	}
	
	ResultsController   *aViewController = [[ResultsController alloc] initWithNibName:@"ResultsController" bundle:nil];
	[self.navigationController pushViewController:aViewController animated:YES];
	[aViewController searchFor:searchTerm];
	[self addToHistory:@{@"text": [NSString stringWithFormat:@"Search: %@", searchTerm], @"searchTerms": searchTerm}];

    //LOG(@"%s - OUT",__FUNCTION__);
	
} // doMySearch

- (IBAction) doAdvancedSearch:(id)sender
{
#ifndef __DEBUG_OUTPUT__
	[Flurry logEvent:@"doAdvancedSearch"];
#endif
	NSString    *searchCriteria = [self assembleAdvancedSearchCriteria];
    
	if(![self screenSearch:searchCriteria] && ![self screenSearch:allFields]) {
		UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:@"Please check your search term"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		//•
		return;
	}
	
	
	ResultsController*	aViewController = [[ResultsController alloc] initWithNibName:@"ResultsController" bundle:nil];
	[self.navigationController pushViewController:aViewController animated:YES];
	[aViewController searchFor:searchCriteria];
} // doAdvancedSearch

-(BOOL) screenSearch:(NSString*)searchString
{
	//LOG(@"%s - IN",__FUNCTION__);
	NSString*	testString = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
	testString = [testString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	//LOG(@"%s - OUT",__FUNCTION__);
	if(testString.length)
		return YES;
	
	return NO;
} // screenSearch

- (IBAction) doSettings:(id)sender
{
#ifndef __DEBUG_OUTPUT__
	[Flurry logEvent:@"Settings"];
#endif
	Settings*	aViewController = [[Settings alloc] initWithNibName:@"Settings" bundle:nil];
	[self.navigationController pushViewController:aViewController animated:YES];
} // doSettings

- (NSString*) groupTheseTogether:(NSArray*)tags withType:(NSString*)type operation:(NSString*)operation
{
	//LOG(@"%s - IN",__FUNCTION__);
	NSArray*	tmpArray = @[];
	
	for(NSString* tag in tags)
		tmpArray = [tmpArray arrayByAddingObject:[NSString stringWithFormat:@"%@[%@]",tag, type]];

	NSString*	returnString = [NSString stringWithFormat:@"(%@)", [tmpArray componentsJoinedByString:operation]];
	//LOG(@"%s - OUT",__FUNCTION__);

	return returnString;
} // groupTheseTogether

- (NSString*) assembleAdvancedSearchCriteria
{
	NSArray*		tmpTerms = @[];
	NSArray*		searchTextArray = @[];
	//LOG(@"%s - IN",__FUNCTION__);
	
// first handle the search terms & the all fields box
	if(allFields && allFields.length)
		searchTextArray = [searchTextArray arrayByAddingObject:allFields];
	
	for(NSDictionary*searchD in searchFields)
	{
		tmpTerms = [tmpTerms arrayByAddingObject:[NSString stringWithFormat:@"%@[%@]", searchD[@"term"], searchD[@"tag"]]];
		searchTextArray = [searchTextArray arrayByAddingObject:[NSString stringWithFormat:@"%@[%@]", searchD[@"term"], searchD[@"field"]]];
	}
	NSString*		searchTerms = [tmpTerms componentsJoinedByString:weAreANDingTerms ? @"+AND+" : @"+OR+"];

// to do an advanced search we need to have, at least, a search term OR an all fields term
	if(searchTerms.length)
	{
		if(allFields && allFields.length)
			searchTerms = [NSString stringWithFormat:@"%@[All+Fields]+AND+%@", allFields, searchTerms];
	}
	else
		searchTerms = allFields;
	
	// now string the limits together
// each group's members are OR'ed together
// All the groups are AND'ed together
// We also want to assemble a human readable seach description we can use
// with the actual search string as a dictionary we can use for search history
	
	NSArray*		groupArray = @[];

	for(NSDictionary*groupD in limitFields)
	{
		NSString*	globalType = groupD[@"type"];
		NSString*	title = groupD[@"title"];
		BOOL		languageGroup = [title.uppercaseString isEqualToString:@"LANGUAGES"];
		BOOL		pubGroup = [title.uppercaseString isEqualToString:@"TYPE OF ARTICLE"];
		NSString*	groupOP = groupD[@"groupOP"];
		
		if(groupOP == nil)	// most groups are OR'ed but some are AND'ed
			groupOP = @"OR";
		
		groupOP = [NSString stringWithFormat:@"+%@+", groupOP];
		
		NSArray*	termArray = @[];

		for(NSDictionary*itemD in groupD[@"items"])
		{
			BOOL selected = [itemD[@"selected"] boolValue];
			if(!selected)
				continue;

			searchTextArray = [searchTextArray arrayByAddingObject:itemD[@"title"]];

			NSString*	tag = itemD[@"tag"];
			NSString*	type = itemD[@"type"];			// some may override global type
			if(type == nil)
				type = globalType;

			if(languageGroup || pubGroup)
				tag = [itemD[@"title"] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
			
			if([tag isKindOfClass:[NSArray class]])
				termArray = [termArray arrayByAddingObject:[self groupTheseTogether:(NSArray*)tag withType:type operation:@"+OR+"]];
			else
				termArray = [termArray arrayByAddingObject:[NSString stringWithFormat:@"%@[%@]", tag, type]];
		} // inside group loop
		NSString* thisGroupsTerms;
		if(termArray.count == 0)
			continue;
		if(termArray.count == 1)
			thisGroupsTerms = termArray[0];
		else
			thisGroupsTerms = [NSString stringWithFormat:@"(%@)", [termArray componentsJoinedByString:groupOP]];
		
		groupArray = [groupArray arrayByAddingObject:thisGroupsTerms];
	} // outside group loop
		
	NSString*	limitTerms;
	
	switch (groupArray.count) {
		case 0:
			limitTerms = @"";
			break;

		case 1:
			limitTerms = groupArray[0];
			break;

		default:
			limitTerms = [groupArray componentsJoinedByString:@"+AND+"];
			break;
	}
	
	if(groupArray.count)
		searchTerms = [searchTerms stringByAppendingFormat:@"+AND+%@",limitTerms];
	
	
	NSString*	searchHistoryText = [NSString stringWithFormat:@"Search: %@", [searchTextArray componentsJoinedByString:@", "]];
	[self addToHistory:
	 @{@"searchTerms": searchTerms, 
	  @"allFields": [allFields copy], 
	  @"searchFields": [searchFields  copy], 
	  @"limitFields": [limitFields copy], 
	  @"text": searchHistoryText}];
#ifdef __DEBUG_OUTPUT__
	NSLog(@"searchTerms is: %@",searchTerms);
#endif
	//LOG(@"%s - OUT",__FUNCTION__);
	return searchTerms;
	
} // assembleAdvancedSearchCriteria

#pragma mark Add Field methods

- (void) addSearchField:(NSDictionary*)info
{
	[searchFields addObject:info];
	[advancedView reloadData];
} // addSearchField

- (void) replaceSearchField:(NSDictionary*)oldInfo with:(NSDictionary*)newInfo
{
	searchFields[[searchFields indexOfObject:oldInfo]] = newInfo;
	[advancedView reloadData];
	
} // requestNewSearchField

- (void) removeTerm:(NSDictionary*)oldInfo
{
	[searchFields removeObject:oldInfo];
	[advancedView reloadData];
	
} // removeTerm

- (void) removeIndexTerm:(NSDictionary*)oldInfo
{
	
	indexField = nil;
	[advancedView reloadData];
} // removeIndexTerm

- (void) replaceTermField:(NSDictionary*)newInfo
{
	
	indexField = newInfo;
} // replaceTermField

- (void) replaceLimits:(NSArray*)newLimits
{
	limitFields = [newLimits mutableCopy];
} // replaceLimits

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(actionSheet == andOrAlert)
	{
		weAreANDingTerms = !buttonIndex;
		[advancedView reloadData];
	}
	
} // alertView:clickedButtonAtIndex:

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return segmentHeadings.count;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case kAllFields:
			return 1;
			break;
			
		case kSearchHistory:
				return 1;
			break;
			
		case kLimits:
			return limitFields.count;
			break;
			
		case kSearchFields:
//            if(![searchFields respondsToSelector:@selector(count)])
//            {
//                NSLog(@"searchFields can't count: %@", searchFields);
//                return 1;
//            }
            
			if(searchFields.count < 3)
				return searchFields.count + 2;
			else 
				return searchFields.count + 1;

			break;
			
		case kIndices:
			return 1;
			break;
			
	}
	return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return segmentHeadings[section];
} // titleForHeaderInSection

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
	if(indexPath.section == kAllFields)
	{
		CGRect	r = self.view.frame;
		static NSString *EditCellIdentifier = @"EditCell";
		TextEditCell *cell = (TextEditCell*) [tableView dequeueReusableCellWithIdentifier:EditCellIdentifier];
		if (cell == nil) {
            cell = [[TextEditCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:EditCellIdentifier];			cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
		}
		[cell setWidth:r.size.width];
		cell.myTextEditField.text = allFields;
		cell.myTextEditField.delegate = self;
		return cell;
	}
 
    static NSString *CellIdentifier = @"searchCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

        
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    
	
	cell.textLabel.textColor = [UIColor blackColor];

	switch (indexPath.section)
	{
		case kAllFields:
			cell.textLabel.text = allFields;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
			
		case kSearchHistory:
			if(searchHistory.count)
			{
				cell.textLabel.text = @"History";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			else
			{
				cell.textLabel.text = @"No search history";
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			break;
			
		case kSearchFields:
			if(indexPath.row == 0)
			{
				cell.textLabel.text = weAreANDingTerms ? @"Search for ALL of these terms" : @"Search for ANY of these terms";
				cell.textLabel.textColor = [UIColor redColor];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			else if(indexPath.row > searchFields.count)
			{
				cell.textLabel.text = @"Add a search term...";
				cell.textLabel.textColor = [UIColor blueColor];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			else
			{
				NSDictionary*	d = searchFields[indexPath.row-1];
				cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", d[@"field"], d[@"term"]];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			break;
			
		case kLimits:
			cell.textLabel.text = limitFields[indexPath.row][@"title"];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
			
		case kIndices:
			if(indexField)
				cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", indexField[@"field"], indexField[@"term"]];
			else
			{
				cell.textLabel.text = @"Add index term";
				cell.textLabel.textColor = [UIColor blueColor];
			}
				
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
			
			
	} // switch
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	//LOG(@"%s - IN",__FUNCTION__);
	switch (indexPath.section) {
		case kAllFields:
		{
		}
			break;
			
		case kSearchHistory:
		{
			if(searchHistory.count)
			{
				History*	historyController = [[History alloc] initWithNibName:@"History" bundle:nil];
				historyController.delegate = self;
				historyController.history = searchHistory;
				[self.navigationController pushViewController:historyController animated:YES];

			}
		}
			break;
			
		case kSearchFields:
		{
			if(indexPath.row == 0)
			{
				andOrAlert = [[UIAlertView alloc] initWithTitle:@"Search Options"
															  message:@"Do you want search for all terms or any?"
															 delegate:self
													cancelButtonTitle:@"All"
													otherButtonTitles:@"Any", nil];
				[andOrAlert show];
			}
			else if(indexPath.row > searchFields.count)
			{
				SearchFieldEditor*	sfe = [[SearchFieldEditor alloc] initWithNibName:@"SearchFieldEditor" bundle:nil];
				sfe.myController = self;
				[self.navigationController pushViewController:sfe animated:YES];
			}
			else
			{
				SearchFieldEditor*	sfe = [[SearchFieldEditor alloc] initWithNibName:@"SearchFieldEditor" bundle:nil];
				sfe.myController = self;
				sfe.info = searchFields[indexPath.row -1];
				[self.navigationController pushViewController:sfe animated:YES];
			}
		}
			break;

		case kLimits:
		{
			LimitEditor*	le = [[LimitEditor alloc] initWithNibName:@"LimitEditor" bundle:nil];
			le.myController = self;
			[le setInfo:limitFields atIndex:indexPath.row];
			[self.navigationController pushViewController:le animated:YES];
		}
			break;
			
		case kIndices:
		{
			IndexFieldEditor*	sfe = [[IndexFieldEditor alloc] initWithNibName:@"SearchFieldEditor" bundle:nil];
			sfe.myController = self;
			sfe.info = indexField;
			[self.navigationController pushViewController:sfe animated:YES];
		}
			break;
		default:
			break;
	} // switch
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//LOG(@"%s - OUT",__FUNCTION__);
} // didSelectRowAtIndexPath

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	//LOG(@"%s - IN",__FUNCTION__);
	switch (indexPath.section) {
		case 2:
		{
			LimitsController*	aViewController = [[LimitsController alloc] initWithNibName:@"LimitsController" bundle:nil];
			[self.navigationController pushViewController:aViewController animated:YES];
		}
			break;
		default:
			break;
	} // switch
	//LOG(@"%s - OUT",__FUNCTION__);
} // accessoryButtonTappedForRowWithIndexPath

#pragma mark Orientation support

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

@end
