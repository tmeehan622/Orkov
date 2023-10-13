//
//  InAppWebBrowser.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 10/13/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "InAppWebBrowser.h"


@implementation InAppWebBrowser
@synthesize mainWebView;
@synthesize navBar;
@synthesize toolBar;
@synthesize backButton;
@synthesize forwardButton;
@synthesize refreshButton;
@synthesize destination;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	navBar.tintColor = ORKOV_TINT_COLOR;
	
	[mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:destination]]];
	
#if 1
	UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"Alert"
													message:@"When you are done, touch the 'Back to Orkov' button."
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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{

	toolBar.hidden = YES;
	return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[mainWebView stopLoading];
	mainWebView.delegate = nil;
	[super viewWillDisappear:animated];
} // viewWillDisappear


-(void) showControls
{
	[UIView beginAnimations:nil context:@"toolbar"];
	toolBar.alpha = !toolBar.hidden;
	toolBar.hidden = !toolBar.hidden;
	
	[UIView setAnimationDuration:0.3];
	toolBar.alpha = !toolBar.hidden;
	[UIView commitAnimations];
} // showControls

@end
