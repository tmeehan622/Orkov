//
//  LoansomeView.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 9/25/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "LoansomeView.h"


@implementation LoansomeView
@synthesize mainWebView;
@synthesize navBar;
@synthesize backButton;
@synthesize forwardButton;
@synthesize refreshButton;

- (void)viewDidLoad {
    [super viewDidLoad];

	navBar.tintColor = ORKOV_TINT_COLOR;
	
	[mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://docline.gov/loansome/login.cfm"]]];

#if 1
	UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"LoansomeDoc"
													message:@"When you are done with LoansomeDoc, touch the 'Back to Orkov' button."
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	//•
#endif
	
}

- (IBAction) done:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
} // done

- (IBAction) back:(id)sender
{
	[mainWebView goBack];
} // back

- (IBAction) next:(id)sender
{
	[mainWebView goForward];
} // next

- (IBAction) refresh:(id)sender
{
	[mainWebView reload];
} // refresh

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	backButton.enabled = mainWebView.canGoBack;
	forwardButton.enabled = mainWebView.canGoForward;
	refreshButton.enabled = YES;
} // webViewDidFinishLoad

- (void)webViewDidStartLoad:(UIWebView *)webView;
{
	backButton.enabled = mainWebView.canGoBack;
	forwardButton.enabled = mainWebView.canGoForward;
	refreshButton.enabled = NO;
} // webViewDidStartLoad

- (void)viewWillDisappear:(BOOL)animated
{
	[mainWebView stopLoading];
	mainWebView.delegate = nil;
	[super viewWillDisappear:animated];
} // viewWillDisappear

@end
