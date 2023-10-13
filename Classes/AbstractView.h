//
//  AbstractView.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 6/22/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
//

@class ResultsController;

@interface AbstractView : UIViewController <MFMailComposeViewControllerDelegate,UIWebViewDelegate,NSURLSessionDelegate>{
}

@property (nonatomic, weak)   IBOutlet	UIBarButtonItem		*bookmarkButton;
@property (nonatomic, weak)   IBOutlet	UIBarButtonItem		*emailButton;
@property (nonatomic, weak)   IBOutlet	UIBarButtonItem		*fullTextButton;
@property (nonatomic, weak) 	IBOutlet	UIToolbar			*myToolbar;
@property (nonatomic, strong) 	IBOutlet	UIWebView			*abstractView;
@property (nonatomic, weak) 	IBOutlet	UIView				*contentView;
@property (nonatomic, strong) 	UITextField						*bmTitleField;
@property (nonatomic, strong) 	UISegmentedControl				*navArrows;
@property (nonatomic, strong) 	NSDictionary					*info;
@property (nonatomic, strong) 	NSString						*dbName;
@property (nonatomic, strong) 	NSTimer							*statusTimer;
@property (nonatomic, strong) 	NSString						*pmcID;
@property (nonatomic, strong) 	NSString						*doi;
@property (nonatomic, strong) 	NSString						*html;
@property (nonatomic, strong) 	ResultsController				*myController;
@property (nonatomic, strong) 	NSString						*cacheFile;
@property (nonatomic, assign) 	CGRect							ContFrameLand;
@property (nonatomic, assign) 	CGRect							ContFramePort;
@property (nonatomic, assign) 	CGFloat							VShiftLandscape;
@property (nonatomic, assign)     CGFloat                            VShiftPortrait;
@property (nonatomic, assign)     BOOL                            pdfAvailable;

-(IBAction) arrowTouch:(id)sender;
-(IBAction) addAsBookmark:(id)sender;
-(void) updateBookmarkInfo:(NSDictionary*)newInfo;
-(IBAction) sendAsEmail:(id)sender;
-(IBAction) viewFullText:(id)sender;
-(IBAction) getRelated:(id)sender;
-(IBAction) searchButton:(id)sender;
-(void) clearEmailStatus:(NSTimer*)timer;
@end
