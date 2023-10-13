//
//  ResultsController.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 7/9/09.
//  Copyright 2009 The Frodis Co.. All rights reserved.
//

#import "ResultsController.h"
#import "QueryAgent.h"
#import "AbstractCell.h"
#import "AbstractView.h"
#import "SafeCell.h"
#import "FullTextViewController.h"
#import "Pubmed_ExperimentAppDelegate.h"

static NSMutableDictionary* gViewedAbstracts = nil;

@implementation ResultsController
@synthesize contentView;
@synthesize busy;
@synthesize searchListView;
@synthesize statsLabel;
@synthesize backButton;
@synthesize nextButton;
@synthesize noHits;
@synthesize myToolbar;
@synthesize didGetMemoryWarning;
@synthesize ContFrameLand;
@synthesize ContFramePort;
@synthesize VShiftLandscape;
@synthesize VShiftPortrait;
@synthesize recordsPerPage,bufferPageCount;
@synthesize displayIndex;
@synthesize abstractView;
@synthesize searchTerm;
@synthesize statsText;
@synthesize searchResults;
@synthesize fetchResults;
@synthesize articles;
@synthesize allArticles;
@synthesize fullTextArticles;
@synthesize decimalFormatter;
@synthesize dbName;
@synthesize startingRecordNumber;
@synthesize endingRecordNumber;
@synthesize totalRecordNumber;
@synthesize statusTimer;
@synthesize allOrFullText;

+(NSString*) viewedAbstractsFile {
//LOG(@"%s - IN",__FUNCTION__);
    
    NSFileManager   *fileManager = [NSFileManager defaultManager];
    NSArray         *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString        *documentsDirectory = paths[0];
	
    BOOL exists = [fileManager fileExistsAtPath:documentsDirectory];
    if (!exists) {
        BOOL success = [fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:nil];
       
        if (!success) {
            NSAssert(0, @"Failed to create Documents directory.");
       }
    }
	
    NSString *prefPath = [documentsDirectory stringByAppendingFormat:@"/orkovViewedAbstracts.plist"];
	//LOG(@"%s - OUT",__FUNCTION__);
	return prefPath;
} // viewedAbstractsFile

+(void) saveViewedAbstracts {
//LOG(@"%s - IN",__FUNCTION__);
    
    if(gViewedAbstracts == nil){
        //LOG(@"%s - OUT",__FUNCTION__);
		return;
    }
	
	[gViewedAbstracts writeToFile:[ResultsController viewedAbstractsFile] atomically:YES];
//LOG(@"%s - OUT",__FUNCTION__);
}

+(void) addViewedAbstract:(NSString*)pmid {
//LOG(@"%s - IN",__FUNCTION__);
    
	gViewedAbstracts[pmid] = @([NSDate timeIntervalSinceReferenceDate]);
	[ResultsController saveViewedAbstracts];
    
//LOG(@"%s - OUT",__FUNCTION__);
}

+(BOOL) hasBeenViewed:(NSString*)pmid {
//LOG(@"%s - IN",__FUNCTION__);
	
    NSDictionary    *abstracts = [ResultsController viewedAbstracts];
	NSDate          *aDate     = abstracts[pmid];
	
//LOG(@"%s - OUT",__FUNCTION__);
	return (aDate != nil);
}

