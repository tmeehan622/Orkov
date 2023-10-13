//
//  AbstractCell.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 6/22/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AbstractCell : UITableViewCell {
}
@property (nonatomic, strong) IBOutlet UILabel*			label_Title;
@property (nonatomic, strong) IBOutlet UILabel*			label_JournalTitle;
@property (nonatomic, strong) IBOutlet UILabel*			label_PubDate;
@property (nonatomic, strong) IBOutlet UILabel*			label_Authors;
@property (nonatomic, strong) IBOutlet UIImageView*		iv_UnreadDot;
@property (nonatomic, strong) IBOutlet UIButton*		btn_Note;
@property (nonatomic, strong) IBOutlet UILabel*			label_RecordNumber;
@property (nonatomic, strong) IBOutlet UILabel*         label_DocType;
@property (nonatomic, strong) IBOutlet UIView*          v_TypeContainer;
@property (nonatomic, strong) NSDictionary*		info;
@property (nonatomic, strong) NSArray*			articleIdList;
@property (nonatomic, strong) NSString*			pmcID;

+(NSString*) findADate:(NSDictionary*)d;
-(void)setBadgeHidden:(BOOL)hidden;

@end
