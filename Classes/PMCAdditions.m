//
//  PMCAdditions.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/6/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "PMCAdditions.h"
#import "GenericParser.h"


@implementation NSString(PMCAdditions)

-(NSString*)author
{
	return self;
} // author

-(NSArray*)authors
{
	return [NSArray arrayWithObject:self];
} // authors

@end

@implementation NSDictionary(PMCAdditions)

-(NSString*)author
{
	NSString*	xrefString = [self objectAtPath:@"xref"];
	if(xrefString == nil)
		xrefString = @"";
	
	return xrefString;
} // author

-(NSArray*)authors
{
	return [NSArray arrayWithObject:[self author]];
} // authors

@end

@implementation NSArray(PMCAdditions)

-(NSString*)author
{
	return @"";
} // author

-(NSArray*)authors
{
	NSArray*	xRefsArray = [NSArray array];
	
	for(NSDictionary*d in self)
	{
		if([d isKindOfClass:[NSDictionary class]])
		{
			id	sup = [d objectForKey:@"sup"];
			if(sup)
				xRefsArray = [xRefsArray arrayByAddingObject:sup];
		}
		else
			xRefsArray = [xRefsArray arrayByAddingObject:[NSString stringWithFormat:@"%@", d]];
	}
	
	return xRefsArray;
} // authors

@end
