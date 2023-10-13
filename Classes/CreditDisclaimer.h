//
//  CreditDisclaimer.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 10/17/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CreditCard;

@interface CreditDisclaimer : UIViewController {

	CreditCard*		delegate;
}
@property (nonatomic, retain) CreditCard*		delegate;

-(IBAction) doContinue:(id)sender;
-(IBAction) doCancel:(id)sender;
@end
