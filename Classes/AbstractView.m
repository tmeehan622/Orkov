//
//  AbstractView.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 6/22/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "AbstractView.h"
#import "AbstractCell.h"
#import "BookMarksController.h"
#import "RelatedResults.h"
#import "FullTextViewController.h"
#import "NotesView.h"
#import "LoansomeView.h"
#import "Pubmed_ExperimentAppDelegate.h"

@interface AbstractView()
{
    NSString *htmlStr;
}
@end

@implementation AbstractView
@synthesize bookmarkButton;
@synthesize emailButton;
@synthesize fullTextButton;
@synthesize myToolbar;
@synthesize abstractView;
@synthesize contentView;
@synthesize bmTitleField;
@synthesize navArrows;
@synthesize info;
@synthesize dbName;
@synthesize statusTimer;
@synthesize pmcID, pdfAvailable;
@synthesize doi;
@synthesize html;
@synthesize myController;
@synthesize cacheFile;
@synthesize ContFrameLand;
@synthesize ContFramePort;
@synthesize VShiftLandscape;
@synthesize VShiftPortrait;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		myController = nil;
		
		ContFrameLand = CGRectMake(0,0,480,185);
		ContFramePort = CGRectMake(0,0,320,374);
		VShiftLandscape = 32.0;
		VShiftPortrait = 50.0;
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	//NSLog(@"abstract viewDidLoad-IN");
    
//	Pubmed_ExperimentAppDelegate *appD = [[UIApplication sharedApplication] delegate];
//	[self.view insertSubview:appD.logTextView atIndex:[[self.view subviews] count]-1];
    
//    abstractView.delegate = self;
//	abstractView.alpha = 0.25;
    self.pdfAvailable = NO;
    
    if(abstractView.delegate == nil)
        [abstractView setDelegate:self];

	for(UIBarButtonItem* bbi in myToolbar.items)
		bbi.enabled = NO;
	
    emailButton.enabled = YES;
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass == nil)
		emailButton.enabled = NO;

	self.navigationItem.title = @"Abstract";
	
//	NSArray*	arrows = @[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UpTriangle" ofType:@"png"]],
//						  [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DownTriangle" ofType:@"png"]]];

    NSArray *arrows = @[[UIImage imageNamed:@"Misc_UpTriangle"],
                        [UIImage imageNamed:@"Misc_DownTriangle"]];
	navArrows = [[UISegmentedControl alloc] initWithItems:arrows];
//	navArrows.segmentedControlStyle = UISegmentedControlStyleBar;
	navArrows.momentary = YES;
	[navArrows addTarget:self
						 action:@selector(arrowTouch:)
			   forControlEvents:UIControlEventValueChanged];

	UINavigationItem*	navItem = self.navigationItem;
	UIBarButtonItem*	rightButton = [[UIBarButtonItem alloc] initWithCustomView:navArrows];
    navItem.rightBarButtonItem = rightButton;
	//NSLog(@"abstract viewDidLoad-OUT");
}

- (IBAction) arrowTouch:(id)sender
{
	for(UIBarButtonItem* bbi in myToolbar.items)
		bbi.enabled = NO;

	if([sender selectedSegmentIndex] == 0)
		[myController showPrevious];
	else
		[myController showNext];
		
} // arrowTouch


-(IBAction) viewFullText:(id)sender
{
	FullTextViewController *anotherViewController = [[FullTextViewController alloc] initWithNibName:@"FullTextViewController" bundle:nil];
	anotherViewController.pmcid = pmcID;
    anotherViewController.info = info;
    anotherViewController.pdfAvailable = pdfAvailable ? 1 : 0;
    

	[self.navigationController pushViewController:anotherViewController animated:YES];
	
} // viewFullText

- (void)viewWillAppear:(BOOL)animated 
{
	//NSLog(@"viewWillAppear-IN");
	[super viewWillAppear:animated];
    
    NSLog(@"AbstractView - viewWillAppear");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSLog(@"Documents Directory: %@",documentsDirectory);

    // Update the webview
    //[abstractView loadHTMLString:@"" baseURL:nil];
    [self loadHTML];
    
} // viewWillAppear

