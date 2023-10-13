//
//  PMCAdditions.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/6/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//



@interface NSString(PMCAdditions) 

-(NSString*)author;
-(NSArray*)authors;

@end

@interface NSDictionary(PMCAdditions) 
-(NSString*)author;
-(NSArray*)authors;

@end

@interface NSArray(PMCAdditions) 
-(NSString*)author;
-(NSArray*)authors;

@end

