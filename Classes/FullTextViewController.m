//
//  FullTextViewController.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 7/31/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "FullTextViewController.h"
#import "PDFLibraryViewController.h"
#import "QueryAgent.h"
#import "BookMarksController.h"
#import "PMCRecordParser.h"
#import "RelatedResults.h"
#import "PDFNotesView.h"
#import "LoansomeView.h"
#import "InAppWebBrowser.h"

#define BIG_IMAGE_FADE 0.5

/*
PMC articles figures:
 in the xml the look like this:
 
 
 <fig position="float" id="F1">
 <label>Figure 1</label>
 <caption>
 <p>
 <bold>The percentage of "outlier" spots,
 <italic>P</italic>
 <sub>
 <italic>out</italic>
 </sub>
 , is plotted versus PMT gain in slide #3</bold>
 .
 <italic>P</italic>
 <sub>
 <italic>out</italic>
 </sub>
 =
 <italic>N</italic>
 <sub>
 <italic>out</italic>
 </sub>
 /
 <italic>N</italic>
 with
 <italic>N</italic>
 <sub>
 <italic>out</italic>
 </sub>
 being the number of events where a spot is found to be an "outlier" between
 two successive scans and
 <italic>N</italic>
 = (
 <italic>Nscans</italic>
 -1) &#x000d7;
 <italic>n</italic>
 <sub>
 <italic>spots</italic>
 </sub>
 (
 <italic>Nscans</italic>
 is the number of scans in the series and
 <italic>n</italic>
 <sub>
 <italic>spots</italic>
 </sub>
 is the number of spots on the slide). The lines with triangles
 are those obtained for the Cy3 signal (532 nm) and the lines
 with lozenges are for the Cy5 signal (635 nm).</p>
 </caption>
 <graphic xlink:href="1471-2105-10-98-1"/>
 </fig>
 
Thumbnails are available from pmc like so
http://www.pubmedcentral.nih.gov/picrender.fcgi?artid=2681461&blobname=1471-2105-10-98-1.gif

Notice the relationship of the GET parameter blobname=1471-2105-10-98-1.gif and the xml <graphic xlink:href="1471-2105-10-98-1"/>

Full sized images are available from pmc like so:
http://www.pubmedcentral.nih.gov/articlerender.fcgi?artid=2681461&rendertype=figure&id=F1


Notice the relationship of the GET parameter id=1 and the xml <fig position="float" id="F1">


 */

@implementation FullTextViewController
@synthesize	contentView;
@synthesize	busy;
@synthesize	busyText;
@synthesize	fullTextView;
@synthesize	bookmarkButton;
@synthesize	emailButton;
@synthesize	dumpButton;
@synthesize	pdfButton;
@synthesize	myToolbar;
@synthesize	jumpPicker;
@synthesize	jumpPickerContainer;
@synthesize	webToolbar;
@synthesize	backButton;
@synthesize	forwardButton;
@synthesize	refreshButton;
@synthesize	popUpImage;
@synthesize	noDownload;
@synthesize	isPDF;
@synthesize	isAlternate;
@synthesize	parserWarningAlready;
@synthesize	canDownloadPDF, pdfAvailable;
@synthesize	showingPicker;
@synthesize	showingExternalSite;
@synthesize	pickerTop;
@synthesize	ContFrameLand;
@synthesize	ContFramePort;
@synthesize	VShiftLandscape;
@synthesize	VShiftPortrait;
@synthesize	pickerMap;
@synthesize	fullTextSource;
@synthesize	pmcid;
@synthesize	doi;
@synthesize	info;
@synthesize	infoBits;
@synthesize	bmTitleField;
@synthesize	theAuthors;
@synthesize	html;
@synthesize	altHtmlURL;
@synthesize	cacheFile;
@synthesize	documentsDirectory;
@synthesize	loadingMessage;
@synthesize	imageCache;
@synthesize	navFadeTimer;

// we search for the the full tag initally so we can find very specfic one.
// we remove everything after the space to find the closing tag
// then we loop to remove any more
+ (void) removeTags:(NSString  *)tag fromString:(NSMutableString*)htmlString
{
	//LOG(@"%s - IN",__FUNCTION__);
	NSString  *atomicTag = [tag componentsSeparatedByString:@" "][0];
	NSString  *openTag = [NSString stringWithFormat:@"<%@", tag];
	NSString  *closeTag = [NSString stringWithFormat:@"</%@>", atomicTag];
	
	NSRange		openRange = [htmlString rangeOfString:openTag];
	while(1)
	{
		if(openRange.location == NSNotFound)
			return;
		NSRange		closeRange = [htmlString rangeOfString:@">" options:NSLiteralSearch range:
								  NSMakeRange(openRange.location, htmlString.length - openRange.location -1)];
		NSRange		deleteRange = NSMakeRange(openRange.location, closeRange.location - openRange.location + closeRange.length);
		[htmlString deleteCharactersInRange:deleteRange];
		
		deleteRange = [htmlString rangeOfString:closeTag options:NSLiteralSearch range:NSMakeRange(openRange.location, htmlString.length - openRange.location -1)];
		[htmlString deleteCharactersInRange:deleteRange];

		// look for the next one
		openRange = [htmlString rangeOfString:openTag options:NSLiteralSearch range:NSMakeRange(openRange.location, htmlString.length - openRange.location -1)];
	} // while
	//LOG(@"%s - OUT",__FUNCTION__);
} // removeTags: fromString

-(void) disableNavigation:(BOOL)disable 
{
	//LOG(@"%s - IN",__FUNCTION__);
	NSString *state;

    if(disable)
		state = @"disabling";
	else 
		state = @"enabling";
	
	//LOG(@"%s - IN  (%@)",__FUNCTION__,state);
	
	if(disable)
		fullTextView.alpha = 0.25;
	else
		fullTextView.alpha = 1;
		
	if((html == nil) && (!isAlternate))
	{
        for(UIBarButtonItem* bbi in myToolbar.items){
            if (bbi.tag != 100){
                bbi.enabled = NO;
            }
        }
		self.navigationItem.rightBarButtonItem.enabled = NO;
		//LOG(@"%s - OUT (early)",__FUNCTION__);
		return;
	}
    
   for(UIBarButtonItem* bbi in myToolbar.items){
       if (bbi.tag != 100){
           bbi.enabled = !disable;
       }
   }

	if(isAlternate)
		self.navigationItem.rightBarButtonItem.enabled = NO;
	else
		self.navigationItem.rightBarButtonItem.enabled = !noDownload;
		
	if(!disable)
	{
    
		NSDictionary    *existingX = nil;
        if(canDownloadPDF)
		{
			//existingX = [PDFLibraryViewController findArticleWithID:self.pmcid forDB:@"pubmed"];
			//pdfButton.enabled = (existingX == nil);
            //NSLog(@"hello");
		}
		//else
			//pdfButton.enabled = NO;
		
        //pdfButton.enabled = YES;
  
        if(showingExternalSite){
			bookmarkButton.enabled = NO;
        } else {
			NSString  *pmid = [info objectAtPath:@"MedlineCitation/PMID"];
			existingX = [BookMarksController findBookmarkWithID:pmid forDB:@"pubmed"];
			bookmarkButton.enabled = (existingX == nil);
		}
	}
//	self.navigationItem.hidesBackButton = disable;
	//LOG(@"%s - OUT",__FUNCTION__);
	
} // disableNavigation

- (void) searchAgain:(NSNotification*)notification
{
	//LOG(@"%s - IN",__FUNCTION__);
	QueryAgent*	pubmedQuery = [[QueryAgent alloc] initForDB:@""];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFullText:) name:@"PUBMED_FULLTEXT_COMPLETE" object:pubmedQuery];
	[pubmedQuery getFullTextFor:pmcid usingDelegate:self];
	//LOG(@"%s - OUT",__FUNCTION__);

} // searchAgain

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(NSString *) getFullPathInDocumentsDirectory:(NSString  *)fname {
	int c = 0;
	
	NSFileManager   *fileManager    = [NSFileManager defaultManager];
	NSArray         *paths          = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString        *documentsDir   = paths[0];
	NSString        *filePath       = [documentsDir stringByAppendingPathComponent:fname];
	NSString        *basePath       = [documentsDir stringByAppendingPathComponent:fname];
	
    while([fileManager fileExistsAtPath:filePath]) {
		filePath = [basePath stringByAppendingString:[NSString stringWithFormat:@"%d",c++]];
	}
	
	return filePath;
}