- (void)viewWillDisappear:(BOOL)animated
{
	//NSLog(@"viewWillDisappear-IN");
	[super viewWillDisappear:animated];

	[abstractView stopLoading];
//	abstractView.delegate = nil;
	
	
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSLog(@"Documents Directory: %@",documentsDirectory);
    BOOL exists = [fileManager fileExistsAtPath:documentsDirectory];
    if (!exists) {
        BOOL success = [fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:nil];
       if (!success) {
            NSAssert(0, @"Failed to create Documents directory.");
        }
    }
	
    self.cacheFile = [documentsDirectory stringByAppendingFormat:@"/abstractCache.plist"];
	[info writeToFile:self.cacheFile atomically:YES];
	//NSLog(@"viewWillDisappear-OUT");
	
} // viewWillDisappear


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}



-(NSDictionary*) info
{
	return info;
} // info

-(void)checkForPDF {
    
    NSString    *pmcURL=[NSString stringWithFormat:@"http://www.pubmedcentral.nih.gov/picrender.fcgi?artid=%@&blobtype=pdf", self.pmcID];
    
    NSURL *url = [NSURL URLWithString:pmcURL];
    
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              
                                              NSHTTPURLResponse   *hResponse = (NSHTTPURLResponse*)response;
                                              int status = hResponse.statusCode;
                                              
                                              self.pdfAvailable = status == 200;
                                          }];
    
    
    [downloadTask resume];
}

-(void)checkForPDFStatus {
    NSURLSessionDataTask *finderTask;
    NSString             *pmcURL=[NSString stringWithFormat:@"http://www.pubmedcentral.nih.gov/picrender.fcgi?artid=%@&blobtype=pdf", self.pmcID];
    
    NSLog(@"URL: %@",pmcURL);
    NSURL *url = [NSURL URLWithString:pmcURL];
    
    
   NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                                           delegate:self
                                                                      delegateQueue:[NSOperationQueue mainQueue]];

                                   
                                   
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    finderTask = [session dataTaskWithRequest:request];
    [finderTask resume];
                                   
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{

    NSLog(@"Did Receive Data");

}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
   
    
    NSLog(@"Did Receive Response");
    
    NSHTTPURLResponse   *hResponse = (NSHTTPURLResponse*)response;
    int status = hResponse.statusCode;
    
    NSLog(@"Status: %d", status);

    self.pdfAvailable = status == 200;

    completionHandler(NSURLSessionResponseCancel);
}

