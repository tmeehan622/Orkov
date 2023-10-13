//
//  RelatedResults.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/12/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultsController.h"

@interface RelatedResults : ResultsController {
}
@property (nonatomic, strong) NSArray   *relatedList;

-(void)searchForRelated:(NSString*)term;
-(void)_searchRelated;
-(void) getRelatedResults:(NSNotification*)notification;
-(void) _getRelatedResults:(NSDictionary*)tResults;
@end
