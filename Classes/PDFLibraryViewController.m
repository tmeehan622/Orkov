//
//  PDFLibraryViewController.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 9/4/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "PDFLibraryViewController.h"
#import "BookmarkCell.h"
#import "PDFViewController.h"
#import "GenericParser.h"
#import "PDFNotesView.h"

static NSMutableDictionary  *gArticles;

@implementation PDFLibraryViewController
+(NSString*) articlesFile {
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
	
    NSString *prefPath = [documentsDirectory stringByAppendingFormat:@"/articles.plist"];
	return prefPath;
}

+(NSMutableDictionary*) gArticles {
	if(gArticles == nil) {
		gArticles = [NSMutableDictionary dictionaryWithContentsOfFile:[PDFLibraryViewController articlesFile]];
        if(gArticles){
			;
        } else {
			gArticles = [[NSMutableDictionary alloc] init];
        }
	}
	
	return gArticles;
}

+(void) saveArticles {
	if(gArticles == nil)
		return;
	
	[gArticles writeToFile:[PDFLibraryViewController articlesFile] atomically:YES];
}

+(void) addArticle:(NSDictionary*)newBM forDatabase:(NSString*)dbname {
	NSMutableArray  *bmList  = [PDFLibraryViewController gArticles][dbname];
    NSString        *newPMID = nil;
    
    if(bmList == nil){
		bmList = [NSMutableArray array];
    } else {
        newPMID = [newBM objectAtPath:@"MedlineCitation/PMID"];
    }
	
	NSString  *pmcid = [newBM objectAtPath:@"MedlineCitation/OtherID"];
	
    if([pmcid isKindOfClass:[NSArray class]]) {
		NSArray *tmpArray = (NSArray*) pmcid;
		for(NSString*s in tmpArray) {
			if([s.uppercaseString hasPrefix:@"PMC"]) {
				pmcid = s;
				break;
			}
		}
	}
    
    if (pmcid == nil) {
        NSArray *ArticleIdList = [newBM objectAtPath:@"PubmedData/ArticleIdList/ArticleId"];
        if(ArticleIdList && ![ArticleIdList isKindOfClass:[NSArray class]])
            ArticleIdList = @[ArticleIdList];
        
        for(id xidType in ArticleIdList) {
            NSString    *xidTypeString = nil;
            if(![xidType isKindOfClass:[NSDictionary class]])
                continue;
            
            xidTypeString = xidType[@"IdType"];
            if([xidTypeString.uppercaseString isEqualToString:@"PMC"]){
                pmcid = xidType[@"Id"];
                break;
            }
        }
    }
    
    if(![pmcid hasPrefix:@"PMC"]){
		pmcid = [@"PMC" stringByAppendingString:pmcid];
    }
	
    NSDictionary  *oldArticle = nil;
	
    for(NSDictionary*d in bmList) {
        NSArray  *otherIDs = [d objectAtPath:@"MedlineCitation/OtherID"];
        NSString *PMID     = [d objectAtPath:@"MedlineCitation/PMID"];

        if(otherIDs != nil){
            if(![otherIDs isKindOfClass:[NSArray class]]){
                otherIDs = @[otherIDs];
            }
            
            for(NSString *thisID in otherIDs){
                if(thisID && [thisID isEqualToString:pmcid]) {
                    oldArticle = d;
                    break;
                }
            }
        } else {
            if ([PMID isEqualToString:newPMID]){
                oldArticle = d;
                break;
            }
        }
	}
    
    if(oldArticle){
		bmList[[bmList indexOfObject:oldArticle]] = newBM;
    } else {
		[bmList addObject:newBM];
    }
	
	[PDFLibraryViewController gArticles][dbname] = bmList;
	[PDFLibraryViewController saveArticles];
}

+(NSMutableArray*) articlesForDB:(NSString*) dbname {
	NSMutableArray  *bmList = [PDFLibraryViewController gArticles][dbname];
	
    if(bmList == nil) {
		bmList = [NSMutableArray array];
    }
	
	[PDFLibraryViewController gArticles][dbname] = bmList;
	
	return bmList;
}

+(NSDictionary*) findArticleWithID:(NSString*)pubID forDB:(NSString*)dbname {
	NSMutableArray  *bmList = [PDFLibraryViewController gArticles][dbname];
	NSString        *pmcid  = pubID;

    if(![pmcid hasPrefix:@"PMC"]){
		pmcid = [@"PMC" stringByAppendingString:pmcid];
    }

	for(NSDictionary*d in bmList) {
		NSArray     *otherIDs = [d objectAtPath:@"MedlineCitation/OtherID"];
		NSString    *newPMID  = [d objectAtPath:@"MedlineCitation/PMID"];
        
        if (otherIDs != nil){
            if(![otherIDs isKindOfClass:[NSArray class]]){
                otherIDs = @[otherIDs];
            }
            
            for(NSString  *thisID in otherIDs) {
                if(thisID && [thisID isEqualToString:pmcid]){
                    return d;
                }
            }
        }
        if ([newPMID isEqualToString:pubID]){
            return d;
        }
	}
	
	return nil;
}