+(NSMutableDictionary*)viewedAbstracts {
//LOG(@"%s - IN",__FUNCTION__);
	
    if(gViewedAbstracts == nil) {
		gViewedAbstracts = [NSMutableDictionary dictionaryWithContentsOfFile:[ResultsController viewedAbstractsFile]];
		if(gViewedAbstracts) {
			// we're going to remove items viewed more than 1 week ago
			NSArray *keys           = gViewedAbstracts.allKeys;
			double	timeThreshold   = [NSDate timeIntervalSinceReferenceDate] - 604800.0;
            
			for(NSString* key in keys) {
                if([gViewedAbstracts[key] doubleValue] - timeThreshold < 0){
					[gViewedAbstracts removeObjectForKey:key];
                }
			}
			[ResultsController saveViewedAbstracts];
		} else {
			gViewedAbstracts = [[NSMutableDictionary alloc] init];
        }
	}

//LOG(@"%s - OUT",__FUNCTION__);

	return gViewedAbstracts;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//LOG(@"%s - IN",__FUNCTION__);
   
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.dbName                 = @"pubmed";
		self.startingRecordNumber   = @1;
		self.endingRecordNumber     = @1;
		self.totalRecordNumber      = @0;
		fullTextArticles            = nil;
		didGetMemoryWarning         = NO;
        
		int	index = [[NSUserDefaults standardUserDefaults] integerForKey:@"itemsPerPage"];
		
        switch (index) {
			case 0:
				recordsPerPage = 10;
               // bufferPageCount = 3;
				break;
			case 1:
				recordsPerPage = 25;
              //  bufferPageCount = 5;
				break;
			case 2:
				recordsPerPage = 50;
              //  bufferPageCount = 8;
				break;
			case 3:
				recordsPerPage = 75;
              //  bufferPageCount = 10;
				break;
			case 4:
				recordsPerPage = 100;
              //  bufferPageCount = 10;
				break;
			default:
				recordsPerPage = 25;
             //   bufferPageCount = 5;
			break;
		}
    }
	
	ContFrameLand   = CGRectMake(0,0,480,212);
	ContFramePort   = CGRectMake(0,0,320,372);
	VShiftLandscape = 37.0;
	VShiftPortrait  = 50.0;

//LOG(@"%s - OUT",__FUNCTION__);
    return self;
}

-(void) disableNavigation:(BOOL)disable {
//LOG(@"%s - IN",__FUNCTION__);
   
    searchListView.hidden = disable;
	busy.hidden = !disable;
    
    for(UIBarButtonItem *bbi in myToolbar.items) {
		bbi.enabled = !disable;
    }

	self.navigationItem.leftBarButtonItem.enabled = !disable;
    
//LOG(@"%s - OUT",__FUNCTION__);
}

- (void)viewDidLoad {
//LOG(@"%s - IN",__FUNCTION__);
   
    [super viewDidLoad];

    UINib *nib = [UINib nibWithNibName:@"AbstractCell" bundle:nil];
    [searchListView registerNib:nib forCellReuseIdentifier:@"SearchResultsCell"];
    [searchListView registerNib:nib forCellReuseIdentifier:@"SearchResultsCell_PDF"];
    [searchListView registerNib:nib forCellReuseIdentifier:@"SearchResultsCell_WEB"];
    searchListView.rowHeight = UITableViewAutomaticDimension;
    searchListView.estimatedRowHeight = 80.0;
    UINib *nib2 = [UINib nibWithNibName:@"SafeCell" bundle:nil];
    [searchListView registerNib:nib2 forCellReuseIdentifier:@"SafeCell"];

	if(didGetMemoryWarning) {
		busy.hidden = YES;
		statsLabel.text = statsText;
		didGetMemoryWarning = NO;
	}
	
	allOrFullText                       = [[UISegmentedControl alloc] initWithItems:@[@"All", @"Full Text"]];
	allOrFullText.segmentedControlStyle = UISegmentedControlStyleBar;
	allOrFullText.selectedSegmentIndex  = 0;
    
	[allOrFullText addTarget:self action:@selector(allOrFullTextChanged:)forControlEvents:UIControlEventValueChanged];
	self.navigationItem.titleView       = allOrFullText;
	
	decimalFormatter                    = [[NSNumberFormatter alloc] init];
	
    [decimalFormatter setUsesGroupingSeparator:YES];
	decimalFormatter.numberStyle        = NSNumberFormatterDecimalStyle;
	
	UIBarButtonItem *bookmarkButton     = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Misc_EmailButton"] style:UIBarButtonItemStylePlain target:self action:@selector(sendAsEmail:)];
	
	self.navigationItem.rightBarButtonItem = bookmarkButton;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchAgain:) name:@"SEARCH_AGAIN" object:nil];
    
//LOG(@"%s - OUT",__FUNCTION__);
}

