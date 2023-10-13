//
//  QueryAgent.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 6/22/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "QueryAgent.h"
#import "FullTextViewController.h"
#import "AuthenticationPage.h"

#define BLOCKING YES
#define USE_DELEGATE 1
@implementation QueryAgent

@synthesize searchTimer;
@synthesize resultDict;
@synthesize parseStack;
@synthesize currentAttributes;
@synthesize dbName;
@synthesize currentElementValue;
@synthesize workSilently;
@synthesize retstart;
@synthesize retmax;
@synthesize delegate;
@synthesize savedTitle;
@synthesize openTitle, blockMode;

+(NSString*)esearchURL {
	NSString    *finalString = @"http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=%@&term=%@&datetype=edat&retstart=%d&retmax=%d&usehistory=y";
	NSUserDefaults  *ud = [NSUserDefaults standardUserDefaults];
	
    if([ud boolForKey:@"proxyOnOff"]) {
		NSString    *ezProxyURL = [ud stringForKey:@"ezProxyURL"];
        if(ezProxyURL && ezProxyURL.length){
			finalString = [NSString stringWithFormat:@"%@%@", ezProxyURL, finalString];
        }
	}
	return finalString;
}

+(NSString*)efetchURL {
	NSString    *finalString = @"http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=%@&id=%@&retmode=xml";
	NSUserDefaults  *ud = [NSUserDefaults standardUserDefaults];
	
    if([ud boolForKey:@"proxyOnOff"]) {
		NSString    *ezProxyURL = [ud stringForKey:@"ezProxyURL"];
		if(ezProxyURL && ezProxyURL.length)
			finalString = [NSString stringWithFormat:@"%@%@", ezProxyURL, finalString];
	}
	return finalString;
}

+(NSString*)eLinkURL {
	NSString    *finalString = @"http://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?dbfrom=%@&db=%@&id=%@&retmode=xml";
	NSUserDefaults  *ud = [NSUserDefaults standardUserDefaults];
    
	if([ud boolForKey:@"proxyOnOff"]) {
		NSString    *ezProxyURL = [ud stringForKey:@"ezProxyURL"];
        if(ezProxyURL && ezProxyURL.length){
			finalString = [NSString stringWithFormat:@"%@%@", ezProxyURL, finalString];
        }
	}
	return finalString;
}

-(id)initForDB:(NSString*)db {
	if(self = [super init]) {
        blockMode = NO;
		retstart = 0;
		int	index = [[NSUserDefaults standardUserDefaults] integerForKey:@"itemsPerPage"];
		switch (index) {
			case 0:
				retmax = 10;
				break;
			case 1:
				retmax = 25;
				break;
			case 2:
				retmax = 50;
				break;
			case 3:
				retmax = 75;
				break;
			case 4:
				retmax = 100;
				break;
			default:
				retmax = 25;
				break;
		}
		self.delegate   = nil;
		self.resultDict = nil;
		self.parseStack = [NSMutableArray array];
		dbName          = [db copy];
        self.savedTitle = @"";
        self.openTitle  = NO;
	}
	
	return self;
}

