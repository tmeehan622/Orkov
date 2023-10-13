//
//  PDFLibraryViewController.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 9/4/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookMarksController.h"
#import "PDFNotesView.h"

@interface PDFLibraryViewController : BookMarksController<pdfnotesdelegate> {

}

+(NSString*) articlesFile;
+(NSMutableDictionary*) gArticles;
+(void) saveArticles;
+(void) addArticle:(NSDictionary*)newBM forDatabase:(NSString*)dbname;
+(NSMutableArray*) articlesForDB:(NSString*) dbname;
+(NSDictionary*) findArticleWithID:(NSString*)pubID forDB:(NSString*)dbname;
+(NSDictionary*) findArticlePDFWithID:(NSString*)pubID forDB:(NSString*)dbname;
- (void) addBookmarkListner:(NSNotification*)notification;

@end