-(void) setInfo:(NSDictionary*)d
{
	info = d;

	NSDictionary    *medlineCitation    = info[@"MedlineCitation"];
	NSDictionary    *article            = medlineCitation[@"Article"];
	NSDictionary    *journal            = article[@"Journal"];
	NSDictionary    *abstract           = article[@"Abstract"];
	id				otherID             = medlineCitation[@"OtherID"];
	
	NSString        *authorsString = @"";
	
	NS_DURING
	NSArray         *authorList = [article objectAtPath:@"AuthorList/Author"];
   
    if(![authorList isKindOfClass:[NSArray class]]){
		authorList = @[authorList];
    }
	
	NSArray *authorStrings = @[];
	for(NSDictionary*d in authorList) {
		NSString    *hrefString = [NSString stringWithFormat:@"%@ %@",d[@"ForeName"], d[@"LastName"]];
		authorStrings = [authorStrings arrayByAddingObject:
						 [NSString stringWithFormat:@"<a href=\"orkovauth://%@\">%@ %@</a>", hrefString, d[@"LastName"],d[@"Initials"]]];
	}
	authorsString = [authorStrings componentsJoinedByString:@", "];
	NS_HANDLER
	//NSLog(@"Barfed on getting abstract author name");
	NS_ENDHANDLER
	NSString    *pubDate = [AbstractCell findADate:article];
	NSString    *journalTitle = journal[@"Title"];
	
	NSString    *headings = @"";
    if(journalTitle){
		headings = [headings stringByAppendingFormat:@"<br/>%@", journalTitle];
    }
	
    if(pubDate){
		headings = [headings stringByAppendingFormat:@"<br/>%@", pubDate];
    }
	
    NSString    *header = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fullTextHeader" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
	
    NSString  *articleTitle = article[@"ArticleTitle"];
	NSString  *abstractText = abstract[@"AbstractText"];
    
    if([abstractText isKindOfClass:[NSDictionary class]]){
        abstractText = nil;
    }

    if(articleTitle == nil){
		articleTitle = @"";
    }
    
    if(abstractText == nil){
        abstractText = @"";
    }
    
	NSArray *otherIDs = [info objectAtPath:@"MedlineCitation/OtherID"];
    
	NS_DURING
    if(otherIDs != nil && ![otherIDs isKindOfClass:[NSArray class]]){
		otherIDs = @[otherIDs];
    }
	NS_HANDLER
	otherIDs = @[];
	NS_ENDHANDLER
	
	NSArray *pubIDs = @[];
    
	for(NSString  *thisID in otherIDs) {
		if([thisID.uppercaseString hasPrefix:@"PMC"]) {
			pubIDs = [pubIDs arrayByAddingObject:[NSString stringWithFormat:@"<span class=\"doc-number\">PubMed Central ID %@</span><br/>", thisID]];
        } else {
			pubIDs = [pubIDs arrayByAddingObject:[NSString stringWithFormat:@"<span class=\"doc-number\">Journal ID %@</span><br/>", thisID]];
        }
		
	}
	NSString *pubIDstring = @"";
    
	pubIDstring = [NSString stringWithFormat:@"<p><hr/>PubMed ID %@<br/>%@<br/><a href=\"https://docline.gov/loansome/login.cfm\" ><img src=\"https://docline.gov/loansome/images/sub_logo.gif\"/> Order from NLM LoansomeDoc</a><br/></p><hr/>\n", [info objectAtPath:@"MedlineCitation/PMID"],
				   [pubIDs componentsJoinedByString:@"\n"]];
	
	html = [NSString stringWithFormat:@"%@<body><div class=\"fm-title\">%@</div>\n<span class=\"doc-number\">%@</span>\n<p>%@</p><div class=\"fm-author\">%@</div>%@</body></html>", 
			header, articleTitle, pubIDstring, headings, authorsString, abstractText];
	
    htmlStr = html;
    
	self.pmcID = nil;
	self.doi = nil;

	if(otherID) {
		if([otherID isKindOfClass:[NSArray class]]) {
			for(NSString* thisID in otherID) {
				if([thisID.uppercaseString hasPrefix:@"PMC"]) {
					self.pmcID = [thisID substringFromIndex:3];
					break;
				}
			}
        } else {
            if([otherID isKindOfClass:[NSString class]]) {
                self.pmcID = otherID;
            }
        }
	}

	NSArray *ArticleIdList = [info objectAtPath:@"PubmedData/ArticleIdList/ArticleId"];
	
    if(ArticleIdList && ![ArticleIdList isKindOfClass:[NSArray class]]){
		ArticleIdList = @[ArticleIdList];
    }
    
	for(id xidType in ArticleIdList) {
		NSString    *xidTypeString = nil;
        
        if(![xidType isKindOfClass:[NSDictionary class]]){
			continue;
        }
		
		xidTypeString = xidType[@"IdType"];
        
		if([xidTypeString.uppercaseString isEqualToString:@"PMC"]){
			self.pmcID = xidType[@"Id"];
		} else {
            if([xidTypeString.uppercaseString isEqualToString:@"DOI"]) {
                self.doi = xidType[@"Id"];
            }
        }
	}
	
    for(UIBarButtonItem* bbi in myToolbar.items){
		bbi.enabled = YES;
    }

    [self checkForPDFStatus];
    
//    if (self.pmcID != nil){
//        self.pdfAvailable = [self checkForPDF];
//    } else {
//        self.pdfAvailable = NO;
//    }
    
    //self.pdfAvailable = YES;
	fullTextButton.enabled = (pmcID != nil || doi != nil);
    
	NSDictionary    *existingX = [BookMarksController findBookmarkWithID:[info objectAtPath:@"MedlineCitation/PMID"] forDB:@"pubmed"];
	bookmarkButton.enabled = (existingX == nil);
}


