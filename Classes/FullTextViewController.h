//
//  FullTextViewController.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 7/31/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "GenericParser.h"
#import "PDFNotesView.h"

@interface FullTextViewController : UIViewController <GenericParserClient, MFMailComposeViewControllerDelegate,pdfnotesdelegate, UIWebViewDelegate> {
}

@property (nonatomic, weak) IBOutlet	UIView				*contentView;
@property (nonatomic, weak) IBOutlet	UIView				*busy;
@property (nonatomic, weak) IBOutlet	UILabel				*busyText;
@property (nonatomic, weak) IBOutlet	UIWebView			*fullTextView;
@property (nonatomic, weak) IBOutlet	UIBarButtonItem		*bookmarkButton;
@property (nonatomic, weak) IBOutlet	UIBarButtonItem		*emailButton;
@property (nonatomic, weak) IBOutlet	UIBarButtonItem		*dumpButton;
@property (nonatomic, weak) IBOutlet	UIBarButtonItem		*pdfButton;
@property (nonatomic, weak) IBOutlet	UIToolbar			*myToolbar;
@property (nonatomic, weak) IBOutlet	UIPickerView		*jumpPicker;
@property (nonatomic, weak) IBOutlet	UIView				*jumpPickerContainer;
@property (nonatomic, weak) IBOutlet	UIToolbar			*webToolbar;
@property (nonatomic, weak) IBOutlet	UIBarButtonItem		*backButton;
@property (nonatomic, weak) IBOutlet	UIBarButtonItem		*forwardButton;
@property (nonatomic, weak) IBOutlet	UIBarButtonItem		*refreshButton;
@property (nonatomic, weak) IBOutlet	UIImageView			*popUpImage;
@property (nonatomic, assign) BOOL							noDownload;
@property (nonatomic, assign) BOOL							isPDF;
@property (nonatomic, assign) BOOL							isAlternate;
@property (nonatomic, assign) BOOL							parserWarningAlready;
@property (nonatomic, assign) int                            pdfAvailable;
@property (nonatomic, assign) BOOL                            canDownloadPDF;
@property (nonatomic, assign) BOOL							showingPicker;
@property (nonatomic, assign) BOOL							showingExternalSite;
@property (nonatomic, assign) double							pickerTop;
@property (nonatomic, assign) CGRect							ContFrameLand;
@property (nonatomic, assign) CGRect							ContFramePort;
@property (nonatomic, assign) CGFloat						VShiftLandscape;
@property (nonatomic, assign) CGFloat						VShiftPortrait;
@property (nonatomic, strong) NSArray						*pickerMap;
@property (nonatomic, strong) NSString						*fullTextSource;
@property (nonatomic, strong) NSString						*pmcid;
@property (nonatomic, strong) NSString						*doi;
@property (nonatomic, strong) NSDictionary					*info;
@property (nonatomic, strong) NSDictionary					*infoBits;
@property (nonatomic, strong) UITextField					*bmTitleField;
@property (nonatomic, strong) NSString						*theAuthors;
@property (nonatomic, strong) NSString						*html;
@property (nonatomic, strong) NSString						*altHtmlURL;
@property (nonatomic, strong) NSString						*cacheFile;
@property (nonatomic, strong) NSString						*documentsDirectory;
@property (nonatomic, strong) NSString						*loadingMessage;
@property (nonatomic, strong) NSMutableDictionary			*imageCache;
@property (nonatomic, strong) NSTimer						*navFadeTimer;

+(void) removeTags:(NSString*)tag fromString:(NSMutableString*)htmlString;
-(IBAction) searchButton:(id)sender;
-(IBAction) addAsBookmark:(id)sender;
-(IBAction) saveAsPDF:(id)sender;
-(void) saveAsPDFThread;
-(void) saveAsPDFComplete:(NSDictionary*)newInfo;

-(IBAction) sendAsEmail:(id)sender;
-(NSMutableString*)findBlockWithTag:(NSString*)tag;
-(NSMutableString*)findBlockWithTag:(NSString*)tag inString:(NSString*)s includingTag:(BOOL)includingTag;
-(void)replace:(NSMutableString*)s tags:(NSString*)oldTag withDiv:(NSString*)newdiv;

-(NSString*) untangleAuthor:(NSDictionary*)authorDict;
-(NSString*) untangleAffiliation:(NSDictionary*)affiliationDict;
-(NSString*) untangleReference:(NSDictionary*)referenceDict manualLabel:(int)xLabel;
-(NSString*) authorsFromPersonGroup:(NSDictionary*)personGroup;

-(IBAction) dumpXML:(id)sender;
-(NSMutableString*) fixImageLinks:(NSString*)bodyText;
-(void) parserTimeout;
-(IBAction) jump:(id)sender;
-(IBAction) doJump:(id)sender;
-(IBAction) cancelJump:(id)sender;
-(IBAction) getRelated:(id)sender;

-(void) popupDone:(NSNotification*)notification;
-(void) searchAgain:(NSNotification*)notification;
-(void) getFullText:(NSNotification*)notification;
-(void) disableNavigation:(BOOL)disable;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL tryLoadingPDF;

- (BOOL)fixFigure:(NSMutableString*)bodyText;
- (void) updatePDFInfo:(NSDictionary*)newInfo;
- (void) updateBookmarkInfo:(NSDictionary*)newInfo;

-(void) popLater:(NSTimer*)timer;


- (IBAction) back:(id)sender;
- (IBAction) next:(id)sender;
- (IBAction) refresh:(id)sender;

- (void) showControls;
- (void) fadeControls:(NSTimer*)timer;
- (void) _hideControls:(NSTimer*)timer;

@end