- (void)viewWillAppear:(BOOL)animated {
//LOG(@"%s - IN",__FUNCTION__);
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchAgain:) name:@"SEARCH_AGAIN" object:nil];
	
	[super viewWillAppear:animated];
	
	[searchListView reloadData];
	
	displayIndex = -1;
    
//LOG(@"%s - OUT",__FUNCTION__);
}

- (void)viewWillDisappear:(BOOL)animated {
//LOG(@"%s - IN",__FUNCTION__);

    [super viewWillDisappear:animated];
    
//LOG(@"%s - OUT",__FUNCTION__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	didGetMemoryWarning = YES;
}

-(IBAction) sendAsEmail:(id)sender
{
    // Don't crash out if the device has no mail addresses set up
    if([MFMailComposeViewController canSendMail] == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot compose mail."
                                                        message:@"This device has not configured any email addresses."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        return;
    }
    
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate          = self;
	picker.navigationBar.tintColor      = ORKOV_TINT_COLOR;
	
	[picker setSubject:@"Orkov Pubmed Abstracts"];

    NSString *emailBody = @"";
	
	for(NSDictionary*d in articles) {
		NSDictionary*	article = d[@"MedlineCitation"][@"Article"];
		NSDictionary*	journal = article[@"Journal"];
		
        emailBody = [emailBody stringByAppendingFormat:@"<h2>%@</h2><h3>%@</h3><p>%@</p>\n<br/>", article[@"ArticleTitle"], journal[@"Title"], [AbstractCell findADate:article]];
	}
	[picker setMessageBody:emailBody isHTML:YES];
	
	[self presentModalViewController:picker animated:YES];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	statsLabel.text = @"";
	
	// Notifies users about errors associated with the interface
	switch (result) {
		case MFMailComposeResultCancelled:
			statsLabel.text = @"Email Canceled";
			break;
		case MFMailComposeResultSaved:
			statsLabel.text = @"Email Saved";
			break;
		case MFMailComposeResultSent:
			statsLabel.text = @"Email Sent";
			break;
		case MFMailComposeResultFailed:
			statsLabel.text = @"Email Failed";
			break;
		default:
			statsLabel.text = @"Email Not Sent";
			break;
	}
#if __DEBUG_OUTPUT__
	//NSLog(@"Email status:%d",result);
#endif
	statusTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(clearEmailStatus:) userInfo:nil repeats:NO];
	[self dismissModalViewControllerAnimated:YES];
}

-(void) clearEmailStatus:(NSTimer*)timer {
	statsLabel.text = statsText;
}

-(void)searchFor:(NSString*)term {
//LOG(@"%s - IN",__FUNCTION__);
	
    self.searchTerm = term;
	[self _search];
   
//LOG(@"%s - OUT",__FUNCTION__);
}

-(void) searchAgain:(NSNotification*)notification {
//LOG(@"%s - IN",__FUNCTION__);
	
    [self _search];
  
//LOG(@"%s - OUT",__FUNCTION__);
}

-(void)_search {
//LOG(@"%s - IN",__FUNCTION__);
	
    [self disableNavigation:YES];
	noHits.hidden = YES;
	
	QueryAgent  *pubmedQuery = [[QueryAgent alloc] initForDB:dbName];
	pubmedQuery.retstart    = startingRecordNumber.intValue-1;
    pubmedQuery.retmax      = recordsPerPage;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSearchResults:) name:@"PUBMED_SEARCH_COMPLETE" object:pubmedQuery];
	
	[pubmedQuery searchFor:searchTerm usingDelegate:self];
    
//LOG(@"%s - OUT",__FUNCTION__);
}

-(void) parserTimeout {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
													message:@"The server is not responding (parse failure)"
												   delegate:self
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];

	busy.hidden = YES;
	self.navigationItem.hidesBackButton = NO;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
		
	[self performSelector:@selector(searchButton:) withObject:self afterDelay:.5];
}

