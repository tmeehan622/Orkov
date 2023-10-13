//
//  Settings.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/24/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "Settings.h"
#import "EZProxySettings.h"
#import "SegmentedPref.h"
#import "AboutBox.h"
#import "Disclaimer.h"
//#import "Registration.h"
#import "Support.h"
#import "TermsOfUse.h"

enum { kTellAFriend=0, kAbout, kPageLength, kDisclaimer, kEzProxy, kSupport, kTerms };

@implementation Settings
@synthesize myTable;
@synthesize tableHeadings;

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
	self.navigationItem.title = @"Settings";
	tableHeadings = @[@"Tell a Friend", @"About Orkov", @"Abstracts Per Page", @"Disclaimer", @"EZProxy Settings", @"Support", @"Terms of Use"];
//	tableHeadings = [[NSArray alloc] initWithObjects:@"Tell a Friend", @"About Orkov", @"Abstracts Per Page", @"Disclaimer", @"EZProxy Settings", @"Support", @"Registration", @"Terms of Use", nil];
//	[self view].backgroundColor = ORKOV_BG_COLOR;
//	myTable.backgroundColor = ORKOV_BG_COLOR;
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



#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tableHeadings.count;	// stub
}

#if 0
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [segmentHeadings objectAtIndex:section];
} // titleForHeaderInSection

#endif
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"SettingsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	
        
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
 		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
   }
    
	cell.textLabel.text = tableHeadings[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIViewController*	nextView = nil;
	
	switch (indexPath.row) {
			
		case kTellAFriend:
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
			[picker setSubject:@"Checkout Orkov the PubMed search App for iPhone"];
			NSString*	emailBody = @"<html><head></head><body><p>Go To iTunes and download Orkov - it's free..</p><p>Orkov is the PubMed search authority on iPhone.</p></body></html>";
			[picker setBccRecipients:@[@"info@visualsoftinc.com"]];
			[picker setMessageBody:emailBody isHTML:YES];
			
			[self presentModalViewController:picker animated:YES];
		}
			break;
			
		case kAbout:
			//nextView = [[AboutBox alloc] initWithNibName:@"AboutBox" bundle:nil];
			[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ABOUT_TOUCH" object:self]];
			break;
		case kPageLength:
		{
			SegmentedPref*	aViewController = [[SegmentedPref alloc] initWithNibName:@"SegmentedPref" bundle:nil];
			aViewController.prefName = @"itemsPerPage";
			aViewController.segments = @[@"10", @"25", @"50", @"75", @"100"];
			aViewController.prefTitle = @"Number of abstracts per page:";
			nextView = (UIViewController*) aViewController;
		}
			break;
			
		case kDisclaimer:
			nextView = [[Disclaimer alloc] initWithNibName:@"Disclaimer" bundle:nil];
			break;

		case kEzProxy:
		{
			EZProxySettings*	aViewController = [[EZProxySettings alloc] initWithNibName:@"EZProxySettings" bundle:nil];
			nextView = (UIViewController*) aViewController;
		}
			break;

		case kSupport:
			nextView = [[Support alloc] initWithNibName:@"Support" bundle:nil];
			break;
			
//
//		case kRegister:
//			nextView = [[Registration alloc] initWithNibName:@"Registration" bundle:nil];
//			break;
			
		case kTerms:
			nextView = [[TermsOfUse alloc] initWithNibName:@"TermsOfUse" bundle:nil];
			[self presentModalViewController:nextView animated:NO];
			nextView = nil;

			break;
			
		default:
			break;
	}
	
	if(nextView)
	{
		[self.navigationController pushViewController:nextView animated:YES];
	}

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
} // didSelectRowAtIndexPath

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
	[self dismissModalViewControllerAnimated:YES];
}

@end