+(NSDictionary*) findArticlePDFWithID:(NSString*)pubID forDB:(NSString*)dbname {
    NSMutableArray  *bmList = [PDFLibraryViewController gArticles][dbname];
    NSString        *pmcid  = pubID;
    
    if(![pmcid hasPrefix:@"PMC"]){
        pmcid = [@"PMC" stringByAppendingString:pmcid];
    }
    
    for(NSDictionary*d in bmList) {
        NSArray     *otherIDs = [d objectAtPath:@"MedlineCitation/OtherID"];
        NSString    *newPMID  = [d objectAtPath:@"MedlineCitation/PMID"];
        
        if(![otherIDs isKindOfClass:[NSArray class]]){
            otherIDs = @[otherIDs];
        }
        
        for(NSString  *thisID in otherIDs) {
            if(thisID && [thisID isEqualToString:pmcid]){
                return d;
            }
        }
        
        if ([newPMID isEqualToString:pmcid]){
            return d;
        }
    }
    
    return nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"ADD_BOOKMARK" object:nil];			// we don't want to list for the same messages as the super class
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addBookmarkListner:) name:@"SAVE_PDF" object:nil];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self syncDownloadsToPlist];
    self.bookmarks = [PDFLibraryViewController articlesForDB:@"pubmed"];
    [self.tableView reloadData];
}

- (void) addBookmarkListner:(NSNotification*)notification {
	[PDFLibraryViewController addArticle:notification.userInfo forDatabase:@"pubmed"];
    if(self.tableView){
		[self.tableView reloadData];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];

	self.bookmarks = [PDFLibraryViewController articlesForDB:@"pubmed"];
	self.navigationItem.title = @"Saved PDFs";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
    if(!editing){
		[PDFLibraryViewController saveArticles];
    }
}

-(void) syncDownloadsToPlist {
    NSArray       *paths       = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString      *docpath     = paths[0];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    int c = [self.bookmarks count];
    NSMutableArray *indexToDelete = [NSMutableArray array];
    
    if ( c > 0){
        for (int i = c-1; i >= 0; i--){
           NSDictionary  *article     = (self.bookmarks)[i];
           NSDictionary  *pubMedDatat = article[@"PubmedData"];
           NSString      *tempS       = [self pdfFileNameFromArticle:pubMedDatat];
           NSString      *pdfPath     = [docpath stringByAppendingFormat:@"/%@.pdf", tempS];
            
           if(![fileManager fileExistsAtPath:pdfPath]){
               NSNumber *idxNum = [NSNumber numberWithInt:i];
               if (idxNum != nil){
                   [indexToDelete addObject:idxNum];
               }
           }
        }
    }
    
    if ([indexToDelete count] > 0) {
        int k = [indexToDelete count];
        
        for (int i = 0; i < k; i++){
            [self.bookmarks removeObjectAtIndex:i];
        }
        [PDFLibraryViewController saveArticles];
    }
}

-(void) updatePDFInfo:(NSDictionary*)newInfo {
	(self.bookmarks)[self.editingNoteIndex] = newInfo;
	[PDFLibraryViewController saveArticles];
}

