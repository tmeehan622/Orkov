//
//  AbstractCell.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 6/22/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "AbstractCell.h"
#import "ResultsController.h"

#define	TEXT_PAD	4
#define	TEXT_OFFSET 32
#define TEXT_WIDTH 275-TEXT_OFFSET
#define AUTHOR_WIDTH 320-TEXT_OFFSET

@implementation AbstractCell
//@synthesize journalTitle, title, pubDate, authors, articleIdList, pmcID, recordNumber,iv_UnreadDot, info;
@synthesize label_Title, label_Authors, label_DocType, label_PubDate, label_JournalTitle, label_RecordNumber, iv_UnreadDot, v_TypeContainer, info;

+(NSString*) findADate:(NSDictionary*)d
{
	NSString        *foundDate       = nil;
	NSDictionary    *journal         = d[@"Journal"];
	NSDictionary    *journalIssue    = journal[@"JournalIssue"];
	NSDictionary    *pubDate         = journalIssue[@"PubDate"];
	NSString        *issue           = journalIssue[@"Issue"];
	NSString        *volume          = journalIssue[@"Volume"];
	
	foundDate = pubDate[@"MedlineDate"];
	if(foundDate)
		foundDate = [NSString stringWithFormat:@"Medline Date: %@", foundDate];
	else
	{
		NSString    *month = pubDate[@"Month"];
		NSString    *year  = pubDate[@"Year"];
		NSString    *day   = pubDate[@"Day"];
        
		if(year) {
			if(month) {
				if(day)
					foundDate = [NSString stringWithFormat:@"%@ %@ %@", day, month, year];
				else
					foundDate = [NSString stringWithFormat:@"%@ %@", month, year];
			}
			else
				foundDate = year;
		}
	} // ! medline date
	
	if(volume) {
        if(issue){
			volume = [NSString stringWithFormat:@"Volume %@, Issue %@. ", volume, issue];
        } else {
			volume = [NSString stringWithFormat:@"Volume %@. ", volume];
        }
	} else {
		volume = @"";
    }
	
	return [NSString stringWithFormat:@"%@%@", volume, foundDate];
} // findADate

/*
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])
	{
        label_Title       = [[UILabel alloc] initWithFrame:CGRectMake(TEXT_PAD+TEXT_OFFSET, 0, TEXT_WIDTH, 36)];
		label_JournalTitle= [[UILabel alloc] initWithFrame:CGRectMake(TEXT_PAD+TEXT_OFFSET, 8+30, TEXT_WIDTH, 15)];
		label_Authors     = [[UILabel alloc] initWithFrame:CGRectMake(TEXT_PAD+TEXT_OFFSET, 10+30+15, AUTHOR_WIDTH, 15)];
		label_PubDate     = [[UILabel alloc] initWithFrame:CGRectMake(TEXT_PAD+TEXT_OFFSET, 10+30+15+15, AUTHOR_WIDTH, 15)];
		label_RecordNumber= [[UILabel alloc] initWithFrame:CGRectMake(TEXT_PAD, 2, TEXT_OFFSET, 15)];
        iv_UnreadDot      = [[UIImageView alloc] initWithFrame:CGRectMake(TEXT_OFFSET/3, 74/2 - 8, 12, 12)];
		
		label_Title       .backgroundColor = [UIColor clearColor];
		label_JournalTitle.backgroundColor = [UIColor clearColor];
		label_PubDate     .backgroundColor = [UIColor clearColor];
		label_Authors     .backgroundColor = [UIColor clearColor];
		label_RecordNumber.backgroundColor = [UIColor clearColor];

		label_Title.lineBreakMode = NSLineBreakByWordWrapping;
		label_Title.numberOfLines = 2;
		label_Title.font = [UIFont boldSystemFontOfSize:15];
//		title.textColor = [UIColor blueColor];
//		title.textColor = [UIColor colorWithRed:0 green:0.5 blue:1 alpha:1];
		
		label_JournalTitle.font = [UIFont systemFontOfSize:13];
		label_Authors.font = [UIFont systemFontOfSize:11];
		label_PubDate.font = [UIFont systemFontOfSize:13];
		label_RecordNumber.font = [UIFont boldSystemFontOfSize:10];
		label_RecordNumber.textAlignment = NSTextAlignmentLeft;
		label_RecordNumber.textColor = [UIColor colorWithRed:0.5 green:0 blue:0 alpha:1];
	
		label_Title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label_JournalTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label_PubDate.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		[self addSubview:label_Title];
		[self addSubview:label_JournalTitle];
		[self addSubview:label_Authors];
		[self addSubview:label_PubDate];
		[self addSubview:iv_UnreadDot];
		[self addSubview:label_RecordNumber];

		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	}
    return self;
}
*/

/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//LOG(@"%s - IN",__FUNCTION__);

    [super setSelected:selected animated:animated];