// setInfo isn't working right...
// when it is called before the view has loaded, the webview won't work right because it has no delegate
// let's call it separately
-(void)loadHTML
{
//    NSLog(@"HTML: %@", htmlStr);
    [abstractView loadHTMLString:htmlStr baseURL:nil];
//    htmlStr = nil;
    
    // Copied from above because setInfo doesnt work great
    for(UIBarButtonItem* bbi in myToolbar.items)
        bbi.enabled = YES;
    
    fullTextButton.enabled = (pmcID != nil || doi != nil);
    NSDictionary    *existingX = [BookMarksController findBookmarkWithID:[info objectAtPath:@"MedlineCitation/PMID"] forDB:@"pubmed"];
    bookmarkButton.enabled = (existingX == nil);
    
    [navArrows setEnabled:[myController canShowPrevious] forSegmentAtIndex:0];
    [navArrows setEnabled:[myController canShowNext] forSegmentAtIndex:1];
}


-(IBAction) searchButton:(id)sender
{
	[self.navigationController popToRootViewControllerAnimated:YES];
} // searchButton


-(IBAction) getRelated:(id)sender
{
	RelatedResults*	aViewController = [[RelatedResults alloc] initWithNibName:@"ResultsController" bundle:nil];
	[self.navigationController pushViewController:aViewController animated:YES];
	NSString*	searchTerm = [info objectAtPath:@"MedlineCitation/PMID"]; 
	[aViewController searchForRelated:searchTerm];
	
} // getRelated


-(IBAction) addAsBookmark:(id)sender
{
	NSDictionary    *article = info[@"MedlineCitation"][@"Article"];

	UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Bookmark Saved" message:article[@"ArticleTitle"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
//    bmTitleField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
//    bmTitleField.text = article[@"ArticleTitle"];
//    bmTitleField.backgroundColor = [UIColor whiteColor];
//    [myAlertView addSubview:bmTitleField];
//	CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 130.0);
//	[myAlertView setTransform:myTransform];
	
	[myAlertView show];
	
} // addAsBookmark

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex != 0)
	{
		NSString*	newTitle = bmTitleField.text;
		NSMutableDictionary*	newInfo = [NSMutableDictionary dictionaryWithDictionary:info];
		NSMutableDictionary*	newCitation = [NSMutableDictionary dictionaryWithDictionary:newInfo[@"MedlineCitation"]];
		NSMutableDictionary*	newArticle = [NSMutableDictionary dictionaryWithDictionary:newCitation[@"Article"]];

		newArticle[@"ArticleTitle"] = newTitle;
		newCitation[@"Article"] = newArticle;
		newInfo[@"MedlineCitation"] = newCitation;
		
#if 0
		[BookMarksController addBookmark:newInfo forDatabase:dbName];
#else
		NotesView*		nv = [[NotesView alloc] initWithNibName:@"NotesView" bundle:nil];
		nv.info = newInfo;
		nv.delegate = self;
		[self.navigationController pushViewController:nv animated:YES];
		[nv toggleEditing:self];
#endif		
	}
} // clickedButtonAtIndex

-(void) updateBookmarkInfo:(NSDictionary*)newInfo
{
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ADD_BOOKMARK"
																						 object:self
																					   userInfo:newInfo]];
} // updateInfo

