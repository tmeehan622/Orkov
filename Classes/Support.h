//
//  Support.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/26/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface Support : UIViewController <MFMailComposeViewControllerDelegate> {

}
-(IBAction) emailSupport:(id)sender;
-(IBAction) emailSales:(id)sender;

@end
