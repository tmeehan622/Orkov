//
//  Support.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/26/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "Support.h"


@implementation Support

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.hidesBottomBarWhenPushed = YES;
	}
    return self;
}


- (void)viewDidLoad {
#ifndef __DEBUG_OUTPUT__
	[Flurry logEvent:@"Support Open"];
#endif
    [super viewDidLoad];
	self.navigationItem.title = @"Support";
}

-(IBAction) emailSupport:(id)sender {
    NSDate *today               = [NSDate date];
    NSDateFormatter *formatter  = [[NSDateFormatter alloc] init];
    formatter.dateStyle         = kCFDateFormatterMediumStyle;
    formatter.timeStyle         = NSDateFormatterShortStyle;
    NSString *tempS             = [formatter stringFromDate:today];
    NSMutableString *dateStr    = [NSMutableString stringWithString:tempS];
    
    [dateStr replaceOccurrencesOfString:@" at " withString:@" " options:NSLiteralSearch range:NSMakeRange(0, dateStr.length)];

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
    
    NSString *subjectLine = [NSString stringWithFormat:@"Support on Orkov App %@",dateStr];
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.navigationBar.tintColor = ORKOV_TINT_COLOR;
	picker.mailComposeDelegate = self;
	[picker setToRecipients:@[@"info@visualsoftinc.com"]];
	[picker setSubject:subjectLine];
	
	[self presentModalViewController:picker animated:YES];
	
}

-(IBAction) emailSales:(id)sender
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
	[picker setToRecipients:@[@"info@visualsoftinc.com"]];
	[picker setSubject:@"Sales Support"];
	
	[self presentModalViewController:picker animated:YES];
	
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
	[self dismissModalViewControllerAnimated:YES];
}
@end
