//
//  PDFViewController.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 9/2/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface PDFViewController : UIViewController <MFMailComposeViewControllerDelegate> {
}
@property (nonatomic, weak) IBOutlet UIWebView   *myWebView;
@property (nonatomic, strong) NSString      *pdfFileName;
@property (nonatomic, strong) NSDictionary  *info;
@property (nonatomic, strong) NSString      *pmcID;




@end
