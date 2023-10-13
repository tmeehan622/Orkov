//
//  QueryAgent.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 6/22/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QueryAgent : NSObject<NSXMLParserDelegate> {
}
@property (nonatomic, strong) NSTimer				*searchTimer;
@property (nonatomic, strong) NSMutableDictionary	*resultDict;
@property (nonatomic, strong) NSMutableArray		*parseStack;
@property (nonatomic, strong) NSDictionary			*currentAttributes;
@property (nonatomic, strong) NSString				*dbName;
@property (nonatomic, strong) NSString                *currentElementValue;
@property (nonatomic, strong) NSString                *savedTitle;
@property (nonatomic, assign) BOOL openTitle;
@property (nonatomic, assign) BOOL blockMode;
@property (nonatomic, assign) BOOL bookArticleInProgress;
@property (nonatomic, assign) BOOL workSilently;
@property (nonatomic, assign) int  retstart;
@property (nonatomic, assign) int  retmax;
@property (nonatomic, weak) id	  delegate;

+(NSString*)esearchURL;
+(NSString*)efetchURL;
+(NSString*)eLinkURL;
-(id)initForDB:(NSString*)db;
-(void) searchFor:(NSString*)term usingDelegate:(id)aDelegate;
-(void) searchThread:(NSString*)searchString;
-(void) searchTimeout:(NSTimer*)timer;

-(void) fetchIDs:(NSArray*)pubIDs usingDelegate:(id)aDelegate;
-(void) fetchThread:(NSString*)fetchString;

-(void) getFullTextFor:(NSString*)pmid usingDelegate:(id)aDelegate;
-(void) fullTextThread:(NSString*)pmid;

-(void) fetchRelated:(NSArray*)pubIDs usingDelegate:(id)aDelegate;
-(void) relatedThread:(NSString*)fetchString;

@end

