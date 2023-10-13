//
//  TermsOfUse.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 10/1/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "TermsOfUse.h"
#import <UIKit/UIKit.h>

@implementation TermsOfUse
@synthesize mainWebView;
@synthesize acceptButton;
@synthesize declineButton;
@synthesize okButton;

- (void)viewDidLoad {
    
#ifndef __DEBUG_OUTPUT__
	[Flurry logEvent:@"TermsOfUse"];
#endif
    
    [super viewDidLoad];
	
	BOOL alreadyAccepted = [[NSUserDefaults standardUserDefaults] boolForKey:@"agreedToTerms"];

	if(alreadyAccepted) {
		okButton.hidden = NO;
		acceptButton.hidden = YES;
		declineButton.hidden = YES;
	} else {
		okButton.hidden = YES;
		acceptButton.hidden = NO;
		declineButton.hidden = NO;
	}
	self.navigationItem.title = @"Terms of Use";
    
	[mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"termsOfUse" ofType:@"html"]]]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (IBAction)accept:(id)sender {
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"agreedToTerms"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)decline:(id)sender {
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"agreedToTerms"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Decline"
//                                                    message:@"Terms must be agreed to prior to using Orkov. To continue using Orkov, please tap 'Cancel' to dismiss this alert and then tap 'Agree' on the Terms and Conditions screen."
//                                                   delegate:nil
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//    [alert show];


    UIAlertController   *alert = [UIAlertController alertControllerWithTitle:@"Decline"
                                                                   message:@"Terms must be agreed to prior to using Orkov. To continue using Orkov, please tap 'Cancel' to dismiss this alert and then tap 'Agree' on the Terms and Conditions screen."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction   *OKAction = [UIAlertAction actionWithTitle:@"Quit Application" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {exit(0);}];
    UIAlertAction   *canceAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {}];

    [alert addAction:OKAction];
    [alert addAction:canceAction];

    [self presentViewController:alert animated:YES completion:nil];

}

@end