-(void)notesButtonClicked:(id)sender
{
	UIView      *senderButton = (UIView*) sender;
	NSIndexPath *indexPath    = [self.tableView indexPathForCell: (UITableViewCell*)senderButton.superview.superview];
	
	self.editingNoteIndex    = indexPath.row;
	NSDictionary    *article = (self.bookmarks)[self.editingNoteIndex];
	PDFNotesView    *nv      = [[PDFNotesView alloc] initWithNibName:@"NotesView" bundle:nil];
	
    nv.info = article;
	nv.delegate = self;
    
	[self.navigationController pushViewController:nv animated:YES];
	
} // notesButtonClicked


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString        *CellIdentifier  = @"BookmarkCell";
	NSDictionary    *article         = (self.bookmarks)[indexPath.row];
	NSDictionary    *medlineCitation = article[@"MedlineCitation"];
	id	            otherID          = medlineCitation[@"OtherID"];
	NSString        *pmcID           = nil;
    NSDictionary    *thenoteDict     = article[@"notes"];
    NSString        *thenote;
    
    if (thenoteDict != nil){
        thenote = thenoteDict[@"text"];
    } else {
        thenote = @"";
    }
    
	if(otherID) {
		if([otherID isKindOfClass:[NSArray class]]) {
			for(NSString* thisID in otherID) {
				if([thisID.uppercaseString hasPrefix:@"PMC"]) {
					pmcID = [thisID substringFromIndex:3];
					break;
				}
			}
		} else if([otherID isKindOfClass:[NSString class]]) {
			pmcID = otherID;
		}
	}
	
    BookmarkCell *cell = nil;
	
	cell = (BookmarkCell*) [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BookmarkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		UIButton    *xButton = [UIButton buttonWithType:UIButtonTypeCustom];
		UIImage     *ftImage = [UIImage imageNamed:@"Misc_StickyNote"];
		[xButton setImage:ftImage forState:UIControlStateNormal];
		[xButton setImage:ftImage forState:UIControlStateSelected];
		[xButton addTarget:self action:@selector(notesButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		CGRect noteFrame = CGRectMake(4, 25, 30, 30);
		xButton.frame = noteFrame;
		[cell.contentView addSubview:xButton];
		xButton.frame = noteFrame;
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    cell.btn_Note.hidden = YES;
    [cell.btn_Note addTarget:self action:@selector(notesButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    cell.label_RecordNumber.text = [NSString stringWithFormat:@"%ld", indexPath.row + 1];
   
    if (thenote.length > 0){
        cell.btn_Note.imageView.image = [UIImage imageNamed:@"Misc_StickyNoteActive"];
    } else {
        cell.btn_Note.imageView.image = [UIImage imageNamed:@"Misc_StickyNote"];
    }

	cell.info = article;
	
    return cell;
}

-(NSString*)pdfFileNameFromArticle:(NSDictionary*) PubmedData {
    NSArray     *ArticleIdList = [PubmedData objectAtPath:@"ArticleIdList/ArticleId"];
    NSString    *pmcID = nil;
    NSString    *retString = nil;

    if(ArticleIdList && ![ArticleIdList isKindOfClass:[NSArray class]]){
        ArticleIdList = @[ArticleIdList];
    }

    for(id xidType in ArticleIdList) {
        NSString    *xidTypeString = nil;

        if(![xidType isKindOfClass:[NSDictionary class]])
            continue;
        
        xidTypeString = xidType[@"IdType"];
        if([xidTypeString.uppercaseString isEqualToString:@"PMC"]) {
            pmcID = xidType[@"Id"];
            break;
        }
    }
    
    NSRange r = [pmcID rangeOfString:@"PMC"];
    BOOL found = (r.location != NSNotFound);
    
    if (found == YES){
        retString = [pmcID substringFromIndex:3];
    } else {
        retString = pmcID;
    }
    
    return retString;
}

-(void)deletePDFNamed:(NSString*) fName {
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *pdfPath = [documentsDirectory stringByAppendingFormat:@"/%@.pdf", fName];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:pdfPath]){
        [fileManager removeItemAtPath:pdfPath error:nil];
    }
}

- (void)tableView:(UITableView *)theTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary    *article = (self.bookmarks)[indexPath.row];
    NSDictionary    *pubMedDatat = article[@"PubmedData"];
    NSString        *pdfFileName = nil;
    
    if (pubMedDatat != nil){
        pdfFileName = [self pdfFileNameFromArticle:pubMedDatat];
    }
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [self.bookmarks removeObjectAtIndex:indexPath.row];
        [theTableView deleteRowsAtIndexPaths:@[indexPath]withRowAnimation:UITableViewRowAnimationFade];
        [PDFLibraryViewController saveArticles];
        
        if (pdfFileName != nil){
            [self deletePDFNamed:pdfFileName];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary*	article = (self.bookmarks)[indexPath.row];
    
    NSLog(@"Article: %@",article);
    NSDictionary    *medlineCitation = article[@"MedlineCitation"];
    NSDictionary    *pubMedDatat = article[@"PubmedData"];
	id			    otherID = medlineCitation[@"OtherID"];
	NSString        *pmcID = nil;
	
	if(otherID)
	{
		if([otherID isKindOfClass:[NSArray class]])
		{
			for(NSString* thisID in otherID)
			{
				if([thisID.uppercaseString hasPrefix:@"PMC"])
				{
					pmcID = [thisID substringFromIndex:3];
					break;
				}
			}
		} // array
		else if([otherID isKindOfClass:[NSString class]])
		{
			pmcID = otherID;
		}
	}
    if (pmcID == nil){
        
        pmcID = [self pdfFileNameFromArticle: pubMedDatat];
        
    }
    
	if([pmcID.uppercaseString hasPrefix:@"PMC"])
		pmcID = [pmcID substringFromIndex:3];
	
	NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = paths[0];
	NSString *pdfPath = [documentsDirectory stringByAppendingFormat:@"/%@.pdf", pmcID];		
	
	PDFViewController *anotherViewController = [[PDFViewController alloc] initWithNibName:@"PDFViewController" bundle:nil];
	anotherViewController.pdfFileName = pdfPath;
	anotherViewController.info = article;
	
	[self.navigationController pushViewController:anotherViewController animated:YES];
	
	
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	
} // didSelectRowAtIndexPath

@end