- (void)viewDidLoad {
	//NSLog(@"viewDidLoad-IN");

	//LOG(@"%s - IN",__FUNCTION__);

#ifndef __DEBUG_OUTPUT__
		//NSLog(@"DEBUG = true");
	[Flurry logEvent:@"FullText Open"];
#endif
	[super viewDidLoad];
    
	NSFileManager  *fileManager = [NSFileManager defaultManager];
	NSArray        *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	documentsDirectory = paths[0];
	
	BOOL exists = [fileManager fileExistsAtPath:documentsDirectory];
	if (!exists) {
        BOOL success = [fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:nil];
		if (!success) {
			NSAssert(0, @"Failed to create Documents directory.");
		}
	}

	[self disableNavigation:YES];

	NSArray *ArticleIdList = [info objectAtPath:@"PubmedData/ArticleIdList/ArticleId"];
	
    if(ArticleIdList && ![ArticleIdList isKindOfClass:[NSArray class]]){
		ArticleIdList = @[ArticleIdList];
    }
    
	for(id xidType in ArticleIdList) {
		NSString    *xidTypeString = nil;
		
        if(![xidType isKindOfClass:[NSDictionary class]])
			continue;
		
		xidTypeString = xidType[@"IdType"];
		if([xidTypeString.uppercaseString isEqualToString:@"DOI"]) {
			self.doi = xidType[@"Id"];
			break;
		}
	}
	
	NSArray *otherIDs = [info objectAtPath:@"MedlineCitation/OtherID"];
   
    if(otherIDs == nil){
		otherIDs = [NSArray array];
    } else {
        if(![otherIDs isKindOfClass:[NSArray class]]){
            otherIDs = @[otherIDs];
        }
    }
    
	canDownloadPDF = NO;
    
	for(NSString *thisID in otherIDs)
	{
		NSRange r = [thisID rangeOfString:@"[Avail"];
		if([thisID.uppercaseString hasPrefix:@"PMC"] && r.location == NSNotFound) {
			canDownloadPDF = YES;
			break;
		}
	}		
    
    if(self.pdfAvailable == 1){
      canDownloadPDF = YES;
    } else {
        if(self.pdfAvailable == 0){
            canDownloadPDF = NO;
        }
    }
    
    pdfButton.enabled = canDownloadPDF;
    //pdfButton.enabled = YES;

    parserWarningAlready        = NO;
	self.navigationItem.title   = @"Full Text";
	imageCache                  = [[NSMutableDictionary alloc] init];
	
	pickerMap = @[@{@"name": @"Abstract", @"anchor": @"abstract"},
	@{@"name": @"Main", @"anchor": @"main"},
	@{@"name": @"References", @"anchor": @"references"}];
	
	
	UIBarButtonItem *jumpButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Jump",@"")
																	style:UIBarButtonItemStylePlain
																   target:self
																   action:@selector(jump:)];
	
	self.navigationItem.rightBarButtonItem  = jumpButton;
	self.navigationItem.rightBarButtonItem.enabled  = NO;


	UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
	
    if(interfaceOrientation != UIInterfaceOrientationPortrait){
		pickerTop = 44;
    } else {
		pickerTop = 44;
    }
	
	showingPicker = NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popupDone:) name:@"POPUP_DONE" object:nil];
	
	NSRange	available = [pmcid rangeOfString:@"[Avail" options:NSCaseInsensitiveSearch];
	if(pmcid && available.location != NSNotFound) {
		NSString    *ftMessage = [pmcid substringFromIndex:available.location+1];
		
        if([ftMessage hasSuffix:@"]"]){
			ftMessage = [ftMessage substringToIndex:ftMessage.length-1];
        }
		
		UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"Full Text"
														message:ftMessage
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		
		busy.hidden = YES;
		self.navigationItem.hidesBackButton = NO;
		[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(popLater:) userInfo:nil repeats:NO];
	} else {
		QueryAgent  *pubmedQuery = [[QueryAgent alloc] initForDB:@""];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFullText:) name:@"PUBMED_FULLTEXT_COMPLETE" object:pubmedQuery];
		[pubmedQuery getFullTextFor:pmcid usingDelegate:self];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchAgain:) name:@"SEARCH_AGAIN" object:nil];
	//LOG(@"%s - OUT",__FUNCTION__);
 } // viewDidLoad

-(void) popLater:(NSTimer*)timer {
	//LOG(@"%s - IN",__FUNCTION__);
	[self.navigationController popViewControllerAnimated:YES];
	//LOG(@"%s - OUT",__FUNCTION__);
} // popLater

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
	{
		ContFrameLand = CGRectMake(0,0,480,212);
		ContFramePort = CGRectMake(0,0,320,325);
		VShiftLandscape = 37.0;
		VShiftPortrait = 50.0;
        pdfAvailable = -1;
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated 
{
	//NSLog(@"viewWillAppear-IN");
	//LOG(@"%s - IN",__FUNCTION__);
	[super viewWillAppear:animated];
	fullTextView.delegate = self;


	//NSLog(@"viewWillAppear-OUT");
    
    /*
    // Get rid of the jump container
    CGRect jcFrame = jumpPickerContainer.frame;
    jcFrame.origin.y = self.view.bounds.size.height;
    jumpPickerContainer.frame = jcFrame;
    */
	
	//LOG(@"%s - OUT",__FUNCTION__);
} // viewWillAppear




- (void)viewWillDisappear:(BOOL)animated
{
	//NSLog(@"viewWillDisappear-IN");
	//LOG(@"%s - IN",__FUNCTION__);
	[super viewWillDisappear:animated];

	[fullTextView stopLoading];
	fullTextView.delegate = nil;
	busy.hidden = YES;
	
	
	//LOG(@"%s - OUT",__FUNCTION__);
	//NSLog(@"viewWillDisappear-OUT");
} // viewWillDisappear


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if(fromInterfaceOrientation == UIInterfaceOrientationPortrait){
        pickerTop = 44;
    } else {
        pickerTop = 44;
    }

	
	if(showingPicker) {
		CGRect r = jumpPickerContainer.frame;
		r.origin.y = pickerTop;
		jumpPickerContainer.frame = r;
	}
}

- (void)didReceiveMemoryWarning {
	[imageCache removeAllObjects];
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) parserTimeout {
	UIAlertView     *alert = [[UIAlertView alloc] initWithTitle:@"Error"
													message:@"The server is not responding"
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];

	busy.hidden = YES;
	self.navigationItem.hidesBackButton = NO;
} // parserTimeout


- (NSString  *) fullTextSource
{
	//LOG(@"%s - IN",__FUNCTION__);
	//LOG(@"%s - OUT",__FUNCTION__);
	return fullTextSource;
}

- (void) setFullTextSource:(NSString  *) newSource
{
	//LOG(@"%s - IN",__FUNCTION__);
	
	if(newSource == nil)
	{
		fullTextSource = nil;
		return;
	}
	
	fullTextSource = newSource;
	
	PMCRecordParser *gp = [[PMCRecordParser alloc] init];
	[gp parseString:fullTextSource usingDelegate:self];
	//LOG(@"%s - OUT",__FUNCTION__);

} // setFullTextSource

-(void) getFullText:(NSNotification*)notification
{
	//LOG(@"%s - IN",__FUNCTION__);
	NSString    *t = notification.userInfo[@"fulltext"];
#ifdef __DEBUG_OUTPUT__
	//NSLog(t);
#endif
	self.fullTextSource = t;
	//LOG(@"%s - OUT",__FUNCTION__);
}

- (NSString  *) pmcid
{
	return pmcid;
}

- (void) setPmcid:(NSString  *)newid
{
	//LOG(@"%s - IN",__FUNCTION__);
	
	if([newid.uppercaseString hasPrefix:@"PMC"])
		pmcid = [newid substringFromIndex:3];
	else
		pmcid = newid;
	//LOG(@"%s - OUT",__FUNCTION__);
	
}

- (NSString  *) doi
{
	//LOG(@"%s - IN",__FUNCTION__);
	//LOG(@"%s - OUT",__FUNCTION__);
	return doi;
} 

