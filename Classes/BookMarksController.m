//
//  BookMarksController.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 7/20/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "BookMarksController.h"
#import "BookmarkCell.h"
#import "AbstractView.h"
#import "NotesView.h"
#import "FullTextViewController.h"
#import "PDFViewController.h"
#import "Pubmed_ExperimentAppDelegate.h"

static NSMutableDictionary*	gBookmarks;

@implementation BookMarksController
@synthesize contentView;
@synthesize tableView;
@synthesize editingNoteIndex;
@synthesize displayIndex;
@synthesize ContFrameLand;
@synthesize ContFramePort;
@synthesize VShiftLandscape;
@synthesize VShiftPortrait;
@synthesize bookmarks;
@synthesize abstractView;

+(NSString*) bookmarksFile {
    NSFileManager *fileManager        = [NSFileManager defaultManager];
    NSArray       *paths              = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString      *documentsDirectory = paths[0];
	
    BOOL exists = [fileManager fileExistsAtPath:documentsDirectory];
    if (!exists) {
        BOOL success = [fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:nil];

        if (!success) {
            NSAssert(0, @"Failed to create Documents directory.");
        }
    }
	
    NSString *prefPath = [documentsDirectory stringByAppendingFormat:@"/bookmarks.plist"];
	return prefPath;
}

+(NSMutableDictionary*) gBookmarks {
	if(gBookmarks == nil) {
		gBookmarks = [NSMutableDictionary dictionaryWithContentsOfFile:[BookMarksController bookmarksFile]];
        if(!gBookmarks){
			gBookmarks = [[NSMutableDictionary alloc] init];
        }
	}
	return gBookmarks;
}

+(void) saveBookmarks {
    if(gBookmarks == nil){
		return;
    }
	
	[gBookmarks writeToFile:[BookMarksController bookmarksFile] atomically:YES];
}

+(void) addBookmark:(NSDictionary*)newBM forDatabase:(NSString*)dbname {
	NSMutableArray  *bmList = [BookMarksController gBookmarks][dbname];
	
    if(bmList == nil){
		bmList = [NSMutableArray array];
    }
	
	NSString     *pmcid      = [newBM objectAtPath:@"MedlineCitation/PMID"];
	NSDictionary *oldArticle = nil;
    
	for(NSDictionary*d in bmList) {
		NSString    *thisPmcid = [d objectAtPath:@"MedlineCitation/PMID"];
		if([thisPmcid isEqualToString:pmcid]) {
			oldArticle = d;
			break;
		}
	}
    
    if(oldArticle){
		bmList[[bmList indexOfObject:oldArticle]] = newBM;
    } else {
		[bmList addObject:newBM];
    }
	[BookMarksController gBookmarks][dbname] = bmList;
	[BookMarksController saveBookmarks];
}

+(NSMutableArray*) bookmarksForDB:(NSString*) dbname {
	NSMutableArray  *bmList = [BookMarksController gBookmarks][dbname];
	
    if(bmList == nil){
		bmList = [NSMutableArray array];
    }
	
	[BookMarksController gBookmarks][dbname] = bmList;
	
	return bmList;
}

+(NSDictionary*) findBookmarkWithID:(NSString*)pubID forDB:(NSString*)dbname {
	NSMutableArray  *bmList = [BookMarksController gBookmarks][dbname];
	
	for(NSDictionary*d in bmList) {
		NSString  *thisID = [d objectAtPath:@"MedlineCitation/PMID"];
       
        if(thisID && [thisID isEqualToString:pubID]){
			return d;
        }
	}
	return nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		bookmarks = [BookMarksController bookmarksForDB:@"pubmed"];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addBookmarkListner:) name:@"ADD_BOOKMARK" object:nil];
		ContFrameLand = CGRectMake(0,0,480,229);
		ContFramePort = CGRectMake(0,0,320,389);
		VShiftLandscape = 32.0;
		VShiftPortrait = 50.0;
    }
    return self;
}


-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [tableView reloadData];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title               = @"Favorites";
	self.navigationItem.rightBarButtonItem  = self.editButtonItem;
    
    UINib *nib = [UINib nibWithNibName:@"AbstractCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"BookmarkCell"];
    [tableView registerNib:nib forCellReuseIdentifier:@"BookmarkCell_WEB"];
    [tableView registerNib:nib forCellReuseIdentifier:@"BookmarkCell_PDF"];
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 80.0;
}

