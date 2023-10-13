//
//  GenericParser.m
//
//  Created by Matthew Mashyna on 8/3/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "GenericParser.h"

@implementation NSDictionary(parserextention)
-(id) objectAtPath:(NSString*)path
{
	id				result = self;
	NSDictionary*	d = self;
	
	for(NSString*key in [path componentsSeparatedByString:@"/"])
	{
		if(key.length == 0)
			continue;
		
		result = d[key];
		if(result == nil)
		{
			break;
		}
		if(![result isKindOfClass:[NSDictionary class]])
			break;
		d = result;
	}
	
	return result;
} // objectAtPath


@end


@implementation GenericParser
@synthesize searchTimer;
@synthesize delegate;
@synthesize resultDict;
@synthesize parseStack;
@synthesize valueStack;
@synthesize currentElementValue;

-(id)init
{
	if(self = [super init])
	{
		self.delegate = nil;
		self.resultDict = nil;
		self.parseStack = [NSMutableArray array];
	}
	
	return self;
	
} // init

 // dealloc

-(void) downloadAndParse:(NSString*)urlString usingDelegate:(id <GenericParserClient>)aDelegate
{
	self.delegate = aDelegate;
	self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:60
												   target:self
												 selector:@selector(workerTimeout:)
												 userInfo:nil
												  repeats:NO];
	
	
	[NSThread detachNewThreadSelector:@selector(downloadAndParseThread:)
							 toTarget:self
						   withObject:urlString];
	
} // downloadAndParse

-(void) downloadAndParseThread:(NSString*)urlString
{
	//•
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
	
	// Get ready for the response
	NSData *theData;
	NSURLResponse *response;
	NSError *error;
	
	// Make the request
	//NSLog(@"NSURL-9");
	theData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	[searchTimer invalidate];	// cancel the timer
	self.searchTimer = nil;
	
	// parse the data
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData: theData];

	parser.delegate = self;
	[parser setShouldProcessNamespaces: NO];
	[parser setShouldReportNamespacePrefixes: NO];
	[parser setShouldResolveExternalEntities: NO];
	[parser parse];
		
	if(delegate && [delegate respondsToSelector:@selector(getParserResults:)])
		[delegate performSelectorOnMainThread:@selector(getParserResults:) withObject:resultDict waitUntilDone:NO];
	
	self.currentElementValue = nil;
	self.delegate = nil;
} // downloadAndParseThread

-(void) parseString:(NSString*)string usingDelegate:(id <GenericParserClient>)aDelegate
{
	self.delegate = aDelegate;
	self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:60
												   target:self
												 selector:@selector(workerTimeout:)
												 userInfo:nil
												  repeats:NO];
	
	if(aDelegate)
	{
		[NSThread detachNewThreadSelector:@selector(parseThread:)
							 toTarget:self
						   withObject:string];
	}
	else
		[self parseThread:string];
} // parseString

-(void) parseThread:(NSString*)string
{
	//•
	
	[searchTimer invalidate];	// cancel the timer
	self.searchTimer = nil;
	
	// parse the data
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData: [string dataUsingEncoding:NSUTF8StringEncoding]];

	parser.delegate = self;
	[parser setShouldProcessNamespaces: NO];
	[parser setShouldReportNamespacePrefixes: NO];
	[parser setShouldResolveExternalEntities: NO];
	[parser parse];
	
	if(delegate && [delegate respondsToSelector:@selector(getParserResults:)])
		[delegate performSelectorOnMainThread:@selector(getParserResults:) withObject:resultDict waitUntilDone:NO];
	
	self.currentElementValue = nil;
	self.delegate = nil;
} // parseThread


-(void) workerTimeout:(NSTimer*)timer
{
	// send the error to the delegate
	if(delegate && [delegate respondsToSelector:@selector(parserTimeout)])
		[delegate parserTimeout];
	
} // workerTimeout

#pragma mark parser stuff

- (void) parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
   namespaceURI:(NSString *)namespaceURI 
  qualifiedName:(NSString *)qualifiedName 
	 attributes:(NSDictionary *)attributeDict
{
	
	self.currentElementValue = @"";
	
	NSMutableDictionary*	tempDict = [NSMutableDictionary dictionary];
#if 0
	if(attributeDict && [attributeDict count])
		[tempDict setObject:attributeDict forKey:@"attributes"];
#endif	
	[parseStack addObject:tempDict];						// PUSH!
	if(parseStack.count == 1)
		self.resultDict = parseStack[0];
	
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
	NSMutableDictionary*	currentDict = parseStack.lastObject;
	NSMutableDictionary*	parrentDict = nil;
	id						ealierItem = nil;
	
	
	if(parseStack.count > 1)
		parrentDict = parseStack[parseStack.count -2];
	
	ealierItem = parrentDict[elementName];
	
	id	objectToAdd = nil;
	
	if(currentDict.count == 0)					// flat item
		objectToAdd = currentElementValue;
	else
	{
		if(currentElementValue.length)
			currentDict[@"value"] = currentElementValue;
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
	
	self.currentElementValue = @"";
	[parseStack removeLastObject];		// POP!
} // parser:didEndElement

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	self.currentElementValue = [currentElementValue stringByAppendingString:string]; 
} // parser:foundCharacters

@end
