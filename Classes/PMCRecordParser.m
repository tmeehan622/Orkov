//
//  PMCRecordParser.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/6/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "PMCRecordParser.h"


@implementation PMCRecordParser
@synthesize currentAttributes, elementStack, currentCitationString;

-(id) init
{
	if(self = [super init])
	{
		currentAttributes = nil;
		currentCitationString = nil;
		elementStack = [[NSMutableArray alloc] init];
	}
	return self;
} // init

 // dealloc

- (void) parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
   namespaceURI:(NSString *)namespaceURI 
  qualifiedName:(NSString *)qualifiedName 
	 attributes:(NSDictionary *)attributeDict
{
	if([elementName isEqualToString:@"citation"])
		self.currentCitationString = @"";
	
	self.currentElementValue = @"";
	NSMutableDictionary*	tempDict = [NSMutableDictionary dictionary];
	
	if(attributeDict && attributeDict.count)
	{
		if([elementName isEqualToString:@"contrib"] || [elementName isEqualToString:@"aff"] || [elementName isEqualToString:@"citation"])
			self.currentAttributes = attributeDict;
	}

	[self.parseStack addObject:tempDict];						// PUSH!
	[elementStack addObject:elementName];
	
	if((self.parseStack).count == 1)
		self.resultDict = (self.parseStack)[0];
	
} // parser:didStartElement

/*
 When we get to the end of an element we want to look at it and compare it to the element on the
 top of the stack. If it is the same type
 */

- (void) parser:(NSXMLParser *)parser 
  didEndElement:(NSString *)elementName 
   namespaceURI:(NSString *)namespaceURI 
  qualifiedName:(NSString *)qName;
{
	NSMutableDictionary*	currentDict = (self.parseStack).lastObject;
	NSMutableDictionary*	parrentDict = nil;
	id						ealierItem = nil;
	
	if([elementName isEqualToString:@"contrib-group"])
	{
		// don't do anything
	}
	else if([elementName isEqualToString:@"contrib"])
	{
		// put it in the correct group
		NSMutableDictionary*	contributors = (self.resultDict)[@"contributors"];
		if(contributors == nil)
		{
			contributors = [NSMutableDictionary dictionary];
			(self.resultDict)[@"contributors"] = contributors;
		}

		NSString*		key = currentAttributes[@"contrib-type"];
		if(key == nil)
			key = @"author";
		
		NSMutableArray*	group = contributors[key];
		if(group == nil)
		{
			group = [NSMutableArray array];
			contributors[key] = group;
		}
		[group addObject:currentDict];
		self.currentAttributes = nil;
	}
	else if([elementName isEqualToString:@"aff"])
	{
		if(currentAttributes)
		{
			NSString*	idKey = @"affiliations";
			NSString*	idstring = currentAttributes[@"id"];
			if([idstring hasPrefix:@"edit"])
				idKey = @"editorAffiliations";
				
				// put it in the correct group
			NSMutableArray*	affiliations = (self.resultDict)[idKey];
			if(affiliations == nil)
			{
				affiliations = [NSMutableArray array];
				(self.resultDict)[idKey] = affiliations;
			}
			if(!currentDict[@"institution"] && (self.currentElementValue).length)
				currentDict[@"institution"] = self.currentElementValue;
			[affiliations addObject:currentDict];
		}
		else
		{
			// put it in the correct group
			NSMutableArray*	affiliations = (self.resultDict)[@"affiliations"];
			if(affiliations == nil)
			{
				affiliations = [NSMutableArray array];
				(self.resultDict)[@"affiliations"] = affiliations;
			}
			if(!currentDict[@"institution"] && (self.currentElementValue).length)
				currentDict[@"institution"] = self.currentElementValue;
			[affiliations addObject:currentDict];
		}
		self.currentAttributes = nil;
	}
	else
	{
		if([elementName isEqualToString:@"citation"])
		{
			NSString*	citationType = nil;
			if(currentAttributes)
				citationType = currentAttributes[@"citation-type"];
			if(citationType)
				currentDict[@"citation-type"] = citationType;
			currentDict[@"citation-text"] = currentCitationString;
		}
		if((self.parseStack).count > 1)
			parrentDict = (self.parseStack)[(self.parseStack).count -2];
		
		ealierItem = parrentDict[elementName];
		
		id	objectToAdd = nil;
		
		if(currentDict.count == 0)					// flat item
			objectToAdd = self.currentElementValue;
		else
		{
			if((self.currentElementValue).length)
				currentDict[@"value"] = self.currentElementValue;
			objectToAdd = currentDict;					// complex item
		}
		
		if(ealierItem == nil)	// no previous items like this one
		{
			// single element item
			parrentDict[elementName] = objectToAdd;
		}
		else
		{
			// ok, we have at least one already. We need to add it or make them into an array
			if([ealierItem isKindOfClass:[NSMutableArray class]])
				[ealierItem addObject:objectToAdd];
			else
			{
				NSMutableArray*	tarray = [NSMutableArray arrayWithObjects:ealierItem, objectToAdd, nil];
				parrentDict[elementName] = tarray;
			}
		} // ealierItem
	}
	self.currentElementValue = @"";
	[self.parseStack removeLastObject];		// POP!
	[elementStack removeLastObject];
} // parser:didEndElement

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	self.currentElementValue = [self.currentElementValue stringByAppendingString:string];
	NSString*	elementName = elementStack.lastObject;
    //NSLog(@"Element Name: %@", elementName);
	if(elementName && [elementName isEqualToString:@"citation"])
		self.currentCitationString = [currentCitationString stringByAppendingString:string];
} // parser:foundCharacters


@end
