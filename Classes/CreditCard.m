//
//  CreditCard.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/26/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "CreditCard.h"
//#import "Registration.h"
#import "QuickChoiceList.h"
#import "Wait.h"
#import "CreditDisclaimer.h"

#define HIGHESTFIELD 60
#define LOWESTFIELD 116
#define VA_SALES_TAX 0.05

#if 1
@implementation NSURLRequest(NSHTTPURLRequest)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
	return YES; // Or whatever logic
}
@end
#endif

@implementation CreditCard

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		stateChoice = 0;
		monthChoice = 0;
		yearChoice = 0;
		oneYearSubscription = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = @"Purchase";
	activeBox = nil;
	
	fields = @[nameOnCard, addr1, addr2, city, state, zipcode,
			  country, phone, email, ccnumber, expireMonth, expireYear, csv];

	statesDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"statesAndCountries" ofType:@"plist" ]];
	countriesDictionary = [NSMutableDictionary dictionaryWithDictionary:statesDictionary[@"countries"]];
	countriesArray = @[@"United States"];
	NSArray*	tmpStates = [countriesDictionary.allKeys sortedArrayUsingSelector:@selector(compare:)];
	countriesArray = [countriesArray arrayByAddingObjectsFromArray:tmpStates];
	countriesDictionary[@"United States"] = @"us";
	
	statesDictionary = statesDictionary[@"states"];
	statesArray = [statesDictionary.allKeys sortedArrayUsingSelector:@selector(compare:)];
	monthsArray = @[@"(01) January", @"(02) Feburary", @"(03) March", @"(04) April", @"(05) May", @"(06) June",
				   @"(07) July", @"(08) August", @"(09) September", @"(10) October", @"(11) November", @"(12) December"];

#if 0
	yearsArray =  [[NSArray alloc] initWithObjects:@"2009", @"2010", @"2011", @"2012", @"2013", @"2014", @"2015", @"2016", @"2017", @"2018", @"2019"];
#else
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
	NSDateComponents*	components = [gregorian components: NSCalendarUnitYear | NSCalendarUnitMonth fromDate:[NSDate date]];
	NSInteger thisyear = components.year;
	monthChoice = components.month;
	
	expireMonth.text = [NSString stringWithFormat:@"%d", monthChoice--];
	expireYear.text = [NSString stringWithFormat:@"%d", thisyear];
	yearChoice = 0;
	
	yearsArray = @[];
	for(int y=0;y<10;y++)
		yearsArray = [yearsArray arrayByAddingObject:[NSString stringWithFormat:@"%d", thisyear+y]];
	
#endif

	presaleAlert = [[UIAlertView alloc] initWithTitle:@"Attention"
													message:@"Choose your subscription option"
												   delegate:self
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"$4.99 for 6 Months", @"$8.99 for One Year", nil];
	[presaleAlert show];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(actionSheet == presaleAlert)
	{
		if(buttonIndex == 0)
			[self.navigationController popViewControllerAnimated:YES];
		else
		{
			oneYearSubscription = (buttonIndex == 2);
			[self performSelectorOnMainThread:@selector(pushDisclaimerScreen) withObject:nil waitUntilDone:YES];
		}
	}
	else if(actionSheet == confirmationAlert)
	{
		if(buttonIndex == 1)
		{
			waitScreen = [[Wait alloc] initWithNibName:@"Wait" bundle:nil];
			[self presentModalViewController:waitScreen animated:YES];
			[NSThread detachNewThreadSelector:@selector(purchaseThread) toTarget:self withObject:nil];
		}
	}
} // clickedButtonAtIndex

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

