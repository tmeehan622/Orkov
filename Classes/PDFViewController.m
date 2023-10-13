//
//  PDFViewController.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 9/2/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "PDFViewController.h"
#import "PDFLibraryViewController.h"


@implementation PDFViewController
@synthesize pdfFileName, info, pmcID, myWebView;



- (void)viewDidLoad {
    [super viewDidLoad];
	
#ifndef __DEBUG_OUTPUT__
	[Flurry logEvent:@"PDFLoadSaved"];
#endif
	self.navigationItem.title = @"Full Text PDF";
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
    
	if([fileManager fileExistsAtPath:pdfFileName])
	{
 		BOOL	isGoodPDF = NO;
       
        NSData *td = [fileManager contentsAtPath:pdfFileName];
        if(td.length > 100)
        {
            isGoodPDF = YES;
        }
		
		if(isGoodPDF)
		{
			[myWebView loadRequest :[NSURLRequest requestWithURL:[NSURL fileURLWithPath:pdfFileName]]];
			UIBarButtonItem* bookmarkButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Misc_EmailButton"] style:UIBarButtonItemStylePlain target:self action:@selector(sendAsEmail:)];
			
			self.navigationItem.rightBarButtonItem = bookmarkButton;
		}
		else
		{
			UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"Full Text"
															message:@"Unable to retrieve the article"
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
		}
	}

	id			otherID = info[@"MedlineCitation/OtherID"];
	self.pmcID = nil;
	
	if(otherID)
	{
		if([otherID isKindOfClass:[NSArray class]])
		{
			for(NSString* thisID in otherID)
			{
				if([thisID.uppercaseString hasPrefix:@"PMC"])
				{
					self.pmcID = [thisID substringFromIndex:3];
					break;
				}
			}
		} // array
		else if([otherID isKindOfClass:[NSString class]])
		{
			self.pmcID = otherID;
		}
		
	}
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


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
	
	NSString*	title = info[@"MedlineCitation/Article/ArticleTitle"];
	if(title == nil)
		title = @"";
	
	[picker setSubject:[NSString stringWithFormat:@"Orkov Pubmed Full Text Article %@", title]];

	[picker setSubject:@"Orkov Pubmed Full Text Article"];
	[picker addAttachmentData:[NSData dataWithContentsOfFile:pdfFileName] mimeType:@"application/pdf" fileName:pdfFileName.pathComponents.lastObject];

	if(pmcID)
	{
		NSDictionary    *bm = [PDFLibraryViewController findArticleWithID:pmcID forDB:@"pubmed"];
        NSString        *notes;
        NSDictionary    *noteDict;
		if(bm)
		{
            noteDict =
			noteDict = bm[@"notes"];
            notes = noteDict[@"text"];
			if(notes && notes.length)
			{
				NSString    *html;
				
                html = [NSString stringWithFormat:@"<html><head></head><body><p><strong>Notes: </strong>%@</p><br/></body></html>\n", notes];
				[picker setMessageBody:html isHTML:YES];
			}
		}
	}
	
	[self presentModalViewController:picker animated:YES];
} // sendAsEmail

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
#if __DEBUG_OUTPUT__
	//NSLog(@"Email status:%d",result);
#endif
	[self dismissModalViewControllerAnimated:YES];
} // mailComposeController


@end