- (void) addBookmarkListner:(NSNotification*)notification {
	[BookMarksController addBookmark:notification.userInfo forDatabase:@"pubmed"];
    if(tableView){
		[tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark table methods

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [tableView setEditing:editing animated:YES];
    if(!editing){
		[BookMarksController saveBookmarks];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return bookmarks.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString        *CellIdentifier = @"BookmarkCell";
	NSDictionary    *article        = bookmarks[indexPath.row];
	//NSDictionary*	medlineCitation = [article objectForKey:@"MedlineCitation"];
	//id			otherID         = [medlineCitation objectForKey:@"OtherID"];
	NSString        *pmcID          = nil;
	NSString        *doi            = nil;
    NSDictionary    *thenoteDict    = article[@"notes"];
    NSString        *thenote;
    
    if (thenoteDict != nil){
       thenote        = thenoteDict[@"text"];
    }

	NSArray *ArticleIdList = [article objectAtPath:@"PubmedData/ArticleIdList/ArticleId"];
   
    if(ArticleIdList && ![ArticleIdList isKindOfClass:[NSArray class]]){
		ArticleIdList = @[ArticleIdList];
    }
    
	for(id xidType in ArticleIdList) {
		NSString    *xidTypeString = nil;
		if(![xidType isKindOfClass:[NSDictionary class]]) {
			if([xidType isKindOfClass:[NSString class]]) {
                if ([[xidType uppercaseString] hasPrefix:@"PMC"]){
					pmcID = xidType;
                }
			}
			continue;
		}
		
		xidTypeString = xidType[@"IdType"];
        
		if([xidTypeString.uppercaseString isEqualToString:@"PMC"]) {
			pmcID = xidType[@"Id"];
		} else {
            if([xidTypeString.uppercaseString isEqualToString:@"DOI"]){
                doi = xidType[@"Id"];
            }
        }
	}
		
    BookmarkCell *cell = nil;
	
    if(doi){
		CellIdentifier = @"BookmarkCell_WEB";
    }
    
    if(pmcID){
		CellIdentifier = @"BookmarkCell_PDF";
    }

    if (cell == nil) {
        cell = (BookmarkCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.btn_Note.hidden = NO;
        [cell.btn_Note addTarget:self action:@selector(notesButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

		if(pmcID || doi) {
			cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
	}
    
    CGFloat h = cell.contentView.frame.size.height;
    
    if (thenote.length > 0){
        cell.btn_Note.imageView.image = [UIImage imageNamed:@"Misc_StickyNoteActive"];
    } else {
        cell.btn_Note.imageView.image = [UIImage imageNamed:@"Misc_StickyNote"];
    }

    cell.label_RecordNumber.text = [NSString stringWithFormat:@"%ld", indexPath.row + 1];

	cell.info = article;
	
    return cell;
}

-(void)notesButtonClicked:(id)sender {
	UIView      *senderButton = (UIView*) sender;
	NSIndexPath *indexPath    = [tableView indexPathForCell: (UITableViewCell*)senderButton.superview.superview];
	
	editingNoteIndex         = indexPath.row;
	NSDictionary    *article = bookmarks[editingNoteIndex];
	NotesView       *nv      = [[NotesView alloc] initWithNibName:@"NotesView" bundle:nil];
    nv.info                  = article;
	nv.delegate              = self;
    
	[self.navigationController pushViewController:nv animated:YES];
}

-(void) updateBookmarkInfo:(NSDictionary*)newInfo {
	bookmarks[editingNoteIndex] = newInfo;
	[BookMarksController saveBookmarks];
}

-(void)ftButtonClicked:(id)sender {
	UIView        *senderButton   = (UIView*) sender;
	NSIndexPath   *indexPath      = [tableView indexPathForCell: (UITableViewCell*)senderButton.superview.superview];
	BookmarkCell  *ac             = (BookmarkCell*) [tableView cellForRowAtIndexPath:indexPath];
	
	FullTextViewController *anotherViewController = [[FullTextViewController alloc] initWithNibName:@"FullTextViewController" bundle:nil];
	anotherViewController.pmcid                   = ac.pmcID;
	anotherViewController.info                    = bookmarks[indexPath.row];
	
	[self.navigationController pushViewController:anotherViewController animated:YES];
}

-(BOOL) canShowPrevious {
	return (displayIndex > 0);
}

-(BOOL) canShowNext {
	return (displayIndex < bookmarks.count-1);
}

-(void) showPrevious {
    if(displayIndex > 0){
		[self updateAbstractViewForArticle:--displayIndex];
    }
}

-(void) showNext {
    if(displayIndex < bookmarks.count-1){
		[self updateAbstractViewForArticle:++displayIndex];
    }
}

-(void) updateAbstractViewForArticle:(int)index {
	displayIndex      = index;
	abstractView.info = bookmarks[index];
	
    NSString  *pmi    = nil;
	
	NSDictionary *article = bookmarks[index][@"MedlineCitation"];
	pmi                   = article[@"PMID"];
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(abstractView == nil) {
		abstractView = [[AbstractView alloc] initWithNibName:@"AbstractView" bundle:nil];
		abstractView.myController = (ResultsController*)self;
	}
	
	[self.navigationController pushViewController:abstractView animated:YES];
	abstractView.info = bookmarks[indexPath.row];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)theTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	BookmarkCell  *ac = (BookmarkCell*) [theTableView cellForRowAtIndexPath:indexPath];
	
	FullTextViewController *anotherViewController = [[FullTextViewController alloc] initWithNibName:@"FullTextViewController" bundle:nil];
	anotherViewController.pmcid                   = ac.pmcID;
	anotherViewController.info                    = bookmarks[indexPath.row];
	
	[self.navigationController pushViewController:anotherViewController animated:YES];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)theTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)theTableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    id	item = bookmarks[sourceIndexPath.row];
    [bookmarks removeObjectAtIndex:sourceIndexPath.row];
    [bookmarks insertObject:item atIndex:destinationIndexPath.row];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)theTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Delete the row from the data source.
		[bookmarks removeObjectAtIndex:indexPath.row];
		[theTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}   
	else if (editingStyle == UITableViewCellEditingStyleInsert) {
		// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
	}   
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)theTableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the item to be re-orderable.
	return YES;
}

-(BOOL) isLandscape {
	UIInterfaceOrientation orient = [UIDevice currentDevice].orientation;
	
    if((orient == UIInterfaceOrientationLandscapeLeft) || (orient == UIInterfaceOrientationLandscapeRight)){
		return YES;
    } else {
		return NO;
    }
}

#pragma mark Orientation support

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

@end