-(void) setDoi:(NSString  *)newdoi
{
	//LOG(@"%s - IN",__FUNCTION__);
	doi = newdoi;
	//LOG(@"%s - OUT",__FUNCTION__);
}

-(IBAction) dumpXML:(id)sender
{
	if(fullTextSource)
		NSLog(@"%@",fullTextSource);
} // dumpXML

-(void) showBusy
{
    busy.hidden = NO;
} // showBusy

-(void) showSavingPDF
{
    busy.hidden = NO;
} // showBusy

-(IBAction) saveAsPDF:(id)sender
{
	//LOG(@"%s - IN",__FUNCTION__);
#ifndef __DEBUG_OUTPUT__
	[Flurry logEvent:@"saveAsPDF"];
#endif
	[self disableNavigation:YES];
	self.navigationItem.rightBarButtonItem.enabled = NO;
	self.navigationItem.hidesBackButton = YES;
	fullTextView.alpha = 0.25;
	//busyText.text = @"Saving PDF Article...";
	//[self performSelectorOnMainThread:@selector(showBusy) withObject:nil waitUntilDone:YES];
	
	[NSThread detachNewThreadSelector:@selector(saveAsPDFThread) toTarget:self withObject:nil];
	//LOG(@"%s - OUT",__FUNCTION__);
} // saveAsPDF

- (void) saveAsPDFThread
{
	//LOG(@"%s - IN",__FUNCTION__);
	//•
	
	NSFileManager   *fileManager = [NSFileManager defaultManager];
	NSString        *pdfPath     = [documentsDirectory stringByAppendingFormat:@"/%@.pdf", self.pmcid];
    NSString        *newPMID  = [info objectAtPath:@"MedlineCitation/PMID"];

    
    id obj = [PDFLibraryViewController findArticleWithID:newPMID forDB:@"pubmed"];
    
   //if(![fileManager fileExistsAtPath:pdfPath])
    if(obj == nil)
	{
        [self performSelectorOnMainThread:@selector(showSavingPDF) withObject:nil waitUntilDone:NO];

		NSString    *pmcURL=[NSString stringWithFormat:@"http://www.pubmedcentral.nih.gov/picrender.fcgi?artid=%@&blobtype=pdf", self.pmcid];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:pmcURL]];
		
		NSData          *theData;
		NSURLResponse   *response;
		NSError         *error;
        NSHTTPURLResponse *hResponse;
		// Make the request
		//NSLog(@"NSURL-10");
		theData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        hResponse = (NSHTTPURLResponse*)response;
        int status = hResponse.statusCode;
        BOOL    isGoodPDF = NO;
        if (status == 200){
            isGoodPDF = YES;
            [theData writeToFile:pdfPath atomically:NO];
        } else {
            isGoodPDF = NO;

        }
    if(!isGoodPDF)
		{
			UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"Full Text"
															message:@"Unable to retrieve the PDF article"
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
			//•
			busy.hidden = YES;
			self.navigationItem.hidesBackButton = NO;
			fullTextView.alpha = 1;
			[self disableNavigation:NO];
			return;
		}
		
    } else {
        UIAlertView*    alert = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                           message:@"This PDF has previously been downloaded and saved."
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [alert show];
        //•
        busy.hidden = YES;
        self.navigationItem.hidesBackButton = NO;
        fullTextView.alpha = 1;
        [self disableNavigation:NO];
        return;
        
    }
	
    NSMutableDictionary     *newInfo = [NSMutableDictionary dictionaryWithDictionary:info];
	NSMutableDictionary     *newCitation = [NSMutableDictionary dictionaryWithDictionary:newInfo[@"MedlineCitation"]];
	NSMutableDictionary     *newArticle = [NSMutableDictionary dictionaryWithDictionary:newCitation[@"Article"]];
	
	if(newInfo[@"notes"])
		[newInfo removeObjectForKey:@"notes"];
	
	newCitation[@"Article"] = newArticle;
	newInfo[@"MedlineCitation"] = newCitation;
	
	[self performSelectorOnMainThread:@selector(saveAsPDFComplete:) withObject:newInfo waitUntilDone:NO];
	
	//LOG(@"%s - OUT",__FUNCTION__);
} // saveAsPDFThread

- (void) saveAsPDFComplete:(NSDictionary*)newInfo
{
	//LOG(@"%s - IN",__FUNCTION__);
	fullTextView.alpha = 1;
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"SAVE_PDF"
																						 object:self
																					   userInfo:newInfo]];
	
	UIAlertView     *alert = [[UIAlertView alloc] initWithTitle:@"Full Text"
													message:@"Saved the PDF article"
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	
	self.navigationItem.hidesBackButton = NO;
	[self disableNavigation:NO];
	
	PDFNotesView  *nv = [[PDFNotesView alloc] initWithNibName:@"NotesView" bundle:nil];
	nv.info = newInfo;
	nv.delegate = self;
	[self.navigationController pushViewController:nv animated:YES];
	[nv toggleEditing:self];
	//LOG(@"%s - OUT",__FUNCTION__);
} // saveAsPDFComplete

-(void) updatePDFInfo:(NSDictionary*)newInfo {
	//LOG(@"%s - IN",__FUNCTION__);
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"SAVE_PDF"
																						 object:self
																					   userInfo:newInfo]];
	//LOG(@"%s - OUT",__FUNCTION__);
} // updateInfo

-(void) updateBookmarkInfo:(NSDictionary*)newInfo {
	//LOG(@"%s - IN",__FUNCTION__);
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ADD_BOOKMARK"
																					 object:self
																				   userInfo:newInfo]];
	//LOG(@"%s - OUT",__FUNCTION__);
} // 

-(IBAction) addAsBookmark:(id)sender {
	//LOG(@"%s - IN",__FUNCTION__);
	NSDictionary    *article = info[@"MedlineCitation"][@"Article"];
	
	UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Bookmark Title" message:@"this gets covered" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
	bmTitleField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
	bmTitleField.text = article[@"ArticleTitle"];
	bmTitleField.backgroundColor = [UIColor whiteColor];
	[myAlertView addSubview:bmTitleField];
	[myAlertView show];
	
	//LOG(@"%s - OUT",__FUNCTION__);
} // addAsBookmark

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	//LOG(@"%s - IN",__FUNCTION__);
	if(buttonIndex != 0)
	{
#ifndef __DEBUG_OUTPUT__
		[Flurry logEvent:@"addAsBookmark"];
#endif
		NSString  *newTitle = bmTitleField.text;
		NSMutableDictionary *newInfo = [NSMutableDictionary dictionaryWithDictionary:info];
		NSMutableDictionary *newCitation = [NSMutableDictionary dictionaryWithDictionary:newInfo[@"MedlineCitation"]];
		NSMutableDictionary *newArticle = [NSMutableDictionary dictionaryWithDictionary:newCitation[@"Article"]];
		
		newArticle[@"ArticleTitle"] = newTitle;
		newCitation[@"Article"] = newArticle;
		newInfo[@"MedlineCitation"] = newCitation;
		
		NotesView   *nv = [[NotesView alloc] initWithNibName:@"NotesView" bundle:nil];
		nv.info = newInfo;
		nv.delegate = self;
		[self.navigationController pushViewController:nv animated:YES];
		[nv toggleEditing:self];
		
	}
	//LOG(@"%s - OUT",__FUNCTION__);
} // clickedButtonAtIndex

