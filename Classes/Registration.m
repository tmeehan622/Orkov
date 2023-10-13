//
//  Registration.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/26/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "Registration.h"
#import "CreditCard.h"


@implementation Registration

+ (NSString *)decodeBase64:(NSString *)input
{
	NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+-";
	NSString *decoded = @"";
	NSString *encoded = [input stringByPaddingToLength:(ceil(input.length / 4) * 4)
											withString:@"A"
									   startingAtIndex:0];
	
	int i;
	char a, b, c, d;
	UInt32 z;
	
	for(i = 0; i < encoded.length; i += 4) {
		a = [alphabet rangeOfString:[encoded substringWithRange:NSMakeRange(i + 0, 1)]].location;
		b = [alphabet rangeOfString:[encoded substringWithRange:NSMakeRange(i + 1, 1)]].location;
		c = [alphabet rangeOfString:[encoded substringWithRange:NSMakeRange(i + 2, 1)]].location;
		d = [alphabet rangeOfString:[encoded substringWithRange:NSMakeRange(i + 3, 1)]].location;
		
		z = ((UInt32)a << 26) + ((UInt32)b << 20) + ((UInt32)c << 14) + ((UInt32)d << 8);
		decoded = [decoded stringByAppendingString:@((char *)&z)];
	}
	
	return decoded;
} // decodeBase64

+(void) checkRegistration
{
//	NSAutoreleasePool*	pool = [[NSAutoreleasePool alloc] init];
	
	NSString*	urlString = @"https://sales.visualsoftinc.com/orkovregister.php";
//	NSString*	urlString = [Registration decodeBase64:@"aHR0cDovL3RvbWNhdC5mcm9kaXMuY29tL29ya292cmVnaXN0ZXIucGhwAE1B"];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
	request.HTTPMethod = @"POST";

	UIDevice*		currentDevice = [UIDevice currentDevice];
	NSString*		udid = currentDevice.identifierForVendor.UUIDString;
	
	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	NSDictionary*	regInfo = [ud objectForKey:@"registrationInfo"];
	NSString*		licenseKey = regInfo[@"licenseKey"];
	
	if(licenseKey == nil || licenseKey.length == 0)
		licenseKey = @"NULL";
		
	request.HTTPBody = [[NSString stringWithFormat:@"Check=yes&UDID=%@&KEY=%@", udid, licenseKey] dataUsingEncoding:NSUTF8StringEncoding];
		
	// Get ready for the response
	NSData *theData;
	NSURLResponse *response;
	NSError *error;
	
	// Make the request
	//NSLog(@"NSURL-3");
	theData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	NSString*	reply = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
#ifdef __DEBUG_OUTPUT__
	NSLog(reply);
#endif
	GenericParser*	gp = [[GenericParser alloc] init];
	[gp parseString:reply usingDelegate:nil];
	NSDictionary*	tResults = gp.resultDict;
#ifdef __DEBUG_OUTPUT__
	NSLog(@"%@", tResults);
#endif

	[Registration handleRegistrationResult:tResults];
	
//	[reply autorelease];
//	[gp autorelease];
//	[pool release];
} // checkRegistration


+(NSDictionary*) registrationInfo
{
	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	NSDictionary*	regInfo = [ud objectForKey:@"registrationInfo"];
	if(regInfo == nil || regInfo.count == 0)
	{
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = @"yyyy-MM-dd";
		
		NSDate*			expireDate = [NSDate dateWithTimeIntervalSinceNow:(60*60*24*30)];
		NSString*		expireDateString = [formatter stringFromDate:expireDate];
		
		regInfo = @{@"expires": @1,
				   @"expirationdate": expireDateString,
				   @"key": @""};
		
//		[ud setObject:regInfo forKey:@"registrationInfo"];
//		[ud synchronize];

		[Registration handleRegistrationResult:@{@"registration": regInfo}];
		regInfo = [ud objectForKey:@"registrationInfo"];
	}
	
	return regInfo;
} // registrationInfo

+(BOOL) handleRegistrationResult:(NSDictionary*)tResults
{
	if(tResults == nil || tResults.count == 0)
		return NO;
	
	NSString*	error = tResults[@"error"];

	if(error)
	{
#if 0
		NSUserDefaults*			ud = [NSUserDefaults standardUserDefaults];
		NSMutableDictionary*	regInfo = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:@"registrationInfo"]];
		
		[regInfo removeObjectForKey:@"licenseKey"];
		[regInfo removeObjectForKey:@"expireDate"];
		
		[ud setObject:regInfo forKey:@"registrationInfo"];
		[ud synchronize];
