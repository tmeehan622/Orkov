//
//  BookMarksController.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 7/20/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AbstractView;

@interface BookMarksController : UIViewController  {
}

@property (nonatomic, weak) IBOutlet	UIView	*contentView;
@property (nonatomic, weak) IBOutlet	UITableView	*tableView;
@property (nonatomic, assign) int		editingNoteIndex;
@property (nonatomic, assign) int		displayIndex;
@property (nonatomic, assign) CGRect		ContFrameLand;
@property (nonatomic, assign) CGRect		ContFramePort;
@property (nonatomic, assign) CGFloat	VShiftLandscape;
@property (nonatomic, assign) CGFloat	VShiftPortrait;
@property (nonatomic, strong) NSMutableArray				*bookmarks;
@property (nonatomic, strong) AbstractView					*abstractView;

+(NSString*) bookmarksFile;
+(NSMutableDictionary*) gBookmarks;
+(void) addBookmark:(NSDictionary*)newBM forDatabase:(NSString*)dbname;
+(void) saveBookmarks;
+(NSMutableArray*) bookmarksForDB:(NSString*) dbname;
+(NSDictionary*) findBookmarkWithID:(NSString*)pubID forDB:(NSString*)dbname;

-(void)ftButtonClicked:(id)sender;
-(void)notesButtonClicked:(id)sender;
-(void)updateBookmarkInfo:(NSDictionary*)newInfo;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL canShowPrevious;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL canShowNext;

-(void) showPrevious;
-(void) showNext;

-(void) updateAbstractViewForArticle:(int)index;
- (void) addBookmarkListner:(NSNotification*)notification;

@end