- (NSString  *) untangleAuthor:(NSDictionary*)authorDict
{
	//LOG(@"%s - IN",__FUNCTION__);
	NSString    *author = @"";
	NS_DURING
	NSString    *xrefString = @"";
	NSString    *degrees = [authorDict objectAtPath:@"degrees"];
	id			xRefs = [authorDict objectAtPath:@"xref"];
    
	if([xRefs isKindOfClass:[NSString class]])
		xrefString = xRefs;
	else if([xRefs isKindOfClass:[NSDictionary class]])
	{
		xrefString = xRefs[@"sup"];
	}
	else if([xRefs isKindOfClass:[NSArray class]])
	{
		NSArray *xRefsArray = [NSArray array];
		for(NSDictionary*d in xRefs)
		{
			if([d isKindOfClass:[NSDictionary class]])
				xRefsArray = [xRefsArray arrayByAddingObject:d[@"sup"]];
			else
				xRefsArray = [xRefsArray arrayByAddingObject:[NSString stringWithFormat:@"%@", d]];
			
		}
		xrefString = [xRefsArray componentsJoinedByString:@" "];
	} // array
	
	NSString    *givenNames = [authorDict objectAtPath:@"name/given-names"];
	if(givenNames == nil)
		givenNames = [authorDict objectAtPath:@"contrib/name/given-names"];
	if(givenNames == nil)
		givenNames = @"";
	
	NSString    *surname = [authorDict objectAtPath:@"name/surname"];
	if(surname == nil)
		surname = [authorDict objectAtPath:@"contrib/name/surname"];
	if(surname == nil)
		surname = @"";
	
	NSString    *hrefString = [NSString stringWithFormat:@"%@ %@",givenNames, surname];
	NSString    *href = [NSString stringWithFormat:@"<a href=\"orkovauth://%@\">%@ %@</a>", hrefString, givenNames, surname];
	
	author = [NSString stringWithFormat:@"%@%@<sup>%@</sup>",href,(degrees ? [NSString stringWithFormat:@", %@", degrees] : @""),xrefString];

	NS_HANDLER
	[self dumpXML:self];
	if(!parserWarningAlready)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice"
														message:@"There was an error parsing the authors."
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];

		parserWarningAlready = YES;
	}
	NS_ENDHANDLER
	return author;
	//LOG(@"%s - OUT",__FUNCTION__);
} // untangleAuthor

- (NSString  *) untangleAffiliation:(NSDictionary*)affiliationDict
{
	//LOG(@"%s - IN",__FUNCTION__);
	NSString  *affiliation = @"";
	NSString  *label = nil;
	NS_DURING
	if([affiliationDict isKindOfClass:[NSString class]])
		affiliation = [NSString stringWithFormat:@"<div class=\"\">%@</div>", affiliationDict];
	
	else
	{
		NSString  *institution = nil;
		NSString  *addr = affiliationDict[@"addr-line"];
		if([addr isKindOfClass:[NSDictionary class]])
		{
			NSDictionary*	addrX = affiliationDict[@"addr-line"];
			label = addrX[@"sup"];
			addr = addrX[@"value"];
		}
		else
		{
			if(addr == nil)
				addr = affiliationDict[@"value"];
			if(addr == nil)
				addr = @"";
			
			institution = affiliationDict[@"institution"];
			
			label = affiliationDict[@"label"];
			if(label == nil)
				label = @"";
		}
		if(institution == nil)
			affiliation =  [NSString stringWithFormat:@"<div class=\"fm-affl\"><sup>%@</sup>%@</div>",
							label, addr];
		else
			affiliation =  [NSString stringWithFormat:@"<div class=\"fm-affl\"><sup>%@</sup>%@<br/>%@</div>",
							label, institution, addr];

	}
	NS_HANDLER
	[self dumpXML:self];
	if(!parserWarningAlready)
	{
		UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"Notice"
														message:@"There was an error parsing the affiliations."
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		//•
		parserWarningAlready = YES;
	}
	NS_ENDHANDLER
	//LOG(@"%s - OUT",__FUNCTION__);
	
	return affiliation;
} // untangleAffiliation

- (NSString  *) authorsFromPersonGroup:(NSDictionary*)personGroup
{
	//LOG(@"%s - IN",__FUNCTION__);
	NSArray  *nameStrings = [NSArray array];
	NSArray  *names = personGroup[@"name"];
	if(names == nil)
		names = [NSArray array];
	if([names isKindOfClass:[NSDictionary class]])
		names = @[names];
	
	for(NSDictionary*d in names)
	{
		NS_DURING
		nameStrings = [nameStrings arrayByAddingObject:[NSString stringWithFormat:@"%@ %@", d[@"surname"], d[@"given-names"]]];
		NS_HANDLER
		//NSLog(@"barfed getting reference name from person-group");
		NS_ENDHANDLER
	}
	NSString  *citationText = [nameStrings componentsJoinedByString:@", "];
	//LOG(@"%s - OUT",__FUNCTION__);
	return citationText;
} // authorsFromPersonGroup

- (NSString  *) untangleReference:(NSDictionary*)referenceDict manualLabel:(int)xLabel
{
	//LOG(@"%s - IN",__FUNCTION__);
	NSString        *reference = @"";
	
	NS_DURING
	NSString        *label = referenceDict[@"label"];
	NSDictionary    *citation = referenceDict[@"citation"];
	
	if(citation == nil)
		citation = referenceDict[@"mixed-citation"];
	
	if(citation == nil)
		citation = referenceDict[@"element-citation"];
	
	if(citation && [citation isKindOfClass:[NSArray class]])
		citation = ((NSArray*) citation)[0];
	
	NSString        *citationType = @"";
	NSString        *citationText = @"";
	NSString        *authorText = nil;
	NSString        *articleTitle = @"";
	NSDictionary    *personGroup = nil;
	NSString        *year = nil;
	
	if([citation isKindOfClass:[NSDictionary class]])
	{
		citationType = citation[@"citation-type"];
		citationText = citation[@"citation-text"];
		authorText = nil;
		articleTitle = citation[@"article-title"];
		personGroup = citation[@"person-group"];
		year = citation[@"year"];
	}
	else if([citation isKindOfClass:[NSString class]])
	{
		citationType = @"other";
		citationText = (NSString  *)citation;
	}
	
	if(!year)
		year = @"";

	if(!label)
		label = [NSString stringWithFormat:@"%d", xLabel];
	
	if(personGroup)
	{
		if([personGroup isKindOfClass:[NSArray class]])
		{
			NSArray *xtemp = (NSArray*)personGroup;
			authorText = [self authorsFromPersonGroup:xtemp[0]];
		}
		else
			authorText = [self authorsFromPersonGroup:personGroup];
	}
	//NSLog(@"%@", referenceDict);
	if(citationType == nil)
		citationType = @"journal";
	
	if([citationType isEqualToString:@"journal"])
	{
		NSString  *	source = citation[@"source"];
		if(!source)
			source = @"";
		
		NSString  *	volume = citation[@"volume"];
		if(!volume)
			volume = @"";
		
		NSString  *	fpage = citation[@"fpage"];
		NSString  *	lpage = citation[@"lpage"];
		NSString  *	pubid = citation[@"pub-id"];
		
		NSString  *	prange = nil;
		if(fpage && lpage)
			prange = [NSString stringWithFormat:@"%@-%@", fpage, lpage];
		else if(fpage)
			prange = fpage;
#if 0		
		reference = [NSString stringWithFormat:@"<tr><td width=\"20px\" valign=\"top\">%@</td><td>%@ <i>%@</i> %@:%@,%@ [%@]</td></tr>",
					 label, authorText, source, volume, fpage, year, pubid];
#else
		reference = [NSString stringWithFormat:@"<tr><td width=\"20px\" valign=\"top\">%@</td><td>", label];
		if(authorText)
			reference = [reference stringByAppendingString:authorText];		// prefered format
		else if(citationText)
			reference = [reference stringByAppendingFormat:@" %@", citationText];
		
		if(articleTitle)
			reference = [reference stringByAppendingFormat:@" %@", articleTitle];
		
		reference = [reference stringByAppendingFormat:@" <i>%@</i> %@;<b>%@</b>", source, year, volume];
		
		if(prange)
			reference = [reference stringByAppendingFormat:@":%@", prange];
		if(pubid && [pubid isKindOfClass:[NSArray class]])
		{
			NSArray  *tmpPubArray = [NSArray array];
			for(NSString  *s in (NSArray*) pubid)
			{
#ifdef __DEBUG_OUTPUT__
				//NSLog(@"%@", s);
#endif
				tmpPubArray = [tmpPubArray arrayByAddingObject:s];
			}
			pubid = [tmpPubArray componentsJoinedByString:@", "];
		}
		if(pubid)
			reference = [reference stringByAppendingFormat:@". [%@]", pubid];
		
		reference = [reference stringByAppendingString:@"</td></tr>"];
#endif
	}
	else if([citationType isEqualToString:@"book"])
	{
		NSString  *	publisherName = citation[@"publisher-name"];
		if(!publisherName)
			publisherName = @"";
		
		NSString  *	publisherLoc = citation[@"publisher-loc"];
		if(!publisherLoc)
			publisherLoc = @"";
		
		
		reference = [NSString stringWithFormat:@"<tr><td width=\"20px\" valign=\"top\">%@</td><td>%@, %@; %@:%@. %@</td></tr>",
					 label, authorText, publisherName, publisherLoc, year, articleTitle];
	}
	else if([citationType isEqualToString:@"other"])
	{
		reference = [NSString stringWithFormat:@"<tr><td width=\"20px\" valign=\"top\">%@</td><td>%@</td></tr>", label, citationText];
	}
	
	NS_HANDLER
	//NSLog(@"Refernce error: %@", [localException reason]);
	if(!parserWarningAlready)
	{
		UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"Notice"
														message:@"There was an error parsing the references."
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		//•
		parserWarningAlready = YES;
	}
	NS_ENDHANDLER
	//LOG(@"%s - OUT",__FUNCTION__);
	
	return reference;
} // untangleReference