#endif
		return NO;
	}

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"yyyy-MM-dd";
	
	NSUserDefaults*			ud = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary*	regInfo = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:@"registrationInfo"]];
	
	NSString*	licenseKey = [tResults objectAtPath:@"registration/key"];
	NSString*	expireDateString = [tResults objectAtPath:@"registration/expirationdate"];
	NSDate*		expireDate = [formatter dateFromString:expireDateString];
	NSNumber*	expires = @([[tResults objectAtPath:@"registration/expires"] intValue]);
	
	regInfo[@"licenseKey"] = licenseKey;
	regInfo[@"expireDate"] = expireDate;
	regInfo[@"expires"] = expires;
	
	[ud setObject:regInfo forKey:@"registrationInfo"];
	[ud synchronize];

	return YES;
	
} // handleRegistrationResult

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.hidesBottomBarWhenPushed = YES;
   }
    return self;
}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	NSDictionary*	regInfo = [Registration registrationInfo];
	NSDate*			expireDate = regInfo[@"expireDate"];
	BOOL			expires = [regInfo[@"expires"] boolValue];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateStyle = NSDateFormatterMediumStyle;

	if(expires)
	{
		expireDateField.text = [formatter stringFromDate:expireDate];
	}
	else
	{
		expireDateField.text = @"Never";
		buyButton.enabled = NO;
		buyButton.titleLabel.text = @"No purchase necessary";
		keyField.enabled = NO;
	}
	
	keyField.text = regInfo[@"licenseKey"];
	if(regInfo[@"licenseKey"] && [regInfo[@"licenseKey"] length])
	{
		keyField.enabled = NO;
		buyButton.titleLabel.text = @"Renew";
		buyButton.titleLabel.textAlignment = UITextAlignmentCenter;
		prompt.text = @"This is a registered version of Orkov. To renew Orkov for another year touch the \"Renew\" button.";
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = @"Registration";
	
	cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel",@"")
													style:UIBarButtonItemStylePlain
												   target:self
												   action:@selector(cancelKey:)];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationComplete:) name:@"REGISTRATION_DONE" object:nil];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

-(IBAction) useCreditCard:(id)sender
{
	NSDictionary*	regInfo = [Registration registrationInfo];		// forces an expiration date
	
	if(regInfo[@"licenseKey"] && [regInfo[@"licenseKey"] length])
	{
		NSDate*		expireDate = regInfo[@"expireDate"];
		NSString*	expMessage = nil;
		int			daysLeft = ((expireDate.timeIntervalSinceReferenceDate - [NSDate date].timeIntervalSinceReferenceDate)/86400.0) + 1;
		int			monthsLeft = daysLeft / 30;
		
		if(daysLeft > 365)
			expMessage = @"Your license has over a year left. Are you sure you want to renew now?";
		else if(monthsLeft == 1)
			expMessage = @"Your license has over a month left. Are you sure you want to renew now?";
		else if(monthsLeft > 1)
			expMessage = [NSString stringWithFormat:@"Your license has %d months left. Are you sure you want to renew now?", monthsLeft];
		else if (daysLeft > 14)
			expMessage = [NSString stringWithFormat:@"Your license has %d days left. Are you sure you want to renew now?", daysLeft];
		
		if(expMessage)
		{
			[[[UIAlertView alloc] initWithTitle:@"Attention"
										 message:expMessage
										delegate:self
							   cancelButtonTitle:@"Cancel"
							   otherButtonTitles:@"Renew", nil] show];
		}
		else
		{
			CreditCard*	aViewController = [[CreditCard alloc] initWithNibName:@"CreditCard" bundle:nil];
			[self.navigationController pushViewController:aViewController animated:YES];
			
		}
		
	}
	else
	{
		CreditCard*	aViewController = [[CreditCard alloc] initWithNibName:@"CreditCard" bundle:nil];
		[self.navigationController pushViewController:aViewController animated:YES];
		
	}
} // useCreditCard

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 0)
		[self.navigationController popViewControllerAnimated:YES];
	else
	{
		CreditCard*	aViewController = [[CreditCard alloc] initWithNibName:@"CreditCard" bundle:nil];
		[self.navigationController pushViewController:aViewController animated:YES];
		
	}
	
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
	[textField resignFirstResponder];
	[NSThread detachNewThreadSelector:@selector(sendRegistrationKey:) toTarget:self withObject:textField.text];
	
	return YES;
} // textFieldShouldReturn

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	self.navigationItem.rightBarButtonItem = cancelButton;
} // 