-(void) searchFor:(NSString*)term usingDelegate:(id)aDelegate {
	self.delegate = aDelegate;
	searchTimer   = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(searchTimeout:) userInfo:nil repeats:NO];
	
	[NSThread detachNewThreadSelector:@selector(searchThread:)
							 toTarget:self
						   withObject:[term stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

-(void) searchThread:(NSString*)searchString {
	NSString    *urlString = [NSString stringWithFormat:[QueryAgent esearchURL], dbName, searchString, retstart, retmax];
    NSLog(@"Search URL: %@", urlString);
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
		
	// Get ready for the response
	NSData        *theData;
	NSURLResponse *response1;
	NSError       *error;

    theData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response1 error:&error];
    NSString *convertedStr = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    
	if(!searchTimer.valid) {
		if(delegate && [delegate respondsToSelector:@selector(letGoOfQueryAgent:)]) {
			//NSLog(@"responds to letGoOfQueryAgent  YES");
			//[delegate letGoOfQueryAgent:self];
		} else  {
            if(delegate && [delegate respondsToSelector:@selector(parserTimeout)]){
				[delegate parserTimeout];
            }
		}
	
		self.delegate = nil;
		return;
	}

	[searchTimer invalidate];	// cancel the timer

	// parse the data
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData: theData];

	parser.delegate = self;
	[parser setShouldProcessNamespaces: NO];
	[parser setShouldReportNamespacePrefixes: NO];
	[parser setShouldResolveExternalEntities: NO];
	[parser parse];
    
    /* TODO: We could iterate through the keys and check for case insensitive cases
     NSArray *allKeys = [resultDict allKeys];
     for(NSString *str in allKeys)
     {
     if([key caseInsensitiveCompare:str] == NSOrderedSame)
     {
     return [self objectForKey:str];
     }
     }
     */
    
    // Instead, let's actually look for something...in this case, an Error key and a Count key
    BOOL containsError = [resultDict objectForKey:@"Error"] != nil;
    BOOL containsCount = [resultDict objectForKey:@"Count"] != nil;
	
	//if([key.uppercaseString isEqualToString:@"ERROR"])
    if(containsError) {
        if(delegate && [delegate respondsToSelector:@selector(parserTimeout)]){
			[delegate parserTimeout];
        }
    } else {
        if(!containsCount) {
            if([[NSUserDefaults standardUserDefaults] boolForKey:@"proxyOnOff"]) {
                //NSLog(@"found html?");
                AuthenticationPage*	anotherViewController = [[AuthenticationPage alloc] initWithNibName:@"AuthenticationPage" bundle:nil];
                anotherViewController.html = theData;
                anotherViewController.delegate = delegate;
                [anotherViewController performSelectorOnMainThread:@selector(kickStartAuthentication) withObject:nil waitUntilDone:NO];
            } else {
                if(delegate && [delegate respondsToSelector:@selector(parserTimeout)])
                    [delegate parserTimeout];
            }
        } else {
            if(delegate && [delegate respondsToSelector:@selector(_getSearchResults:)])
                [delegate performSelectorOnMainThread:@selector(_getSearchResults:) withObject:resultDict waitUntilDone:NO];
        }
    }
    
    if(delegate && [delegate respondsToSelector:@selector(letGoOfQueryAgent:)]) {
		//NSLog(@"responds to letGoOfQueryAgent  YES");
		//[delegate letGoOfQueryAgent:self];
	}
	
	self.delegate = nil;
}

-(void) searchTimeout:(NSTimer*)timer {
	// send the error to the delegate
#if USE_DELEGATE
	if(delegate && [delegate respondsToSelector:@selector(parserTimeout)])
		[delegate parserTimeout];
#else
	[[NSNotificationCenter defaultCenter] postNotification:
	 [NSNotification notificationWithName:@"QUERY_ERROR" object:self userInfo:resultDict]];
#endif
	
	searchTimer = nil;
} // searchTimeout

-(void) fetchIDs:(NSArray*)pubIDs usingDelegate:(id)aDelegate {
	self.delegate = aDelegate;
	searchTimer = [NSTimer scheduledTimerWithTimeInterval:20
												   target:self
												 selector:@selector(searchTimeout:)
												 userInfo:nil
												  repeats:NO];
	
	
	[NSThread detachNewThreadSelector:@selector(fetchThread:)
							 toTarget:self
						   withObject:[pubIDs componentsJoinedByString:@","]];
}

-(void) fetchThread:(NSString*)fetchString {
	NSString            *urlString = [NSString stringWithFormat:[QueryAgent efetchURL], dbName, fetchString];
	NSMutableURLRequest *request   = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
	
	// Get ready for the response
	NSData          *theData;
	NSURLResponse   *response;
	NSError         *error;
	
	// Make the request
    NSLog(@"Fetch URL: %@", urlString);

    theData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if(!searchTimer.valid) {
		if(delegate && [delegate respondsToSelector:@selector(letGoOfQueryAgent:)]) {
			//NSLog(@"responds to letGoOfQueryAgent  YES");
			//[delegate letGoOfQueryAgent:self];
		} else {
			if(delegate && [delegate respondsToSelector:@selector(parserTimeout)])
				[delegate parserTimeout];
		}
		self.delegate = nil;
		return;
	}
	
	[searchTimer invalidate];	// cancel the timer
	
	// parse the data
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData: theData];

	parser.delegate = self;
	[parser setShouldProcessNamespaces: NO];
	[parser setShouldReportNamespacePrefixes: NO];
	[parser setShouldResolveExternalEntities: NO];
	[parser parse];
		
#if USE_DELEGATE
	if(delegate && [delegate respondsToSelector:@selector(_getFetchResults:)])
		[delegate performSelectorOnMainThread:@selector(_getFetchResults:) withObject:resultDict waitUntilDone:NO];
#else
	[[NSNotificationCenter defaultCenter] postNotification:
	 [NSNotification notificationWithName:@"PUBMED_FETCH_COMPLETE" object:self userInfo:resultDict]];
#endif
	
	if(delegate && [delegate respondsToSelector:@selector(letGoOfQueryAgent:)]) {
		//NSLog(@"responds to letGoOfQueryAgent  YES");
		//[delegate letGoOfQueryAgent:self];
	}
	
	self.delegate = nil;
}