- (NSMutableString*)findBlockWithTag:(NSString  *)tag
{
	//LOG(@"%s - IN tag:%@",__FUNCTION__,tag);
	NSRange				tagStart = [fullTextSource rangeOfString:[NSString stringWithFormat:@"<%@ ", tag]];
	if(tagStart.location == NSNotFound)
		tagStart = [fullTextSource rangeOfString:[NSString stringWithFormat:@"<%@>", tag]];
    if(tagStart.location == NSNotFound)
    {
        // The tag is not in the string
        //LOG(@"%s - Cannot find tag:%@",__FUNCTION__,tag);
        return nil;
    }
	NSRange				tagEnd = [fullTextSource rangeOfString:[NSString stringWithFormat:@"</%@", tag]];
	NSRange				tagRange = {tagStart.location, (tagEnd.location - tagStart.location)};
	NSMutableString  *tagText = nil;
	
	NS_DURING
	tagText = [NSMutableString stringWithString:[fullTextSource substringWithRange:tagRange]];
	NSRange clip = [tagText rangeOfString:@">"];
	if(clip.location != NSNotFound)
	{
		clip.length = clip.location+1;
		clip.location = 0;
		[tagText deleteCharactersInRange:clip];
	}
	NS_HANDLER
	NS_ENDHANDLER
	//LOG(@"%s - OUT tag:%@",__FUNCTION__,tag);
	
	return tagText;
} // findBlockWithTag

- (NSMutableString*)findBlockWithTag:(NSString  *)tag inString:(NSString  *)s includingTag:(BOOL)includingTag
{
	//LOG(@"%s - IN tag:%@",__FUNCTION__,tag);
	//NSLog(@"STRING:%@",s);

	NSString    *fullpath;
	NSRange	    tagStart = [s rangeOfString:[NSString stringWithFormat:@"<%@ ", tag]];
	//int len = [s length];
	
    if(tagStart.location == NSNotFound){
		tagStart = [s rangeOfString:[NSString stringWithFormat:@"<%@>", tag]];
    }
	
	if(tagStart.location == NSNotFound) {
		//NSLog(@"Tag Not Found: %@", tag);
		
	//	fullpath = [self getFullPathInDocumentsDirectory:@"OutFile"];
	//	[s writeToFile:fullpath atomically:YES encoding:NSASCIIStringEncoding error:nil];
		return nil;
		
	}
	
	NSRange	tagEnd = [s rangeOfString:[NSString stringWithFormat:@"</%@>", tag]];
	if(tagEnd.location == NSNotFound)
		tagEnd = [s rangeOfString:@"/>" options:NSLiteralSearch range:NSMakeRange(tagStart.location, s.length - tagStart.location)];
	
	NSRange				tagRange = {tagStart.location, (tagEnd.location+tagEnd.length - tagStart.location)};
	NSMutableString  *tagText = nil;
	
	NS_DURING
	tagText = [NSMutableString stringWithString:[s substringWithRange:tagRange]];
	NS_HANDLER
	NS_ENDHANDLER
	
	NS_DURING
	if(!includingTag)
	{
		NSRange clip = [tagText rangeOfString:@">"];
		if(clip.location != NSNotFound)
		{
			clip.length = clip.location+1;
			clip.location = 0;
			[tagText deleteCharactersInRange:clip];
		}
	}
	NS_HANDLER
	NS_ENDHANDLER
	//LOG(@"%s - OUT",__FUNCTION__);
	
	if(tagText && tagText.length == 0)
		return nil;
	
	return tagText;
} // findBlockWithTag

- (void)replace:(NSMutableString*)s tags:(NSString  *)oldTag withDiv:(NSString  *)newdiv
{
	//LOG(@"%s - IN  oldtag: %@",__FUNCTION__,oldTag);
	NSString  *openTag = [NSString stringWithFormat:@"<%@>", oldTag];
	NSString  *closeTag = [NSString stringWithFormat:@"</%@>", oldTag];
	NSString  *divClass = [NSString stringWithFormat:@"<div class=\"%@\">", newdiv];
	
	[s replaceOccurrencesOfString:openTag withString:divClass options:NSCaseInsensitiveSearch range:NSMakeRange(0, s.length)];
	[s replaceOccurrencesOfString:closeTag withString:@"</div>" options:NSCaseInsensitiveSearch range:NSMakeRange(0, s.length)];
	//LOG(@"%s - OUT",__FUNCTION__);
} // replace:tags:withNewTags

- (BOOL)fixFigure:(NSMutableString*)bodyText {
	//LOG(@"%s - IN",__FUNCTION__);
	NSMutableString     *originalBlock = [self findBlockWithTag:@"fig" inString:bodyText includingTag:YES];
	
    if(originalBlock == nil){
		//LOG(@"%s - OUT early",__FUNCTION__);
		return NO;
	}
	
	NSMutableString  *label   = [self findBlockWithTag:@"label" inString:originalBlock includingTag:YES];
	NSMutableString  *caption = [self findBlockWithTag:@"caption" inString:originalBlock includingTag:NO];
	NSMutableString  *title   = [self findBlockWithTag:@"title" inString:originalBlock includingTag:NO];
	NSMutableString  *graphic = [self findBlockWithTag:@"graphic" inString:originalBlock includingTag:YES];
	NSMutableString  *newBlock = [NSMutableString stringWithString:@"<div class=\"orkovFigure\">\n<table width=\"100%%\">\n<tr>\n"];
	[newBlock appendFormat:@"<td>%@</td>\n", (graphic ? graphic : @"&nbsp;")];
	[newBlock appendFormat:@"<td>%@<br/>\n", (label ? label : @"&nbsp;")];
    if(title){
		[newBlock appendFormat:@"<p>%@</p></td></tr></table>\n</div>\n", title];
    } else {
		[newBlock appendFormat:@"%@</td></tr></table>\n</div>\n", (caption ? caption : @"&nbsp;")];
    }
	
	[bodyText replaceOccurrencesOfString:originalBlock withString:newBlock options:NSLiteralSearch range:NSMakeRange(0, bodyText.length)];
	//LOG(@"%s - OUT",__FUNCTION__);
	return YES;
} // fixFigure

-(NSMutableString*) fixImageLinks:(NSString  *)bodyText {
	//LOG(@"%s - IN",__FUNCTION__);
	
//	Need to catch all tags that start with graphic
	NSMutableArray*	chunks = [NSMutableArray arrayWithArray:[bodyText componentsSeparatedByString:@"<graphic "]];
	for(int i=1;i<chunks.count;i++) {
		NSMutableString  *s = [NSMutableString stringWithString:chunks[i]];
		NSRange				xrefRange = [s rangeOfString:@"xlink:href=\""];
		xrefRange.length += xrefRange.location;
		xrefRange.location = 0;
		[s deleteCharactersInRange:xrefRange];
		
		NSRange				tagClose = [s rangeOfString:@">"];
		NSRange				imageEnd = [s rangeOfString:@"\""];
		NSString  *		baseImageName = [s substringToIndex:imageEnd.location];
		NSString  *		baseImageNameUC = baseImageName.uppercaseString;
		BOOL				hasImageType = ([baseImageNameUC hasSuffix:@".JPG"] || [baseImageNameUC hasSuffix:@".GIF"] || [baseImageNameUC hasSuffix:@".PNG"]);
		
		NSString  *		replacementString;
		if(hasImageType)
			replacementString = [NSString stringWithFormat:@"<img src=\"http://www.pubmedcentral.nih.gov/picrender.fcgi?artid=%@&blobname=%@\"/>", pmcid, baseImageName];
		else
			replacementString = [NSString stringWithFormat:@"<a href=\"orkovBigImage://www.pubmedcentral.nih.gov/picrender.fcgi?artid=%@&blobname=%@.jpg\"><img src=\"http://www.pubmedcentral.nih.gov/picrender.fcgi?artid=%@&blobname=%@.gif\"/></a>", pmcid, baseImageName, pmcid, baseImageName];
		
		tagClose.length = tagClose.location+1;
		tagClose.location = 0;
		[s deleteCharactersInRange:tagClose];
		[s insertString:replacementString atIndex:0];
		chunks[i] = s;
	} // for
	
	NSMutableString  *s = [NSMutableString stringWithString:[chunks componentsJoinedByString:@"\n"]];
	//LOG(@"%s - OUT",__FUNCTION__);
	return s;
} // fixImageLinks