-(IBAction) purchase:(id)sender
{
	BOOL	notOK = NO;
	
	notOK |= ((nameOnCard.text).length == 0);
	notOK |= ((addr1.text).length == 0);
	notOK |= ((city.text).length == 0);
	notOK |= ((ccnumber.text).length == 0);
//	notOK |= ([csv.text length] == 0);

	if(notOK)
	{
		UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:@"Please fill in the missing fields."
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		//•
	}
	else
	{
		double subtotal = oneYearSubscription ? 8.99 : 4.99;
		double tax = [(state.text).uppercaseString isEqual:@"VA"] ? subtotal * VA_SALES_TAX : 0.0;
		double chargetotal = subtotal + tax;
		NSString*	message;

		if(tax != 0)
		{
			message = [NSString stringWithFormat:@"Your credit card is about to be charged $%2.2f (includes 5%% Virginia State Sales Tax)", chargetotal];
		}
		else
			message = [NSString stringWithFormat:@"Your credit card is about to be charged $%2.2f", chargetotal];
		
		confirmationAlert = [[UIAlertView alloc] initWithTitle:@"Attention"
												  message:message
												 delegate:self
										cancelButtonTitle:@"Cancel"
										otherButtonTitles:@"OK", nil];
		[confirmationAlert show];
	}
} // purchase

-(void) scrollToTextField:(UITextField*)field
{
	activeBox = field;
	CGRect		containerRect = viewContainer.frame;
	CGRect		boxRect = activeBox.frame;
	
	[activeBox becomeFirstResponder];
	
	if(buttonToolBar.hidden)
	{
		[UIView beginAnimations:nil context:@"toolbar"];
		[UIView setAnimationDuration:0.3];
		buttonToolBar.alpha = 0;
		buttonToolBar.hidden = NO;
		buttonToolBar.alpha = 1;
		[UIView commitAnimations];
	}
	if(boxRect.origin.y > LOWESTFIELD)
	{
		[UIView beginAnimations:nil context:@"scrolling"];
		[UIView setAnimationDuration:0.3];
		double offset = containerRect.origin.y + boxRect.origin.y - LOWESTFIELD;
		containerRect.origin.y -= offset;
		viewContainer.frame = containerRect;
		[UIView commitAnimations];
	}
	if(field == fields[0])
	{
		[UIView beginAnimations:nil context:@"scrolling"];
		[UIView setAnimationDuration:0.3];
		containerRect.origin.y = 0;
		viewContainer.frame = containerRect;
		[UIView commitAnimations];
	}
} // scrollToTextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
	[self nextButton:self];
	return YES;
} // textFieldShouldReturn

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self scrollToTextField:textField];
} // textFieldDidBeginEditing

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	CGRect		containerRect = viewContainer.frame;
	if(containerRect.origin.y != 0)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		containerRect.origin.y = 0;
	//	viewContainer.frame = containerRect;
		[UIView commitAnimations];
	} 
} // textFieldDidEndEditing

-(IBAction) nextButton:(id)sender
{
	int index = [fields indexOfObject:activeBox] + 1;
	if(index > fields.count -1)
		index = 0;
	
	id	nextField = fields[index];
	id	scrollToField = nextField;
	
	if(nextField == state)
		index++;
	else if(nextField == country)
		index++;
	else if(nextField == expireYear)
		index++;
	else if(nextField == expireMonth)
		index+=2;
	
	scrollToField = fields[index];
	[self scrollToTextField:scrollToField];

	if(nextField == state)
		[self stateButton:self];
	else if(nextField == expireYear)
		[self yearButton:self];
	else if(nextField == expireMonth)
		[self monthButton:self];
	else if(nextField == country)
		[self countryButton:self];

} // nextButton

-(IBAction) doneButton:(id)sender
{
	[activeBox resignFirstResponder];
	buttonToolBar.hidden = YES;

	CGRect		containerRect = viewContainer.frame;
	[UIView beginAnimations:nil context:@"scrolling"];
	[UIView setAnimationDuration:0.3];
	containerRect.origin.y = 0;
	viewContainer.frame = containerRect;
	[UIView commitAnimations];
} // doneButton