-(void) fetchRelated:(NSArray*)pubIDs usingDelegate:(id)aDelegate {
	self.delegate = aDelegate;
	searchTimer = [NSTimer scheduledTimerWithTimeInterval:20
													target:self
												  selector:@selector(searchTimeout:)
												  userInfo:nil
												   repeats:NO];
	
	
	[NSThread detachNewThreadSelector:@selector(relatedThread:) toTarget:self withObject:[pubIDs componentsJoinedByString:@","]];
}

-(void) relatedThread:(NSString*)fetchString {
	NSString    *urlString = [NSString stringWithFormat:[QueryAgent eLinkURL], dbName, dbName, fetchString];

    NSLog(@"Fetch Related URL: %@", urlString);

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
	
	// Get ready for the response
	NSData          *theData;
	NSURLResponse   *response;
	NSError         *error;
	
	theData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if(!searchTimer.valid) {
		if(delegate && [delegate respondsToSelector:@selector(letGoOfQueryAgent:)]) {
			//NSLog(@"responds to letGoOfQueryAgent  YES");
			//[delegate letGoOfQueryAgent:self];
		} else {
			if(delegate && [delegate respondsToSelector:@selector(parserTimeout)])
				[delegate parserTimeout];
		}
		self.delegate = nil;
		return;
	}
	
	[searchTimer invalidate];	// cancel the timer
	
	// parse the data
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData: theData];

	parser.delegate = self;
	[parser setShouldProcessNamespaces: NO];
	[parser setShouldReportNamespacePrefixes: NO];
	[parser setShouldResolveExternalEntities: NO];
	[parser parse];
		
#if USE_DELEGATE
    if(delegate && [delegate respondsToSelector:@selector(_getRelatedResults:)]){
        NSLog(@"resultDict: @",resultDict);
		[delegate performSelectorOnMainThread:@selector(_getRelatedResults:) withObject:resultDict waitUntilDone:NO];
    }
#else
	[[NSNotificationCenter defaultCenter] postNotification:
	 [NSNotification notificationWithName:@"PUBMED_RELATED_COMPLETE" object:self userInfo:resultDict]];
#endif
	if(delegate && [delegate respondsToSelector:@selector(letGoOfQueryAgent:)]) {
		//NSLog(@"responds to letGoOfQueryAgent  YES");
		//[delegate letGoOfQueryAgent:self];
	}
	self.delegate = nil;
}

- (void) getFullTextFor:(NSString*)pmid usingDelegate:(id)aDelegate {
	self.delegate = aDelegate;
	searchTimer = [NSTimer scheduledTimerWithTimeInterval:20
												   target:self
												 selector:@selector(searchTimeout:)
												 userInfo:nil
												  repeats:NO];
	
	
	[NSThread detachNewThreadSelector:@selector(fullTextThread:)
							 toTarget:self
						   withObject:pmid];
}

-(void) fullTextThread:(NSString*)pmid {
	NSString    *urlString = [NSString stringWithFormat:[QueryAgent efetchURL], @"pmc", pmid];

    NSLog(@"Fulltext URL: %@", urlString);

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
	
	// Get ready for the response
	NSData          *theData;
	NSURLResponse   *response;
	NSError         *error;
	
	theData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if(!searchTimer.valid) {
		if(delegate && [delegate respondsToSelector:@selector(letGoOfQueryAgent:)]) {
			//NSLog(@"responds to letGoOfQueryAgent  YES");
			//[delegate letGoOfQueryAgent:self];
		} else {
			if(delegate && [delegate respondsToSelector:@selector(parserTimeout)])
				[delegate parserTimeout];
		}
		self.delegate = nil;
		return;
	}

	[searchTimer invalidate];	// cancel the timer

	NSString    *fullText = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
	NSRange r = [fullText rangeOfString:@"<form" options:NSCaseInsensitiveSearch];
	
	if(r.location != NSNotFound) {
		if([[NSUserDefaults standardUserDefaults] boolForKey:@"proxyOnOff"]) {
			//NSLog(@"found login for in abstract?");
			AuthenticationPage*	anotherViewController = [[AuthenticationPage alloc] initWithNibName:@"AuthenticationPage" bundle:nil];
			anotherViewController.html = theData;
			anotherViewController.delegate = delegate;
			[anotherViewController performSelectorOnMainThread:@selector(kickStartAuthentication) withObject:nil waitUntilDone:NO];
		} else {
#if USE_DELEGATE
			if(delegate && [delegate respondsToSelector:@selector(parserTimeout)])
				[delegate parserTimeout];
#else
			[[NSNotificationCenter defaultCenter] postNotification:
			 [NSNotification notificationWithName:@"QUERY_ERROR" object:self userInfo:resultDict]];
#endif
		}
	} else {
#if USE_DELEGATE
		if(delegate && [delegate respondsToSelector:@selector(setFullTextSource:)])
			[delegate performSelectorOnMainThread:@selector(setFullTextSource:) withObject:fullText waitUntilDone:NO];
#else
		[[NSNotificationCenter defaultCenter] postNotification:
		 [NSNotification notificationWithName:@"PUBMED_FULLTEXT_COMPLETE" object:self userInfo: [NSDictionary dictionaryWithObject:fullText forKey:@"fulltext"]]];
#endif
	}
	
	if(delegate && [delegate respondsToSelector:@selector(letGoOfQueryAgent:)]) {
		//NSLog(@"responds to letGoOfQueryAgent  YES");
		//[delegate letGoOfQueryAgent:self];
	}
	self.delegate = nil;
	
} // fullTextThread