#pragma mark query delegate methods
-(void) getSearchResults:(NSNotification*)notification {
//LOG(@"%s - IN",__FUNCTION__);
	
    NSDictionary *tResults = notification.userInfo;
	[self _getSearchResults:tResults];
    
//LOG(@"%s - OUT",__FUNCTION__);
}

-(void) _getSearchResults:(NSDictionary*)tResults {
//LOG(@"%s - IN",__FUNCTION__);
    
	self.searchResults = tResults;
	self.totalRecordNumber = @([searchResults[@"Count"] intValue]);
	
	if(totalRecordNumber.intValue == 0) {
		[self disableNavigation:NO];
		self.startingRecordNumber   = @0;
		self.endingRecordNumber     = @0;
		self.totalRecordNumber      = @0;
		
		UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"Search Results"
														message:@"No items found."
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];

		self.navigationItem.hidesBackButton = NO;
		return;
    }
    
	NSMutableArray  *ids = nil;
	
	id idList = searchResults[@"IdList"][@"Id"];
    
    if([idList isKindOfClass:[NSString class]]){
		ids = @[idList];
    } else {
		ids = (NSMutableArray*) idList;
    }
    
    //NSLog(@"IDs: %@",idList );
	int count = ids.count;
	int	start = [searchResults[@"RetStart"] intValue];
	int	end   = start + count;
	
	self.startingRecordNumber = @(start+1);
	self.endingRecordNumber   = @(end);
	
	QueryAgent *xAgent = [[QueryAgent alloc] initForDB:dbName];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFetchResults:) name:@"PUBMED_FETCH_COMPLETE" object:xAgent];
	
    [xAgent fetchIDs:ids usingDelegate:self];
	
	self.statsText = [NSString stringWithFormat:@"Displaying records\n%@ to %@ of %@", 
					  [decimalFormatter stringFromNumber:startingRecordNumber], 
					  [decimalFormatter stringFromNumber:endingRecordNumber], 
					  [decimalFormatter stringFromNumber:totalRecordNumber]];
	
	statsLabel.text = statsText;
//LOG(@"%s - OUT",__FUNCTION__);
}

-(void) getFetchResults:(NSNotification*)notification {
//LOG(@"%s - IN",__FUNCTION__);
	
    NSDictionary    *tResults = notification.userInfo;
    
	[self _getFetchResults:tResults];
    
//LOG(@"%s - OUT",__FUNCTION__);
}

