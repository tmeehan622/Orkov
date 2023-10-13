//
//  ResultsController.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 7/9/09.
//  Copyright 2009 The Frodis Co.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
//
#import "Pubmed_ExperimentAppDelegate.h"

@class AbstractView;

@interface ResultsController : UIViewController <MFMailComposeViewControllerDelegate, UITableViewDelegate>{
}

@property (nonatomic, weak) IBOutlet UIView			    *contentView;
@property (nonatomic, weak) IBOutlet UIView			    *busy;
@property (nonatomic, weak) IBOutlet UITableView		*searchListView;
@property (nonatomic, weak) IBOutlet UILabel			*statsLabel;
@property (nonatomic, weak) IBOutlet UIBarButtonItem	*backButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem	*nextButton;
@property (nonatomic, weak) IBOutlet UIView			    *noHits;
@property (nonatomic, weak) IBOutlet UIToolbar			*myToolbar;
@property (nonatomic, assign) BOOL						didGetMemoryWarning;
@property (nonatomic, assign) CGRect					ContFrameLand;
@property (nonatomic, assign) CGRect					ContFramePort;
@property (nonatomic, assign) CGFloat					VShiftLandscape;
@property (nonatomic, assign) CGFloat					VShiftPortrait;
@property (nonatomic, assign) int                        recordsPerPage;
@property (nonatomic, assign) int                        bufferPageCount;
@property (nonatomic, assign) int						displayIndex;
@property (nonatomic, strong) AbstractView              *abstractView;
@property (nonatomic, strong) NSString					*searchTerm;
@property (nonatomic, strong) NSString					*statsText;
@property (nonatomic, strong) NSDictionary				*searchResults;
@property (nonatomic, strong) NSDictionary				*fetchResults;
@property (nonatomic, strong) NSArray					*articles;
@property (nonatomic, strong) NSArray					*allArticles;
@property (nonatomic, strong) NSArray					*fullTextArticles;
@property (nonatomic, strong) NSNumberFormatter			*decimalFormatter;
@property (nonatomic, strong) NSString					*dbName;
@property (nonatomic, strong) NSNumber					*startingRecordNumber;
@property (nonatomic, strong) NSNumber					*endingRecordNumber;
@property (nonatomic, strong) NSNumber					*totalRecordNumber;
@property (nonatomic, strong) NSTimer					*statusTimer;
@property (nonatomic, strong) UISegmentedControl		*allOrFullText;

+(NSMutableDictionary*)viewedAbstracts;
+(BOOL) hasBeenViewed:(NSString*)pmid;
+(void) addViewedAbstract:(NSString*)pmid;
+(void) saveViewedAbstracts;
+(NSString*) viewedAbstractsFile;

- (IBAction) allOrFullTextChanged:(id)sender;

-(void)searchFor:(NSString*)term;
-(void)_search;

-(void) getSearchResults:(NSNotification*)notification;
-(void) _getSearchResults:(NSDictionary*)tResults;
-(void) getFetchResults:(NSNotification*)notification;
-(void) _getFetchResults:(NSDictionary*)tResults;

-(IBAction) searchButton:(id)sender;
-(IBAction) doBackButton:(id)sender;
-(IBAction) doNextButton:(id)sender;
-(void) adjustToobar;
-(void) disableNavigation:(BOOL)disable;

-(IBAction) sendAsEmail:(id)sender;
-(void) clearEmailStatus:(NSTimer*)timer;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL canShowPrevious;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL canShowNext;

-(void) showPrevious;
-(void) showNext;

-(void) updateAbstractViewForArticle:(int)index;

-(void) searchAgain:(NSNotification*)notification;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
@end
