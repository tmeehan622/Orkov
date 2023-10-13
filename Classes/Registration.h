//
//  Registration.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/26/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericParser.h"


@interface Registration : UIViewController <GenericParserClient> {
	IBOutlet	UITextField*		keyField;
	IBOutlet	UILabel*			expireDateField;
	IBOutlet	UILabel*			prompt;
	IBOutlet	UIButton*			buyButton;
	
	UIBarButtonItem*				cancelButton;
}
+(NSString *)decodeBase64:(NSString *)input;
+(NSDictionary*) registrationInfo;
+(BOOL) handleRegistrationResult:(NSDictionary*)tResults;
-(IBAction) useCreditCard:(id)sender;
-(IBAction) cancelKey:(id)sender;
-(void) sendRegistrationKey:(NSString*)key;
-(void) registrationComplete:(NSNotification*)notification;
+(void) checkRegistration;

@end
