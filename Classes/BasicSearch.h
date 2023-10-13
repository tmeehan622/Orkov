//
//  BasicSearch.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 9/4/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchController.h"
//


@interface BasicSearch : SearchController {
}

@property (nonatomic, weak) IBOutlet	UIImageView		*portraitLogo;
@property (nonatomic, weak) IBOutlet	UIImageView		*landscapeLogo;
@property (nonatomic, weak) IBOutlet	UIImageView		*vsbanner;
@property (nonatomic, weak) IBOutlet	UIView			*innerView;
@property (nonatomic, weak) IBOutlet	UILabel			*tempLabel;		
@property (nonatomic, weak) IBOutlet	UILabel			*tempLabel2;
@property (nonatomic, weak) IBOutlet	UIView			*contentView;
@property (nonatomic, assign) CGRect						ContFrameLand;
@property (nonatomic, assign) CGRect						ContFramePort;
@property (nonatomic, assign) CGFloat					VShiftLandscape;
@property (nonatomic, assign) CGFloat					VShiftPortrait;
@property (nonatomic, strong) UIImageView				*activeLogo;

@end