//LOG(@"%s - OUT",__FUNCTION__);

    // Configure the view for the selected state
}
*/


-(NSDictionary*) info
{
	return info;
} // info


-(void) setInfo:(NSDictionary*)d
{
	info = d;
	
	NSDictionary    *medlineCitation = info[@"MedlineCitation"];
	NSDictionary    *article         = medlineCitation[@"Article"];
	NSDictionary    *pubmedData      = info[@"PubmedData"];
	NSDictionary    *articleIds      = pubmedData[@"ArticleIdList"];
    NSString        *pmcHack         = info[@"PMC"];

	if(articleIds)
		self.articleIdList = articleIds[@"ArticleId"];
	else
		self.articleIdList = nil;
	
    iv_UnreadDot.hidden = [ResultsController hasBeenViewed:medlineCitation[@"PMID"]];
	
    id test = article[@"ArticleTitle"];
    NSString *theTitle = @"";
    
    if ([test isKindOfClass:[NSDictionary class]]){
        NSArray *keys = [test allKeys];
        
        if (keys){
            if ([keys count] > 0){
                NSString *ky = [keys objectAtIndex:0];
                if([ky isEqualToString:@"sup"]){
                    NSLog(@"here we go");
                }
                id content = [test objectForKey:ky];
                
                if(content){
                    if ([test isKindOfClass:[NSArray class]]){
                        theTitle = @"Array of Items";
                    } else {
                    theTitle  = [NSString stringWithString:content];
//                    if ([content isMemberOfClass:[NSTaggedPointerString class]]){
//                        theTitle = content;
//                    }
                    }
                }
            }
         }
    } else {
       // NSLog(@"Plain Jane Title");
        theTitle = article[@"ArticleTitle"];
    }
    //NSLog(@"test string: %@",test);
    //label_Title.text = article[@"ArticleTitle"];
    

    NSDictionary    *journal = article[@"Journal"];

    label_JournalTitle.text  = journal[@"Title"];
    label_PubDate.text       = [AbstractCell findADate:article];
    
    if (theTitle == nil){
        theTitle = @"No Title Listed";
        if (journal != nil){
            if (journal[@"Title"] != nil){
                theTitle = journal[@"Title"];
            }
        }
    }
    
    label_Title.text         = theTitle;

	id	otherID = medlineCitation[@"OtherID"];

    self.pmcID = nil;
	if(otherID) {
		if([otherID isKindOfClass:[NSArray class]]) {
			for(NSString* thisID in otherID) {
				if([thisID.uppercaseString hasPrefix:@"PMC"]) {
					self.pmcID = [thisID substringFromIndex:3];
					break;
				}
			}
		} else if([otherID isKindOfClass:[NSString class]]) {
			self.pmcID = otherID;
		}
 	}
    
    if (self.pmcID == nil){
        for(id xidType in self.articleIdList) {
            
            NSString    *xidTypeString = nil;
            
            if(![xidType isKindOfClass:[NSDictionary class]]){
               // NSLog(@"not a dict, skip it");
                continue;
            }
            
            xidTypeString = xidType[@"IdType"];
           // NSLog(@"xid string: %@",xidTypeString);
            
            if([xidTypeString.uppercaseString isEqualToString:@"PMC"]) {
                self.pmcID   = xidType[@"Id"];
            }
        }
    }
    
	NSString    *authorsString = @"";
	
	NS_DURING
	NSArray *authorList = article[@"AuthorList/Author"];
	if(authorList != nil && ![authorList isKindOfClass:[NSArray class]])
		authorList = @[authorList];
	
	NSArray *authorStrings = [NSArray array];
	for(NSDictionary*d in authorList) {
		authorStrings = [authorStrings arrayByAddingObject: [NSString stringWithFormat:@"%@ %@", d[@"LastName"],d[@"Initials"]]];
	}
	authorsString = [authorStrings componentsJoinedByString:@", "];
	NS_HANDLER
	NS_ENDHANDLER

	label_Authors.text = authorsString;
    
    if (self.pmcID == nil){
        self.pmcID = pmcHack;
    }
    
    if(self.pmcID)
        label_DocType.text = @"PDF";
    else
        label_DocType.text = @"WEB";
    
 } // setInfo

-(void)setBadgeHidden:(BOOL)hidden
{
    v_TypeContainer.hidden = hidden;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [v_TypeContainer layoutIfNeeded]; // Seems to be an iOS bug that some views have 1000x1000 here
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:v_TypeContainer.bounds byRoundingCorners: UIRectCornerBottomLeft cornerRadii:CGSizeMake(10.0, 10.0)];
    CAShapeLayer *maskLayer = [CAShapeLayer new];
    maskLayer.frame = v_TypeContainer.bounds;
    maskLayer.path  = maskPath.CGPath;
    v_TypeContainer.layer.mask = maskLayer;
}

@end