-(void) _getFetchResults:(NSDictionary*)tResults {
//LOG(@"%s - IN",__FUNCTION__);
    
    int fetchCount = 0;
    
    if ([tResults allKeys].count > 0){
        self.fetchResults = tResults;
    } else {
        self.fetchResults = nil;
    }
    
	if(fetchResults) {
		id	xArticles     = fetchResults[@"PubmedArticle"];

        if (xArticles == nil) {
            xArticles = @[self.fetchResults];
        }
        if(xArticles != nil) {
            if([xArticles isKindOfClass:[NSArray class]]){
                self.allArticles = (NSArray*) xArticles;
            } else {
                self.allArticles = @[xArticles];
            }
        }
	}
    id  xBookArticles = fetchResults[@"PubmedBookArticle"];
    int bookCount     = 0;
    
    if(xBookArticles != nil) {
        if([xBookArticles isKindOfClass:[NSArray class]]){
            bookCount =  [xBookArticles count];
        }
    }
    
    fetchCount = bookCount + [self.allArticles count];
    
    if( [self.allArticles count] < fetchCount){
       // int deficit = fetchCount - [self.allArticles count];
        int deficit = bookCount;
        NSMutableArray *altTitles = [NSMutableArray array];
        
        id    xBookArticles = fetchResults[@"PubmedBookArticle"];

        if(xBookArticles != nil) {
            if([xBookArticles isKindOfClass:[NSArray class]]){
                int ct =  [xBookArticles count];

                for(int i = 0; i< ct; i++){
                    NSDictionary *article = [xBookArticles objectAtIndex:i];
                    NSString     *title   = [article objectAtPath:@"BookDocument/ArticleTitle"];
                    
                    if(title == nil){
                        title = @"Unknown Article";
                    }
                    
                    [altTitles addObject:title];
                }
            }
        }
        
        if (altTitles.count < deficit){
            int padcount = deficit - altTitles.count;
            for (int i = 0; i < padcount; i++){
                [altTitles addObject:@"Unknown Article"];
            }
        }
        
        NSMutableArray *articlesMOD = [self.allArticles mutableCopy];

        for (int i = 0; i < deficit; i++){
            NSString *ttl = [altTitles objectAtIndex:i];
            NSDictionary *rec = [NSDictionary dictionaryWithObjectsAndKeys:ttl, @"alttitle", @"Abstract could not be displayed in this mobile version.  We recommend using a desktop browser.", @"altmessage", nil];
            [articlesMOD addObject:rec];
        }
        
        self.allArticles = articlesMOD;
    }
    
	fullTextArticles = @[];

	for(NSDictionary*d in allArticles) {
		BOOL	    shouldAdd       = NO;
        
        if ([d objectAtPath:@"alttitle"] != nil) {
            continue;
        }
        
		NSArray     *ArticleIdList  = [d objectAtPath:@"PubmedData/ArticleIdList/ArticleId"];
                
       // NSLog(@"Article: %@",d);
        
        if(ArticleIdList && ![ArticleIdList isKindOfClass:[NSArray class]]){
			ArticleIdList = @[ArticleIdList];
        }
        
		for(id xidType in ArticleIdList) {
			NSString    *xidTypeString = nil;
			
            if(![xidType isKindOfClass:[NSDictionary class]])
				continue;
			
			xidTypeString = xidType[@"IdType"];
            
            if([xidTypeString.uppercaseString isEqualToString:@"PMC"] || [xidTypeString.uppercaseString isEqualToString:@"DOI"]) {
                shouldAdd = YES;
                
//                if([xidTypeString.uppercaseString isEqualToString:@"PMC"]){
//                    NSLog(@"HIT");
//                }
            }
  		}
        
        if(shouldAdd){
			fullTextArticles = [fullTextArticles arrayByAddingObject:d];
        }
	}
	
	if(allOrFullText.selectedSegmentIndex == 0) {
		articles = allArticles;
		noHits.hidden = YES;
	} else {
		articles = fullTextArticles;
		noHits.hidden = (fullTextArticles.count > 0);
	}
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
    self.searchListView.alpha = 1.0;
	[searchListView reloadData];
    [searchListView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];

	[self disableNavigation:NO];
	[self adjustToobar];
    
//LOG(@"%s - OUT",__FUNCTION__);
}

-(IBAction) searchButton:(id)sender {
//LOG(@"%s - IN",__FUNCTION__);
	[self.navigationController popToRootViewControllerAnimated:YES];
//LOG(@"%s - OUT",__FUNCTION__);
}

-(IBAction) doBackButton:(id)sender {
//LOG(@"%s - IN",__FUNCTION__);
	int	startNextPage = startingRecordNumber.intValue - recordsPerPage;
    
    if(startNextPage < 0) {
		startNextPage = 0;
    }
	
	self.startingRecordNumber = @(startNextPage);
	[self _search];
    
//LOG(@"%s - OUT",__FUNCTION__);
}

-(IBAction) doNextButton:(id)sender {
	int	startNextPage         = startingRecordNumber.intValue + recordsPerPage;
	self.startingRecordNumber = @(startNextPage);
	
    [self _search];
}

-(void) adjustToobar {
//LOG(@"%s - IN",__FUNCTION__);
    
	backButton.enabled = startingRecordNumber.intValue > 1;
	nextButton.enabled = (endingRecordNumber.intValue < totalRecordNumber.intValue -1);
    
//LOG(@"%s - OUT",__FUNCTION__);
}

-(BOOL) canShowPrevious {
	return (displayIndex > 0);
}

-(BOOL) canShowNext {
	return (displayIndex < articles.count-1);
}

-(void) showPrevious {
    if(displayIndex > 0){
		[self updateAbstractViewForArticle:--displayIndex];
    }
}