-(BOOL) tryLoadingPDF {
	//LOG(@"%s - IN",__FUNCTION__);
	isPDF = NO;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSString *pdfPath = [documentsDirectory stringByAppendingFormat:@"/%@.pdf", self.pmcid];
	if([fileManager fileExistsAtPath:pdfPath]) {
		busyText.text = @"Loading PDF Article...";
		isPDF = YES;
		isAlternate = YES;
		html = nil;
		BOOL	isGoodPDF = NO;
        NSData *td = [fileManager contentsAtPath:pdfPath];
        if(td.length > 100)
            isGoodPDF = YES;

		if(isGoodPDF)
		{
#ifndef __DEBUG_OUTPUT__
	[Flurry logEvent:@"Load PDF"];
#endif
			fullTextView.scalesPageToFit = YES;
			[fullTextView loadRequest :[NSURLRequest requestWithURL:[NSURL fileURLWithPath:pdfPath]]];
		}
		else
		{
#ifndef __DEBUG_OUTPUT__
	[Flurry logEvent:@"Load PDF Error"];
#endif
			UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"Full Text"
															message:@"Unable to retrieve the article"
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
			//•
			self.navigationItem.hidesBackButton = NO;
		}
		[self disableNavigation:NO];
	}
	busy.hidden = YES;
	//LOG(@"%s - OUT",__FUNCTION__);
	return isPDF;
	
} // tryLoadingPDF

-(void) getParserResults:(NSDictionary*)tResults {
	//LOG(@"%s - IN",__FUNCTION__);
	busyText.text = @"Loading Full Text Article...";
	infoBits = tResults;

    NSDictionary    *contributors   = infoBits[@"contributors"];
	NSArray         *authors        = contributors[@"author"];
	NSArray         *affiliations   = infoBits[@"affiliations"];
	
	NSArray  *references = [infoBits objectAtPath:@"article/back/ref-list/ref"];
	if(references == nil) {
		//NSLog(@"references = nil, init to empty array");
		references = [NSArray array];
	}
	
	if(references && [references isKindOfClass:[NSDictionary class]]){
		references = @[references];
		//NSLog(@"set references to arraywithobject:references");
	}
	
	NSArray  *referenceStrings = [NSArray array];
	int	xLabel = 1;

	NSString *ts;
	//NSLog(@"iterate through references and populate referenceStrings");
	for(NSDictionary*d in references) {
		ts = [self untangleReference:d manualLabel:xLabel++];
		//NSLog(@"  item %d  : %@",ic++,ts );
		referenceStrings = [referenceStrings arrayByAddingObject:ts];
	}

	//NSLog(@"Initialize referenceString = nil");
	NSString  *referenceString = nil;
	if(referenceStrings.count > 1) {
		//NSLog(@"[referenceStrings count] > 1");
		referenceString  = [NSString stringWithFormat:@"<table width=\"100%%\" border=\"0\" cellspacing=\"6\" cellpadding=\"0\">%@</table>",[referenceStrings componentsJoinedByString:@"\n"]];
    } else {
		if(referenceStrings.count == 1) {
			//NSLog(@"[referenceStrings count] = 1");			
			referenceString = referenceStrings[0];
		}
    }
    
	NSArray  *authorStrings = [NSArray array];
	//NSLog(@"iterate through authors and populate authorStrings array");
	for(NSDictionary*d in authors) {
		ts = [self untangleAuthor:d];
		authorStrings = [authorStrings arrayByAddingObject:ts];
	//	authorStrings = [authorStrings arrayByAddingObject:[self untangleAuthor:d]];
	}
	
	self.theAuthors = [authorStrings componentsJoinedByString:@"<br/>"];
	//NSLog(@"self.theAuthors: %@",self.theAuthors);
	
	//NSLog(@"Initialize affiliationStrings array");
	NSArray     *affiliationStrings = [NSArray array];
	NSString    *affiliationString  = @"";
	
	//NSLog(@"iterate through affiliations and populate affiliationStrings array");
	for(NSDictionary* aiffDict in affiliations) {
		ts                  = [self untangleAffiliation:aiffDict];
		affiliationStrings  = [affiliationStrings arrayByAddingObject:ts];
	//	affiliationStrings = [affiliationStrings arrayByAddingObject:[self untangleAffiliation:aiffDict]];
	}

	affiliationString  = [affiliationStrings componentsJoinedByString:@"<br/>\n"];
	
	//NSLog(@"affiliationString: %@", affiliationString);
	
	//NSLog(@"find apbstract tag");
	
	NSMutableString  *abstract = [self findBlockWithTag:@"abstract"];
	//NSLog(@"abstract = %@", abstract);
	if(abstract) {
		//NSLog(@"abstract = %@", abstract);
		[self replace:abstract tags:@"title" withDiv:@"title"];
		[self replace:abstract tags:@"abstract" withDiv:@"abstract"];
	} else {
		abstract = [[NSMutableString alloc ] initWithString:@""];
		//NSLog(@"set abstract = empty string");
	}
	
	NSMutableString  *abstitle  = [self findBlockWithTag:@"article-title"];
	NSMutableString  *copyright = [self findBlockWithTag:@"copyright-statement"];
	NSMutableString  *bodyText  = [self findBlockWithTag:@"body"];

	//NSLog(@"abstitle = %@", abstitle);
	//NSLog(@"copyright = %@", copyright);
	//NSLog(@"bodyText = %@", bodyText);
	
	isPDF = NO;
	isAlternate = NO;
	showingExternalSite = NO;

	if(bodyText == nil && doi) {
		//NSLog(@"bodyText == nil && doi");
		html = nil;
		fullTextView.scalesPageToFit = YES;
		isAlternate = YES;
		showingExternalSite = YES;
		self.altHtmlURL = [NSString stringWithFormat:@"http://dx.doi.org/%@", doi];
		[fullTextView loadRequest :[NSURLRequest requestWithURL:[NSURL URLWithString:altHtmlURL]]];
	} else {
		if(bodyText == nil) {
            //NSLog(@"bodyText == nil");
            noDownload = YES;
            fullTextView.alpha = 0.25;

            busyText.text = @"Loading Alternate PDF Article...";
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            NSString *pdfPath = [documentsDirectory stringByAppendingFormat:@"/%@.pdf", self.pmcid];
            if(![fileManager fileExistsAtPath:pdfPath]) {
                NSString    *pmcURL=[NSString stringWithFormat:@"http://www.pubmedcentral.nih.gov/picrender.fcgi?artid=%@&blobtype=pdf", self.pmcid];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:pmcURL]];
                fullTextView.scalesPageToFit = YES;
                
                NSData          *theData;
                NSURLResponse   *response;
                NSError         *error;
                  // Make the request
                //NSLog(@"NSURL-11");
                theData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                [theData writeToFile:pdfPath atomically:NO];
            }
            BOOL	isGoodPDF = NO;
            if([fileManager fileExistsAtPath:pdfPath]) {
                NSData *td = [fileManager contentsAtPath:pdfPath];
                if(td.length > 100)
                    isGoodPDF = YES;
            }
            if(isGoodPDF) {
                isPDF = YES;
                isAlternate = YES;
                html = nil;
                [fullTextView loadRequest :[NSURLRequest requestWithURL:[NSURL fileURLWithPath:pdfPath]]];
            } else {
                UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"Full Text"
                                                                message:@"Unable to retrieve the article"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                busy.hidden = YES;
                self.navigationItem.hidesBackButton = NO;
            }
        } else {
		//NSLog(@"bodyText != nil");
		while([self fixFigure:bodyText])
			;
		noDownload = NO;
	
		if(copyright == nil)
            copyright = [[NSMutableString alloc ] initWithString:@""];
		
        if(abstitle == nil){
            abstitle = [[NSMutableString alloc ] initWithString:@""];
        }
		
		NSArray  *otherIDs = [info objectAtPath:@"MedlineCitation/OtherID"];
        if(otherIDs == nil){
			otherIDs = [NSArray array];
        }
            
		if(![otherIDs isKindOfClass:[NSArray class]])
			otherIDs = @[otherIDs];
		
		NSArray  *pubIDs = [NSArray array];
		for(NSString  *thisID in otherIDs) {
			if([thisID.uppercaseString hasPrefix:@"PMC"]) {
				pubIDs = [pubIDs arrayByAddingObject:[NSString stringWithFormat:@"<span class=\"doc-number\">PubMed Central ID %@</span><br/>", thisID]];
            } else {
				pubIDs = [pubIDs arrayByAddingObject:[NSString stringWithFormat:@"<span class=\"doc-number\">Journal ID %@</span><br/>", thisID]];
            }
		}		
		
		NSString  *pubIDstring = @"";
		pubIDstring = [NSString stringWithFormat:@"<p><hr/>PubMed ID %@<br/>%@<br/><a href=\"https://docline.gov/loansome/login.cfm\" ><img src=\"https://docline.gov/loansome/images/sub_logo.gif\"/> Order from NLM Loansome</a><br/></p><hr/>\n", [info objectAtPath:@"MedlineCitation/PMID"],
						   [pubIDs componentsJoinedByString:@"\n"]];

        if(theAuthors == nil){
			self.theAuthors = @"";
        }
		
        if(abstract == nil){
            abstract = [[NSMutableString alloc ] initWithString:@""];
        }
		
		[self replace:bodyText tags:@"title" withDiv:@"title"];
		NSString  *imageFetchTemplate = [NSString stringWithFormat:@"img src=\"http://www.pubmedcentral.nih.gov/picrender.fcgi?artid=%@&blobname=", pmcid];
		[bodyText replaceOccurrencesOfString:@"inline-graphic xlink:href=\"" withString:imageFetchTemplate options:NSCaseInsensitiveSearch range:NSMakeRange(0, bodyText.length)];
		bodyText = [self fixImageLinks:bodyText];
		
        NSString  *header = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fullTextHeader" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];

		
        
        html = [NSString stringWithFormat:@"%@<body onload=\"findSections();\"><div class=\"fm-copyright\"><p>%@</p></div><div class=\"fm-title\">%@</div>\n<span class=\"doc-number\">%@</span>\n<div class=\"fm-author\">%@</div>\n<div class=\"fm-affl\">%@</div>\n\n<abstract><div class=\"title\">Abstract</div>\n%@</abstract>\n%@\n", 
				header, copyright, abstitle, pubIDstring, theAuthors, affiliationString, abstract, bodyText];
		if(referenceString)
			html = [html stringByAppendingFormat:@"<div class=\"title\">References</div>\n%@\n", referenceString];

		html = [html stringByAppendingString:@"</body></html>"];
		
		[fullTextView loadHTMLString:html baseURL:nil];
		
		if(noDownload) {
			UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"Notice"
															message:@"The publisher of this article does not allow downloading of the full text through PubMed."
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
                [alert show];
			}
	}
}
//	[self disableNavigation:NO];
	//LOG(@"%s - OUT",__FUNCTION__);

} // getParserResults