-(void) sendRegistrationKey:(NSString*)key
{
//	NSAutoreleasePool*	pool = [[NSAutoreleasePool alloc] init];
	NSArray*			params = [NSArray array];
	
	UIDevice*		currentDevice = [UIDevice currentDevice];
	NSString*		udid = currentDevice.identifierForVendor.UUIDString;
	NSString*		licenseKey = keyField.text;
	
	params = [params arrayByAddingObject:[NSString stringWithFormat:@"UDID=%@", udid]];
	params = [params arrayByAddingObject:@"Register=yes"];
	if(licenseKey && licenseKey.length)
		params = [params arrayByAddingObject:[NSString stringWithFormat:@"KEY=%@", licenseKey]];
	
	NSString*			paramString = [params componentsJoinedByString:@"&"];
	NSData*				postData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
	
	NSString*	urlString = @"https://sales.visualsoftinc.com/orkovregister.php";
//	NSString*	urlString = [Registration decodeBase64:@"aHR0cDovL3RvbWNhdC5mcm9kaXMuY29tL29ya292cmVnaXN0ZXIucGhwAE1B"];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
	request.HTTPMethod = @"POST";
	request.HTTPBody = postData;
	
	// Get ready for the response
	NSData *theData;
	NSURLResponse *response;
	NSError *error;
	
	// Make the request
	//NSLog(@"NSURL-4");
	theData = [NSURLConnection sendSynchronousRequest:request 
									returningResponse:&response 
												error:&error];
	
	NSString*	reply = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
#ifdef __DEBUG_OUTPUT__
	NSLog(reply);
#endif
	GenericParser*	gp = [[GenericParser alloc] init];
	[gp parseString:reply usingDelegate:self];
	
//	[reply autorelease];
//	[pool release];
} // sendRegistrationKey

-(void) registrationComplete:(NSNotification*)notification
{
	NSString*		title = @"Registration";
	
	NSDictionary*	d = notification.userInfo;
	int				code = [d[@"code"] intValue];
	if(code != 0)
		title = @"Error";
	else
	{
		// Success!
		NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
		NSDictionary*	regInfo = [ud objectForKey:@"registrationInfo"];
		if(regInfo == nil)
		{
			UIDevice*		currentDevice = [UIDevice currentDevice];
			NSString*		serialNumber = currentDevice.identifierForVendor.UUIDString;
			NSDate*			expireDate = d[@"expireDate"];
			NSString*		licenseKey = d[@"licenseKey"];
			
			regInfo = @{@"serialNumber": serialNumber,
					   @"expireDate": expireDate,
					   @"licenseKey": licenseKey};
			
			[ud setObject:regInfo forKey:@"registrationInfo"];
			[ud synchronize];
		}
	}
	
	UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:title
													message:d[@"message"]
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	
	
} // registrationComplete

-(void) getParserResults:(NSDictionary*)tResults
{
	NSString*	message = @"Thank you for registering Orkov.";
	NSString*	title = @"Resister";
	NSString*	error = tResults[@"error"];
	BOOL		goBack = YES;
	
	if(error)
	{
		message = error;
		title = @"Error";
		goBack = NO;
	}
	else
		[Registration handleRegistrationResult:tResults];
	
	UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	
	
	if(goBack)
		[self.navigationController popToRootViewControllerAnimated:YES];
	
} // getParserResults

-(void) parserTimeout
{
	UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"Error"
													message:@"There was a problem registering. Please try again later."
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	
	
} // parserTimeout

-(void) parserError:(NSException*)localExcaption
{
	UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"Error"
													message:@"There was an error reading the server's reply."
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	
} // parserError

-(IBAction) cancelKey:(id)sender
{
	[keyField resignFirstResponder];
	self.navigationItem.rightBarButtonItem = nil;
	
} // cancelKey
@end
