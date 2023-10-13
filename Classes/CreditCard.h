//
//  CreditCard.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/26/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericParser.h"
@class Wait;
@class CreditDisclaimer;

@interface CreditCard : UIViewController <GenericParserClient> {
	IBOutlet	UITextField*		nameOnCard;
	IBOutlet	UITextField*		addr1;
	IBOutlet	UITextField*		addr2;
	IBOutlet	UITextField*		city;
	IBOutlet	UITextField*		state;
	IBOutlet	UITextField*		zipcode;
	IBOutlet	UITextField*		country;
	IBOutlet	UITextField*		phone;
	IBOutlet	UITextField*		email;
	IBOutlet	UITextField*		ccnumber;
	IBOutlet	UITextField*		csv;
	IBOutlet	UITextField*		expireMonth;
	IBOutlet	UITextField*		expireYear;

	UITextField*					activeBox;
	
	IBOutlet	UIView*				viewContainer;
	IBOutlet	UIToolbar*			buttonToolBar;

	NSArray*						fields;
	
	NSArray*						countriesArray;
	NSMutableDictionary*			countriesDictionary;
	NSArray*						statesArray;
	NSDictionary*					statesDictionary;
	NSArray*						monthsArray;
	NSArray*						yearsArray;
	int								countryChoice;
	int								stateChoice;
	int								monthChoice;
	int								yearChoice;
	
	BOOL							oneYearSubscription;
	
	UIAlertView*					presaleAlert;
	UIAlertView*					confirmationAlert;
	
	Wait*							waitScreen;
	CreditDisclaimer*				disclaimer;
	
}

-(void) scrollToTextField:(UITextField*)field;

-(IBAction) purchase:(id)sender;
-(IBAction) nextButton:(id)sender;
-(IBAction) doneButton:(id)sender;
-(IBAction) stateButton:(id)sender;
-(IBAction) countryButton:(id)sender;
-(IBAction) monthButton:(id)sender;
-(IBAction) yearButton:(id)sender;

-(void) purchaseThread;
-(void) setChoice:(int)choice forKey:(NSString*) key;
-(void) popWaitScreen;
-(void) pushDisclaimerScreen;
-(void) popDisclaimerScreen;
-(void) userAgreed;
-(void) userCancelled;
@end