-(void) parserError:(NSException*)localExcaption {
	//NSLog([localExcaption reason]);
} // 

-(IBAction) sendAsEmail:(id)sender {
#ifndef __DEBUG_OUTPUT__
	[Flurry logEvent:@"sendAsEmail"];
#endif

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
	picker.navigationBar.tintColor = ORKOV_TINT_COLOR;
	picker.mailComposeDelegate = self;
	
	NSString  *title = [info objectAtPath:@"MedlineCitation/Article/ArticleTitle"];
    if(title == nil){
		title = @"";
    }
	
	[picker setSubject:[NSString stringWithFormat:@"Orkov Pubmed Full Text Article %@", title]];
	
	if(isPDF) {
		NSString *pdfPath = [documentsDirectory stringByAppendingFormat:@"/%@.pdf", self.pmcid];
		[picker addAttachmentData:[NSData dataWithContentsOfFile:pdfPath] mimeType:@"application/pdf" fileName:pdfPath.pathComponents.lastObject];
	}
	else if(altHtmlURL) {
		NSString  *currentURL = (fullTextView.request).URL.description;
		NSString  *currentTitle = [fullTextView stringByEvaluatingJavaScriptFromString:@"function gt() { return document.title;} gt();"];
		NSString  *emailBody = [NSString stringWithFormat:@"<html><head></head><body><a href=\"%@\">%@</a></body></html>", currentURL, currentTitle];
		[picker setMessageBody:emailBody isHTML:YES];
	} else {
		// Fill out the email body text
		NSMutableString	*emailBody = [NSMutableString stringWithString:html];
		[emailBody replaceOccurrencesOfString:@"orkovBigImage://" withString:@"http://" options:NSLiteralSearch range:NSMakeRange(0, emailBody.length)];
		[FullTextViewController removeTags:@"a href=\"orkovauth" fromString:emailBody];
		[picker setMessageBody:emailBody isHTML:YES];
	}
	
	[self presentModalViewController:picker animated:YES];
} // sendAsEmail

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissModalViewControllerAnimated:YES];
} // mailComposeController

- (IBAction) back:(id)sender {
	//LOG(@"%s - IN",__FUNCTION__);
	[fullTextView goBack];
	//LOG(@"%s - OUT",__FUNCTION__);
} // back

- (IBAction) next:(id)sender {
	//LOG(@"%s - IN",__FUNCTION__);
	[fullTextView goForward];
	//LOG(@"%s - OUT",__FUNCTION__);
} // next

- (IBAction) refresh:(id)sender {
	//LOG(@"%s - IN",__FUNCTION__);
	[fullTextView reload];
	//LOG(@"%s - OUT",__FUNCTION__);
} // refresh

-(void) showControls {
	//LOG(@"%s - IN",__FUNCTION__);

	if(!showingExternalSite) {
		//LOG(@"%s - OUT early",__FUNCTION__);
		return;
	}
	
	if(webToolbar.hidden) {
		[UIView beginAnimations:nil context:@"showtoolbar"];
		webToolbar.alpha = 0;
		webToolbar.hidden = !webToolbar.hidden;
		
		[UIView setAnimationDuration:0.3];
		webToolbar.alpha = 1;
		[UIView commitAnimations];
		
		navFadeTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(fadeControls:) userInfo:nil repeats:NO];
	} else {
		if(navFadeTimer)
			[navFadeTimer invalidate];
		navFadeTimer = nil;
		
		[UIView beginAnimations:nil context:@"hidetoolbar"];
		webToolbar.hidden = !webToolbar.hidden;
		[UIView setAnimationDuration:0.3];
		webToolbar.alpha = 0;
		[UIView commitAnimations];
	}
	//LOG(@"%s - OUT",__FUNCTION__);
} // showControls

- (void) fadeControls:(NSTimer*)timer {
	//LOG(@"%s - IN",__FUNCTION__);
	navFadeTimer = nil;
	
	[UIView beginAnimations:nil context:@"hidetoolbar"];
	[UIView setAnimationDuration:0.3];
	webToolbar.alpha = 0;
	[UIView commitAnimations];
	[NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(_hideControls:) userInfo:nil repeats:NO];
	//LOG(@"%s - OUT",__FUNCTION__);
} // fadeControls

- (void) _hideControls:(NSTimer*)timer {
	webToolbar.hidden = YES;
} // _hideControls