-(void) showNext {
//LOG(@"%s - IN",__FUNCTION__);
    
    if(displayIndex < articles.count-1){
		[self updateAbstractViewForArticle:++displayIndex];
    }
    
//LOG(@"%s - OUT",__FUNCTION__);
} 

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return articles.count;
}

-(void)checkAbstractText:(NSMutableDictionary*)article {
    id                    AbstractText;
    NSMutableDictionary  *Abstract = nil;
    NSMutableDictionary  *Article = nil;
    NSMutableDictionary  *medlineCitation = [article objectForKey:@"MedlineCitation"];
    
    if(medlineCitation){
        Article = [medlineCitation objectForKey:@"Article"];
        
        if(Article) {
           Abstract = [Article objectForKey:@"Abstract"];
            
            if (Abstract) {
               AbstractText = [Abstract objectForKey:@"AbstractText"];
                
                if([AbstractText isKindOfClass:[NSDictionary class]]) {
                    //NSLog(@"Yikes it's a dictionary");
                   // [Abstract setObject:@"BOGUS" forKey:@"AbstractText"];
                } else {
                    if([AbstractText isKindOfClass:[NSString class]]){
                       // NSLog(@"It's a string as expected");
                    } else {
                       // NSLog(@"who knows what it is");
                    }
                }
            }
         }
    }
 }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//LOG(@"%s - IN",__FUNCTION__);
    
    NSString		    *CellIdentifier  = @"SearchResultsCell";
    NSMutableDictionary	*article         = [articles[indexPath.row] mutableCopy];
    
    if ([article objectAtPath:@"alttitle"] != nil) {
        SafeCell *cell = nil;

       cell = (SafeCell*)[tableView dequeueReusableCellWithIdentifier:@"SafeCell"];
        
        if (cell == nil)  {
            cell = [[SafeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SafeCell"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightMedium];
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.detailTextLabel.textColor = [UIColor colorWithRed:147.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1];
        }
        
        NSString *ttl             = [article objectAtPath:@"alttitle"];
        NSString *desc            = [article objectAtPath:@"altmessage"];
        cell.titleLBL.text        = ttl;
        cell.descLBL.text         = desc;
        
        cell.recordNumber.text = [NSString stringWithFormat:@"%ld", startingRecordNumber.intValue+indexPath.row];

        return cell;
    }

    NSString		    *pmcID           = nil;
    NSString		    *doi             = nil;
    NSArray             *ArticleIdList   = [article objectAtPath:@"PubmedData/ArticleIdList/ArticleId"];
    NSString            *ABText          = [article objectAtPath:@"MedlineCitation/Article/Abstract/AbstractText"];
    NSDictionary        *medlineCitation = [article objectForKey:@"MedlineCitation"];
    id                  otherID          = [medlineCitation objectForKey:@"OtherID"];

    //NSLog(@"Item: %ld  =  NSString",(long)indexPath.row);

#ifdef __DEBUG_OUTPUT__
	//NSLog(@"%@", ArticleIdList);
#endif

    [self checkAbstractText:article];
    
    if(ArticleIdList && ![ArticleIdList isKindOfClass:[NSArray class]]){
		ArticleIdList = @[ArticleIdList];
    }

    int c = ArticleIdList.count;

    for(id xidType in ArticleIdList) {
		NSString    *xidTypeString = nil;
		
        if(![xidType isKindOfClass:[NSDictionary class]]){
			continue;
        }
		
		xidTypeString = xidType[@"IdType"];
       
        if([xidTypeString.uppercaseString isEqualToString:@"PMC"]) {
            pmcID   = xidType[@"Id"];
        }
        
        if([xidTypeString.uppercaseString isEqualToString:@"DOI"]) {
            doi     = xidType[@"Id"];
        }
	}
	AbstractCell *cell = nil;
    
	if(pmcID || doi) {
        if(doi){
			CellIdentifier = @"SearchResultsCell_WEB";
        }
        if(pmcID) {
            [article setObject:pmcID forKey:@"PMC"];
			CellIdentifier = @"SearchResultsCell_PDF";
        }
        
		cell = (AbstractCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
		if (cell == nil) {
			cell = [[AbstractCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
 		}
	} else {
		cell = (AbstractCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
            cell = [[AbstractCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
    
    [cell setBadgeHidden:!(pmcID||doi)];
    
	cell.label_RecordNumber.text = [NSString stringWithFormat:@"%ld", startingRecordNumber.intValue+indexPath.row];
	cell.info                    = article;

//LOG(@"%s - OUT",__FUNCTION__);
    return cell;
}

-(void)buttonClicked:(id)sender {
//LOG(@"%s - IN",__FUNCTION__);
	
    UIView      *senderButton   = (UIView*) sender;
	NSIndexPath *indexPath      = [searchListView indexPathForCell: (UITableViewCell*)senderButton.superview.superview];
	//you have the indexPath of the cell who holds the pushed button
	
	AbstractCell           *ac                    = (AbstractCell*) [searchListView cellForRowAtIndexPath:indexPath];
	FullTextViewController *anotherViewController = [[FullTextViewController alloc] initWithNibName:@"FullTextViewController" bundle:nil];
	
    anotherViewController.info  = articles[indexPath.row];
	anotherViewController.pmcid = ac.pmcID;
	
	NSDictionary    *article = articles[indexPath.row][@"MedlineCitation"];
	NSString        *pmi     = article[@"PMID"];
	
    [ResultsController addViewedAbstract:pmi];
	
	[self.navigationController pushViewController:anotherViewController animated:YES];
    
//LOG(@"%s - OUT",__FUNCTION__);
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if(indexPath.row % 2) {
        cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.02];
    } else {
		cell.backgroundColor = [UIColor clearColor];
    }
}
//- (BOOL)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//LOG(@"%s - IN",__FUNCTION__);
    NSDictionary    *article  = [articles objectAtIndex:indexPath.row];
    
    if ([article objectAtPath:@"alttitle"] != nil){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    if(abstractView == nil) {
		abstractView = [[AbstractView alloc] initWithNibName:@"AbstractView" bundle:nil];
		abstractView.myController = self;
	}
	abstractView.dbName = dbName;
    
    [self.navigationController pushViewController:abstractView animated:YES];
    
    [self updateAbstractViewForArticle:indexPath.row];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

//LOG(@"%s - OUT",__FUNCTION__);
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
//LOG(@"%s - IN",__FUNCTION__);
	
    AbstractCell           *ac                    = (AbstractCell*) [tableView cellForRowAtIndexPath:indexPath];
	FullTextViewController *anotherViewController = [[FullTextViewController alloc] initWithNibName:@"FullTextViewController" bundle:nil];
	
    anotherViewController.info  = articles[indexPath.row];
	anotherViewController.pmcid = ac.pmcID;
	
	NSDictionary    *article = articles[indexPath.row][@"MedlineCitation"];
	NSString        *pmi     = article[@"PMID"];
    
	[ResultsController addViewedAbstract:pmi];

	[self.navigationController pushViewController:anotherViewController animated:YES];
    
//LOG(@"%s - OUT",__FUNCTION__);
}

-(void)updateAbstractViewForArticle:(NSInteger)index {
//LOG(@"%s - IN",__FUNCTION__);
	
    displayIndex             = index;
	abstractView.info        = articles[index];
	
    NSString        *pmi     = nil;
	NSDictionary    *article = articles[index][@"MedlineCitation"];
	
    pmi = article[@"PMID"];

	[ResultsController addViewedAbstract:pmi];

//LOG(@"%s - OUT",__FUNCTION__);
}

- (IBAction) allOrFullTextChanged:(id)sender {
//LOG(@"%s - IN",__FUNCTION__);
	
    if(allOrFullText.selectedSegmentIndex == 0) {
		articles = allArticles;
		noHits.hidden = YES;
	} else {
		articles = fullTextArticles;
		noHits.hidden = (fullTextArticles.count > 0);
	}

	[searchListView reloadData];
    
//LOG(@"%s - OUT",__FUNCTION__);
}


#pragma mark Orientation support

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

@end