#pragma mark parser stuff
//("i", "u", "b", "sup", "sub"):
- (void) parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
   namespaceURI:(NSString *)namespaceURI 
  qualifiedName:(NSString *)qualifiedName 
	 attributes:(NSDictionary *)attributeDict
{
   //NSLog(@"Begin Element: %@",elementName);
    if([elementName isEqualToString:@"sub"]) {
       // NSLog(@"********* Encountered SUB tag ************");
        blockMode = BLOCKING;
    }

    if([elementName isEqualToString:@"sup"]) {
       // NSLog(@"********* Encountered SUP tag ************");
        blockMode = BLOCKING;
    }
    
    if([elementName isEqualToString:@"i"]) {
       // NSLog(@"********* Encountered I tag ************");
        blockMode = BLOCKING;
    }
    if([elementName isEqualToString:@"u"]) {
       // NSLog(@"********* Encountered U tag ************");
        blockMode = BLOCKING;
    }
    if([elementName isEqualToString:@"b"]) {
      //  NSLog(@"********* Encountered B tag ************");
        blockMode = BLOCKING;
    }

    if (blockMode == NO) {
        self.currentElementValue = @"";
       
        [parseStack addObject:[NSMutableDictionary dictionary]];

        if(parseStack.count == 1){
            self.resultDict = parseStack[0];
        }
        
        self.currentAttributes = attributeDict;
    }
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
	NSMutableDictionary     *currentDict = parseStack.lastObject;
	NSMutableDictionary     *parrentDict = nil;
	id						 ealierItem  = nil;

   // NSLog(@"End Element: %@",elementName);

    blockMode = NO;
    
    if([elementName isEqualToString:@"sup"]) {
        blockMode = BLOCKING;
    }
    if([elementName isEqualToString:@"sub"]) {
        blockMode = BLOCKING;
    }
    if([elementName isEqualToString:@"i"]) {
        blockMode = BLOCKING;
    }
    if([elementName isEqualToString:@"u"]) {
        blockMode = BLOCKING;
    }
    if([elementName isEqualToString:@"b"]) {
        blockMode = BLOCKING;
    }

    if (blockMode == NO){
        if(parseStack.count > 1) {
            parrentDict = parseStack[parseStack.count -2];
            ealierItem = parrentDict[elementName];
        } else {
          //  NSLog(@"    no parent dict yet");
        }

        id	objectToAdd = nil;

        if([elementName isEqualToString:@"ArticleId"]) {
            if(currentAttributes) {
                NSString    *IdType = currentAttributes[@"IdType"];
                
                if(IdType && IdType.length){
                    objectToAdd = @{@"IdType": IdType, @"Id": currentElementValue};
                }
            } else {
                objectToAdd = currentElementValue;
            }
        } else {
            if(currentDict.count == 0)	{
                objectToAdd = currentElementValue;
            } else {
                objectToAdd = currentDict;					// complex item
            }
        }
        
        if(ealierItem == nil) {	// no previous items like this one
            // single element item
            parrentDict[elementName] = objectToAdd;
        } else {
            // ok, we have at least one already. We need to add it or make them into an array
            if([ealierItem isKindOfClass:[NSMutableArray class]]){
                [ealierItem addObject:objectToAdd];
            } else {
                NSMutableArray  *tarray = [NSMutableArray arrayWithObjects:ealierItem, objectToAdd, nil];
                parrentDict[elementName] = tarray;
            }
        }
        [parseStack removeLastObject];		// POP!
    }
} // parser:didEndElement

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	self.currentElementValue = [currentElementValue stringByAppendingString:string];
}


@end