#pragma mark WebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView; {
	//LOG(@"%s - IN",__FUNCTION__);
	if(noDownload) {
		busyText.text = @"Loading PDF Article...";
		busy.hidden = NO;
	} else if(showingExternalSite)
	{
		busyText.text = @"Loading External Page...";
		busy.hidden = NO;
	}
	backButton.enabled = fullTextView.canGoBack;
	forwardButton.enabled = fullTextView.canGoForward;
	refreshButton.enabled = NO;
	//LOG(@"%s - OUT",__FUNCTION__);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	//LOG(@"%s - IN",__FUNCTION__);
	[self disableNavigation:NO];
	self.navigationItem.hidesBackButton = NO;
	busy.hidden = YES;
	
//    NSLog(@"webload finised");
//    NSLog(@"pdfAvailable: %d",self.pdfAvailable);
  
	backButton.enabled = fullTextView.canGoBack;
	forwardButton.enabled = fullTextView.canGoForward;
	refreshButton.enabled = YES;
	//LOG(@"%s - OUT",__FUNCTION__);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	//LOG(@"%s - IN",__FUNCTION__);
#if __DEBUG_OUTPUT__
	//NSLog(@"didFailLoadWithError %@",[error localizedDescription]);
#endif
	busy.hidden = YES;
	self.navigationItem.hidesBackButton = NO;
	//LOG(@"%s - OUT",__FUNCTION__);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{	
	//LOG(@"%s - IN",__FUNCTION__);
	
    NSURL       *dest = request.URL;
	BOOL		isLoansome = NO;
	NSString    *urlScheme;
	
    if(dest) {
        urlScheme = dest.scheme.lowercaseString;
		NSRange r = [dest.host rangeOfString:@"docline.gov"];
		isLoansome = (r.location != NSNotFound);
	}

	if(navigationType == UIWebViewNavigationTypeLinkClicked) {
		NSString    *resourceSpecifier = [[dest.resourceSpecifier substringFromIndex:2] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];

		if([urlScheme isEqualToString:@"orkovauth"]) {
			ResultsController   *aViewController = [[ResultsController alloc] initWithNibName:@"ResultsController" bundle:nil];
			[self.navigationController pushViewController:aViewController animated:YES];
			NSString    *searchTerm = [NSString stringWithFormat:@"%@[AU]+AND+(loattrfull+text[sb]+AND+loattrfree+full+text[sb]+AND+hasabstract[text]", resourceSpecifier];
			[aViewController searchFor:searchTerm];
		} else {
            if([urlScheme isEqualToString:@"orkovbigimage"]) {
                [self disableNavigation:YES];
                busy.hidden = YES;
                self.navigationItem.rightBarButtonItem.enabled = NO;
                NSString  *urlString = [NSString stringWithFormat:@"http://%@", resourceSpecifier];
                [NSThread detachNewThreadSelector:@selector(loadRemoteImage:) toTarget:self withObject:urlString];
            } else {
                if(isLoansome) {
                    [fullTextView stopLoading];
                    LoansomeView    *lonesomeView = [[LoansomeView alloc] initWithNibName:@"LoansomeView" bundle:nil];
                    [self presentModalViewController: lonesomeView animated:YES];
                } else {
                    if(showingExternalSite) {
                        return YES;
                    } else {
                        [[UIApplication sharedApplication] openURL:dest];
                    }
                }
            }
        }
		//LOG(@"%s - OUT early",__FUNCTION__);

		return NO;
	}
	//LOG(@"%s - OUT",__FUNCTION__);

	return YES;
}

-(void) popupDone:(NSNotification*)notification {
	//LOG(@"%s - IN",__FUNCTION__);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:BIG_IMAGE_FADE];
        fullTextView.alpha = 1.0;
        popUpImage.alpha = 0;
        [UIView commitAnimations];
        [self disableNavigation:NO];
    });
	//LOG(@"%s - OUT",__FUNCTION__);
}
- (void) loadRemoteImage:(NSString  *)urlString {
	//LOG(@"%s - IN",__FUNCTION__);
	NSError *error = nil;
	UIImage *cachedImage = imageCache[urlString];
    dispatch_async(dispatch_get_main_queue(), ^{
        popUpImage.alpha = 0;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:BIG_IMAGE_FADE];
    });


	if(!cachedImage) {
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        NSData        *theData;
		NSURLResponse *response;
		
		theData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		
		if(!error) {
			cachedImage = [UIImage imageWithData:theData];
			imageCache[urlString] = cachedImage;
		}
	}
	
	if(!error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            popUpImage.image = cachedImage;
            popUpImage.hidden = NO;
            popUpImage.alpha = 1;
            fullTextView.alpha = 0.25;
        });

	}

	[UIView commitAnimations];
	//LOG(@"%s - OUT",__FUNCTION__);
} // loadRemoteImage

#pragma mark Picker stuff
- (IBAction) jump:(id)sender {
	//LOG(@"%s - IN",__FUNCTION__);

#ifndef __DEBUG_OUTPUT__
	[Flurry logEvent:@"jump"];
#endif
	[self disableNavigation:YES];
	busy.hidden = YES;
	self.navigationItem.rightBarButtonItem.enabled = NO;
	self.navigationItem.hidesBackButton = YES;

	NSString *anchorString = [fullTextView stringByEvaluatingJavaScriptFromString:@"getAnchors();"];
	NSArray  *anchors = [anchorString componentsSeparatedByString:@"#;*"];
	
	pickerMap = [NSArray array];
	for(NSString  *anchor in anchors) {
		NSString    *pettyName;
        if([anchor hasPrefix:@"_"]){
			pettyName = [anchor stringByReplacingOccurrencesOfString:@"_" withString:@"  "];
        } else {
			pettyName = anchor;
        }
		
		pickerMap = [pickerMap arrayByAddingObject:
					 @{@"name": pettyName, @"anchor": anchor}];
	}

	[jumpPicker reloadAllComponents];
    
    jumpPickerContainer.hidden = NO;
    CGRect startFrame = jumpPickerContainer.frame;
    startFrame.origin.y = self.view.bounds.size.height;
    jumpPickerContainer.frame = startFrame;
	
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect r = jumpPickerContainer.frame;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        r.origin.y = 0;
        jumpPickerContainer.frame = r;
        [UIView commitAnimations];
    });

 
	//LOG(@"%s - OUT",__FUNCTION__);
	
} // jump

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return pickerMap.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return pickerMap[row][@"name"];
}

-(IBAction) getRelated:(id)sender {
	//LOG(@"%s - IN",__FUNCTION__);
	RelatedResults  *aViewController = [[RelatedResults alloc] initWithNibName:@"ResultsController" bundle:nil];
	
    [self.navigationController pushViewController:aViewController animated:YES];
	
    NSString  *searchTerm = [info objectAtPath:@"MedlineCitation/PMID"];
    
	[aViewController searchForRelated:searchTerm];
	//LOG(@"%s - OUT",__FUNCTION__);	
} // getRelated


- (IBAction) doJump:(id)sender {
 	//LOG(@"%s - IN",__FUNCTION__);
    
	self.navigationItem.rightBarButtonItem.enabled = YES;
	self.navigationItem.hidesBackButton = NO;
	[self disableNavigation:NO];
	NSString  *anchor = pickerMap[[jumpPicker selectedRowInComponent:0]][@"anchor"];
	[fullTextView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"location.href=\"#%@\";", anchor]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect r = jumpPickerContainer.frame;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        
        r.origin.y = self.view.bounds.size.height;
        
        jumpPickerContainer.frame = r;
        jumpPickerContainer.hidden = YES;
        [UIView commitAnimations];
    });

	//LOG(@"%s - OUT",__FUNCTION__);
} // doJump

- (IBAction) cancelJump:(id)sender {
	//LOG(@"%s - IN",__FUNCTION__);
	self.navigationItem.rightBarButtonItem.enabled = YES;
	self.navigationItem.hidesBackButton = NO;
	[self disableNavigation:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect r = jumpPickerContainer.frame;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        r.origin.y = self.view.bounds.size.height;
        jumpPickerContainer.frame = r;
        [UIView commitAnimations];
    });
	//LOG(@"%s - OUT",__FUNCTION__);
}

-(IBAction) searchButton:(id)sender {
	//LOG(@"%s - IN",__FUNCTION__);
	[self.navigationController popToRootViewControllerAnimated:YES];
	//LOG(@"%s - OUT",__FUNCTION__);
}

#pragma mark Orientation support

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

@end