-(IBAction) stateButton:(id)sender
{
	QuickChoiceList *anotherViewController = [[QuickChoiceList alloc] initWithNibName:@"QuickChoiceList" bundle:nil];
	anotherViewController.referenceObject = self;
	anotherViewController.referenceList = statesArray;
	anotherViewController.referenceKey = @"state";
	anotherViewController.navTitle = @"Select a state";
	anotherViewController.currentSelection = stateChoice;
		
	[self.navigationController pushViewController:anotherViewController animated:YES];
	
} // stateButton

-(IBAction) countryButton:(id)sender
{
	QuickChoiceList *anotherViewController = [[QuickChoiceList alloc] initWithNibName:@"QuickChoiceList" bundle:nil];
	anotherViewController.referenceObject = self;
	anotherViewController.referenceList = countriesArray;
	anotherViewController.referenceKey = @"country";
	anotherViewController.navTitle = @"Select a country";
	anotherViewController.currentSelection = countryChoice;
		
	[self.navigationController pushViewController:anotherViewController animated:YES];
	
} // countryButton

-(IBAction) monthButton:(id)sender
{
	QuickChoiceList *anotherViewController = [[QuickChoiceList alloc] initWithNibName:@"QuickChoiceList" bundle:nil];
	anotherViewController.referenceObject = self;
	anotherViewController.referenceList = monthsArray;
	anotherViewController.referenceKey = @"expmonth";
	anotherViewController.navTitle = @"Select a month";
	anotherViewController.currentSelection = monthChoice;
	
	[self.navigationController pushViewController:anotherViewController animated:YES];
	
} // monthButton

-(IBAction) yearButton:(id)sender
{
	QuickChoiceList *anotherViewController = [[QuickChoiceList alloc] initWithNibName:@"QuickChoiceList" bundle:nil];
	anotherViewController.referenceObject = self;
	anotherViewController.referenceList = yearsArray;
	anotherViewController.referenceKey = @"expyear";
	anotherViewController.navTitle = @"Select a year";
	anotherViewController.currentSelection = yearChoice;
	
	[self.navigationController pushViewController:anotherViewController animated:YES];
	
} // yearButton


-(void) setChoice:(int)choice forKey:(NSString*) key
{
	if([key isEqualToString:@"state"])
	{
		stateChoice = choice;
		NSString*	stateKey = statesArray[stateChoice];
		state.text = [statesDictionary[stateKey] uppercaseString];
	}
	
	if([key isEqualToString:@"country"])
	{
		countryChoice = choice;
		NSString*	countryKey = countriesArray[countryChoice];
		country.text = [countriesDictionary[countryKey] uppercaseString];
	}
	
	if([key isEqualToString:@"expmonth"])
	{
		monthChoice = choice;
		expireMonth.text = [NSString stringWithFormat:@"%02d", monthChoice+1];
	}
	
	if([key isEqualToString:@"expyear"])
	{
		yearChoice = choice;
		expireYear.text = yearsArray[yearChoice];
	}
} // setChoice:forKey:

