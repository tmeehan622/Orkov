//
//  SafeCell.m
//  Pubmed Experiment
//
//  Created by Tom Meehan on 3/5/19.
//

#import "SafeCell.h"

@implementation SafeCell


@synthesize recordNumber;
@synthesize titleLBL;
@synthesize descLBL;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