-(IBAction) sendAsEmail:(id)sender
{
    // Don't crash out if the device has no mail addresses set up
    if([MFMailComposeViewController canSendMail] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot compose mail."
                                                        message:@"This device has not configured any email addresses."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        return;
    }
    
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.navigationBar.tintColor = ORKOV_TINT_COLOR;
	picker.mailComposeDelegate = self;
	
	NSString*	title = [info objectAtPath:@"MedlineCitation/Article/ArticleTitle"];
	if(title == nil)
		title = @"";
	
	[picker setSubject:[NSString stringWithFormat:@"Orkov Pubmed Abstract %@", title]];
	
	// Fill out the email body text
	NSMutableString	*emailBody = [NSMutableString stringWithString:html];
	[emailBody replaceOccurrencesOfString:@"orkovBigImage://" withString:@"http://" options:NSLiteralSearch range:NSMakeRange(0, emailBody.length)];
	[FullTextViewController removeTags:@"a href=\"orkovauth" fromString:emailBody];
	
	if(pmcID && pmcID.length)
	{
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = paths[0];
		
		BOOL exists = [fileManager fileExistsAtPath:documentsDirectory];
		if (!exists) {
            BOOL success = [fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:nil];
			if (!success) {
				NSAssert(0, @"Failed to create Documents directory.");
			}
		}
		
		NSString *pdfPath = [documentsDirectory stringByAppendingFormat:@"/%@.pdf", self.pmcID];
		exists = [fileManager fileExistsAtPath:pdfPath];
		if(exists)
			[picker addAttachmentData:[NSData dataWithContentsOfFile:pdfPath] mimeType:@"application/pdf" fileName:pdfPath.pathComponents.lastObject];
	}
	
	NSDictionary *bm = [BookMarksController findBookmarkWithID:[info objectAtPath:@"MedlineCitation/PMID"] forDB:@"pubmed"];
    NSString     *notes;
	
    if(bm) {
        NSString *noteText = @"";
        NSDictionary *notesDict = bm[@"notes"];
        if (notesDict != nil){
            noteText = notesDict[@"text"];
        }
		notes = [NSString stringWithFormat:@"<body><p><strong>Notes: </strong>%@</p><br/>\n", noteText];
		[emailBody replaceOccurrencesOfString:@"<body>" withString:notes options:NSLiteralSearch range:NSMakeRange(0, emailBody.length)];
	}
	
	[picker setMessageBody:emailBody isHTML:YES];
	
	[self presentModalViewController:picker animated:YES];
} // sendAsEmail

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
#if 0
	emailStatus.text = @"";
	
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			emailStatus.text = @"Email Canceled";
			break;
		case MFMailComposeResultSaved:
			emailStatus.text = @"Email Saved";
			break;
		case MFMailComposeResultSent:
			emailStatus.text = @"Email Sent";
			break;
		case MFMailComposeResultFailed:
			emailStatus.text = @"Email Failed";
			break;
		default:
			emailStatus.text = @"Email Not Sent";
			break;
	}
#ifdef __DEBUG_OUTPUT__
	//NSLog(@"Email status:%d",result);
#endif
	statusTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(clearEmailStatus:) userInfo:nil repeats:NO];
#endif
	[self dismissModalViewControllerAnimated:YES];
} // mailComposeController

-(void) clearEmailStatus:(NSTimer*)timer
{
#if 0
	emailStatus.text = @"";
#endif
} // clearEmailStatus

#pragma mark WebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView;
{
    //NSLog(@"Start Webview Load");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    //NSLog(@"Finish Webview Load");
	abstractView.alpha = 1;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
#ifdef __DEBUG_OUTPUT__
	//NSLog(@"didFailLoadWithError %@",[error localizedDescription]);
#endif
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{	
	NSURL*		dest = request.URL;
	BOOL		isLoansome = NO;
	
	if(dest)
	{
		NSRange r = [dest.host rangeOfString:@"docline.gov"];
		isLoansome = (r.location != NSNotFound);
	}
	
	if(navigationType == UIWebViewNavigationTypeLinkClicked)
	{
		NSString*	scheme = dest.scheme;
		NSString*	resourceSpecifier = [[dest.resourceSpecifier substringFromIndex:2] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
		
		if([scheme isEqualToString:@"orkovauth"])
		{
			ResultsController*	aViewController = [[ResultsController alloc] initWithNibName:@"ResultsController" bundle:nil];
			[self.navigationController pushViewController:aViewController animated:YES];
			NSString*	searchTerm = [NSString stringWithFormat:@"%@[AU]+AND+(loattrfull+text[sb]+AND+loattrfree+full+text[sb]+AND+hasabstract[text]", 
									  resourceSpecifier];
			[aViewController searchFor:searchTerm];
		}
		else if(isLoansome)
		{
			[abstractView stopLoading];
			LoansomeView* lonesomeView = [[LoansomeView alloc] initWithNibName:@"LoansomeView" bundle:nil];
			[self presentModalViewController: lonesomeView animated:YES];
		}
		else
			[[UIApplication sharedApplication] openURL:dest];
		
		return NO;
	}
	
	return YES;
}

-(BOOL) isLandscape
{
	UIInterfaceOrientation orient = [UIDevice currentDevice].orientation;
	
	if((orient == UIInterfaceOrientationLandscapeLeft) || (orient == UIInterfaceOrientationLandscapeRight))
		return YES;
	else 
		return NO;
}

#pragma mark Orientation support

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


@end