-(void) purchaseThread
{
	//•
	

	NSArray*			params = @[];
	
	UIDevice*		currentDevice = [UIDevice currentDevice];
	NSString*		udid = currentDevice.identifierForVendor.UUIDString;

	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	NSDictionary*	regInfo = [ud objectForKey:@"registrationInfo"];
	NSString*		licenseKey = regInfo[@"licenseKey"];
	
	params = [params arrayByAddingObject:[NSString stringWithFormat:@"UDID=%@", udid]];
	if(licenseKey && licenseKey.length)
		params = [params arrayByAddingObject:[NSString stringWithFormat:@"KEY=%@", licenseKey]];
	
	double		subtotal = oneYearSubscription ? 8.99 : 4.99;
	double		tax = [(state.text).uppercaseString isEqual:@"VA"] ? subtotal * VA_SALES_TAX : 0.0;
	double		chargetotal = subtotal + tax;

	NSString*	subLength = oneYearSubscription ? @"12" : @"6";

#if 0
	subtotal = 1.0;
	tax = 0.0;
	chargetotal = 1.0;
#endif
	
	params = [params arrayByAddingObject:[NSString stringWithFormat:@"subtotal=%2.2f", subtotal]];
	params = [params arrayByAddingObject:[NSString stringWithFormat:@"tax=%2.2f", tax]];
	params = [params arrayByAddingObject:[NSString stringWithFormat:@"chargetotal=%2.2f", chargetotal]];
	params = [params arrayByAddingObject:@"shipping=0.0"];
	
#if 0	
	// this block produces good params for the First Data xml API gateway

	NSString*	urlString = @"https://sales.visualsoftinc.com/orkovxmlsale.php";
	
	params = [params arrayByAddingObject:[NSString stringWithFormat:@"xMonths=%@", subLength]];
	
	params = [params arrayByAddingObject:[NSString stringWithFormat:@"name=%@", nameOnCard.text]];
	params = [params arrayByAddingObject:[NSString stringWithFormat:@"address1=%@", addr1.text]];
	params = [params arrayByAddingObject:[NSString stringWithFormat:@"city=%@", city.text]];
	params = [params arrayByAddingObject:[NSString stringWithFormat:@"cardnumber=%@", ccnumber.text]];
	params = [params arrayByAddingObject:[NSString stringWithFormat:@"cardexpmonth=%@", expireMonth.text]];
	params = [params arrayByAddingObject:[NSString stringWithFormat:@"cardexpyear=%@", [expireYear.text substringFromIndex:[expireYear.text length]-2]];

	if([csv.text length])
		params = [params arrayByAddingObject:[NSString stringWithFormat:@"cvm=%@", csv.text]];
	
	if([addr2.text length])
		params = [params arrayByAddingObject:[NSString stringWithFormat:@"address2=%@", addr2.text]];
	
	if([state.text length])
		params = [params arrayByAddingObject:[NSString stringWithFormat:@"state=%@", state.text]];
	
	if([zipcode.text length])
		params = [params arrayByAddingObject:[NSString stringWithFormat:@"zip=%@", zipcode.text]];
	
	if([country.text length])
		params = [params arrayByAddingObject:[NSString stringWithFormat:@"country=%@", country.text]];
	
	if([phone.text length])
		params = [params arrayByAddingObject:[NSString stringWithFormat:@"phone=%@", phone.text]];
	
	if([email.text length])
		params = [params arrayByAddingObject:[NSString stringWithFormat:@"email=%@", email.text]];
#else
	// this block produces good params for the First Data Connect gateway
	
	params = [params arrayByAddingObject:[NSString stringWithFormat:@"xMonths=%@", subLength]];
	
	params = [params arrayByAddingObject:[NSString stringWithFormat:@"bname=%@", nameOnCard.text]];
	params = [params arrayByAddingObject:[NSString stringWithFormat:@"baddr1=%@", addr1.text]];
	params = [params arrayByAddingObject:[NSString stringWithFormat:@"bcity=%@", city.text]];
	
	NSString* collapsedCardNumber = [[ccnumber.text componentsSeparatedByString:@" "] componentsJoinedByString:@""];
	params = [params arrayByAddingObject:[NSString stringWithFormat:@"cardnumber=%@", collapsedCardNumber]];
	params = [params arrayByAddingObject:[NSString stringWithFormat:@"expmonth=%@", expireMonth.text]];
	params = [params arrayByAddingObject:[NSString stringWithFormat:@"expyear=%@", expireYear.text]];
	
	if((csv.text).length)
		params = [params arrayByAddingObject:[NSString stringWithFormat:@"cvm=%@", csv.text]];
	
	if((addr2.text).length)
		params = [params arrayByAddingObject:[NSString stringWithFormat:@"baddr2=%@", addr2.text]];
	
	if((state.text).length)
		params = [params arrayByAddingObject:[NSString stringWithFormat:@"bstate=%@", state.text]];
	
	if((zipcode.text).length)
		params = [params arrayByAddingObject:[NSString stringWithFormat:@"bzip=%@", zipcode.text]];
	
	if((country.text).length)
		params = [params arrayByAddingObject:[NSString stringWithFormat:@"bcountry=%@", country.text]];
	
	if((phone.text).length)
		params = [params arrayByAddingObject:[NSString stringWithFormat:@"bphone=%@", phone.text]];
	
	if((email.text).length)
		params = [params arrayByAddingObject:[NSString stringWithFormat:@"email=%@", email.text]];

#endif
	
	NSString*			urlString = @"https://sales.visualsoftinc.com/orkovsalestart.php";
	NSString*			paramString = [params componentsJoinedByString:@"&"];
	NSData*				postData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
	request.HTTPMethod = @"POST";
	request.HTTPBody = postData;
	
	// Get ready for the response
	NSData *theData;
	NSURLResponse *response;
	NSError *error;
	
	// Make the request
	//NSLog(@"NSURL-2");
	theData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	NSString*	reply = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
#ifdef __DEBUG_OUTPUT__
	NSLog(reply);
	if(error)
	{
		NSLog(@"%@", error.userInfo);
	}
#endif
	GenericParser*	gp = [[GenericParser alloc] init];
	[gp parseString:reply usingDelegate:self];
	
} // purchaseThread

-(void) popWaitScreen
{
	[waitScreen dismissModalViewControllerAnimated:YES];
} // 
	
-(void) getParserResults:(NSDictionary*)tResults
{
#ifdef __DEBUG_OUTPUT__
	NSLog(@"%@", tResults);
#endif
	
	
//	NSString*	message = @"Thank you for purchasing Orkov.";
//	NSString*	title = @"Purchase";
//	NSString*	error = [tResults objectForKey:@"error"];
//	BOOL		goBack = YES;
//	
//	if(error)
//	{
//		message = error;
//		title = @"Error";
//		goBack = NO;
//	}
//	else if(tResults == nil)
//	{
//		message = @"There was a problem processing your purchase. Please try again later.";
//		title = @"Error";
//		goBack = NO;
//	}
//	else
//		[Registration handleRegistrationResult:tResults];
//	
//	UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:title
//													message:message
//												   delegate:nil
//										  cancelButtonTitle:@"OK"
//										  otherButtonTitles:nil];
//	[alert show];
//	//•
//	
//	[self performSelectorOnMainThread:@selector(popWaitScreen) withObject:nil waitUntilDone:YES];
//
//	if(goBack)
//		[self.navigationController popToRootViewControllerAnimated:YES];
//		
} // getParserResults

-(void) parserTimeout
{
	UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"Error"
													message:@"An unknown error occured."
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	//•
	
} // parserTimeout

-(void) parserError:(NSException*)localExcaption
{
	UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"Error"
													message:@"There was an error reading the server's reply."
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	//•
} // parserError

-(void) userAgreed
{
	[self performSelectorOnMainThread:@selector(popDisclaimerScreen) withObject:nil waitUntilDone:NO];
}
	
-(void) userCancelled
{
	[self performSelectorOnMainThread:@selector(popDisclaimerScreen) withObject:nil waitUntilDone:YES];
	[self.navigationController popViewControllerAnimated:YES];
}

-(void) popDisclaimerScreen
{
	[disclaimer dismissModalViewControllerAnimated:NO];
	
} // 

-(void) pushDisclaimerScreen
{
	disclaimer = [[CreditDisclaimer alloc] initWithNibName:@"CreditDisclaimer" bundle:nil];
	disclaimer.delegate = self;
	[self presentModalViewController:disclaimer animated:NO];
} // 

	
@end
