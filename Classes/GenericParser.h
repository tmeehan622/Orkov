//
//  GenericParser.h
//
//  Created by Matthew Mashyna on 8/3/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary(parserextention)
-(id) objectAtPath:(NSString*)path;
@end

@protocol GenericParserClient

-(void) getParserResults:(NSDictionary*)tResults;

@optional
-(void) parserTimeout;
-(void) parserError:(NSException*)localExcaption;

@end
//UITableView
@interface GenericParser : NSObject<NSXMLParserDelegate> {
}

@property (nonatomic, strong) 	NSTimer             *searchTimer;
@property (nonatomic,weak) 	id	delegate;
@property (nonatomic, strong) 	NSMutableDictionary *resultDict;
@property (nonatomic, strong) 	NSMutableArray      *parseStack;
@property (nonatomic, strong) 	NSMutableArray      *valueStack;
@property (nonatomic, strong) 	NSString            *currentElementValue;

-(void) downloadAndParse:(NSString*)urlString usingDelegate:(id <GenericParserClient>)aDelegate;
-(void) downloadAndParseThread:(NSString*)urlString;

-(void) parseString:(NSString*)string usingDelegate:(id <GenericParserClient>)aDelegate;
-(void) parseThread:(NSString*)string;

-(void) workerTimeout:(NSTimer*)timer;

@end
