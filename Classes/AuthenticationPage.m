//
//  AuthenticationPage.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/21/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "AuthenticationPage.h"


@implementation AuthenticationPage
@synthesize myWebView, html, delegate;
@synthesize method, action, formName, busy;

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = @"Authentication";
}

-(void)kickStartAuthentication {
	[[delegate navigationController] pushViewController:self animated:YES];
	
    NSString    *authHTML = [[NSString alloc] initWithData:html encoding:NSASCIIStringEncoding];
	
    [myWebView loadHTMLString:authHTML baseURL:nil];
	myWebView.hidden = YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
#if __DEBUG_OUTPUT__
	NSLog(@"webViewDidStartLoad");
#endif
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
#if __DEBUG_OUTPUT__
	NSLog(@"webViewDidFinishLoad");
#endif
	NSString    *myJavascript = @"function findForm() { \
		var head = document.forms; \
		if(head.length > 0) return 'YES'; else return 'NO'; \
	} \
	findForm();";
	
	NSString    *result = [myWebView stringByEvaluatingJavaScriptFromString:myJavascript];
	
	if([result isEqualToString:@"NO"]) {
		myWebView.hidden = YES;
		[self.navigationController popViewControllerAnimated:YES];
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"SEARCH_AGAIN" object:self]];
		[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(popLater:) userInfo:nil repeats:NO];
		return;
	}

	NSMutableArray  *formElements = [self getFormElements];
	
    if([self fillFormElements:formElements]) {
		BOOL ok = [self sendLoginForm:formElements];
		if(ok) {
			myWebView.hidden = YES;
			[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"SEARCH_AGAIN" object:self]];
			[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(popLater:) userInfo:nil repeats:NO];
			return;
		}
	}
	
	busy.hidden = YES;
	myWebView.hidden = NO;
	
	NSUserDefaults  *ud       = [NSUserDefaults standardUserDefaults];
	NSString        *user     = [ud stringForKey:@"ezProxyUser"];
	NSString        *password = [ud stringForKey:@"ezProxyPassword"];
	
	myJavascript = [NSString stringWithFormat:@"function fillForm(user,password) { \
	var inputs = document.getElementsByTagName('input'); \
	var foundUser=false; \
	var foundPassword=false; \
	for (var i = 0; i < inputs.length; i++) { \
		var node = inputs[i]; \
		if (node.getAttribute('type') == 'text') { \
			node.value=user; foundUser=true; } \
		else if (node.getAttribute('type') == 'password') { \
			node.value=password; foundPassword=true; } \
		} \
		if(foundUser && foundPassword) \
			return 'YES'; \
		return 'NO'; \
	} \
	fillForm('%@','%@');", user, password];
	
	result = [myWebView stringByEvaluatingJavaScriptFromString:myJavascript];
}

- (void) popLater:(NSTimer*)timer {
	[self.navigationController popViewControllerAnimated:YES];	
} // popLater
 
-(NSMutableArray*) getFormElements {
	NSString*		myJavascript = @"function getFormElements() { \
					var inputs = document.getElementsByTagName('input'); \
					var outputs = document.forms[0].getAttribute('name') +'::' + document.forms[0].getAttribute('action') +'::' + document.forms[0].getAttribute('method') +'::'; \
					for (var i = 0; i < inputs.length; i++) { \
						var node = inputs[i]; \
						outputs +=  node.getAttribute('name') + ';;'; \
						outputs +=  node.getAttribute('type') + ';;';  \
						outputs +=  node.getAttribute('value') + ';;';  \
						} \
					return outputs; \
					} \
					getFormElements();";
	
	NSString    *result = [myWebView stringByEvaluatingJavaScriptFromString:myJavascript];
	NSArray     *parts  = [result componentsSeparatedByString:@"::"];
    
	self.formName  =	parts[0];
	self.action    =	parts[1];
	self.method    =	parts[2];
	
	NSArray         *formElements   = [parts[3] componentsSeparatedByString:@";;"];
	NSMutableArray  *returnElements = [NSMutableArray array];
	
	int count = formElements.count -1;
	
    for(int i=0;i<count;i+=3) {
		NSString    *xValue = formElements[i+2];
        
        if(xValue == nil){
			xValue = @"";
        }
		
		[returnElements addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
								   formElements[i], @"name",
								   formElements[i+1], @"type",
								   xValue, @"value",
								   nil]];
	}
		
	return returnElements;
}

- (BOOL) fillFormElements:(NSMutableArray*)loginInfo
{
	NSDictionary    *userElement = nil;
	NSDictionary    *passwordElement = nil;
	
	for(NSDictionary*d in loginInfo)
	{
		if([[d[@"type"] uppercaseString] isEqualToString:@"TEXT"])
			userElement = d;
		else if([[d[@"type"] uppercaseString] isEqualToString:@"PASSWORD"])
			passwordElement = d;
	}
	
	if(userElement && passwordElement)
	{
		NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
		NSString*		user = [ud stringForKey:@"ezProxyUser"];
		NSString*		password = [ud stringForKey:@"ezProxyPassword"];
		
		[userElement setValue:user forKey:@"value"];
		[passwordElement setValue:password forKey:@"value"];
		
		return YES;
	}
	
	return NO;
} // fillFormElements

-(BOOL) sendLoginForm:(NSArray*) loginInfo
{
	NSArray*	args = [NSArray array];
	for(NSDictionary*d in loginInfo)
		args = [args arrayByAddingObject:[NSString stringWithFormat:@"%@=%@", d[@"name"], d[@"value"]]];
	
	NSMutableURLRequest*	post;
	NSURL*					url;
	
	NSString*	argString = [NSString stringWithFormat:@"%@", [args componentsJoinedByString:@"&"]];
	if([method.uppercaseString isEqualToString:@"POST"])
	{
		url = [NSURL URLWithString:action];
		post = [NSMutableURLRequest requestWithURL: url];
		post.HTTPMethod = @"POST";
		NSData*	postData = [NSData dataWithData:[[argString stringByAppendingString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		post.HTTPBody = postData;
	}
	else
	{
		url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", action, argString]];
		post = [NSMutableURLRequest requestWithURL: url];
		post.HTTPMethod = @"GET";
	}
	
	// and... post it
	NSURLResponse* response;
	NSError* serverError;
	//NSLog(@"NSURL-1");
	NSData* result = [NSURLConnection sendSynchronousRequest:post returningResponse: &response error:&serverError];

	// we can tell if we were successfull if the return data is NOT html
	NSString*	saywhat = [[NSString alloc] initWithData: result encoding: NSASCIIStringEncoding];
	NSRange		r = [saywhat rangeOfString:@"<html" options:NSCaseInsensitiveSearch];
	if(r.location != NSNotFound)
		return NO;
	
	return YES;
} // sendLoginForm


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
#if __DEBUG_OUTPUT__
	NSLog(@"didFailLoadWithError %@",error.localizedDescription);
#endif
}

@end
