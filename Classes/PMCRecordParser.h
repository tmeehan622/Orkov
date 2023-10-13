//
//  PMCRecordParser.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/6/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericParser.h"


@interface PMCRecordParser : GenericParser {
}
@property (nonatomic, strong) NSDictionary      *currentAttributes;
@property (nonatomic, strong) NSMutableArray    *elementStack;
@property (nonatomic, strong) NSString          *currentCitationString;
@end
